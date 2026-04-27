from __future__ import annotations

import email.utils
import json
import random
import re
import time
import urllib.error
import urllib.parse
import urllib.request

from ..config import Settings

_POWERSHELL_TAG_PATTERN = re.compile(
    r"<powershell>(?P<script>.*?)</powershell>", re.IGNORECASE | re.DOTALL
)
_FENCED_BLOCK_PATTERN = re.compile(
    r"```(?:powershell|ps1)?\s*(?P<script>.*?)\s*```",
    re.IGNORECASE | re.DOTALL,
)
_FENCE_PATTERN = re.compile(r"^```[a-zA-Z0-9_-]*\s*|\s*```$", re.MULTILINE)

_RETRYABLE_HTTP_CODES = {429, 500, 502, 503, 504}


class GeminiApiError(RuntimeError):
    def __init__(
        self,
        message: str,
        *,
        status_code: int | None = None,
        retry_after: float | None = None,
        retryable: bool = False,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.retry_after = retry_after
        self.retryable = retryable


class GeminiAssistantService:
    def __init__(self, settings: Settings) -> None:
        self._api_key = settings.gemini_api_key
        primary_model = settings.gemini_model
        self._models = (primary_model, *settings.gemini_fallback_models)
        self._timeout = settings.gemini_timeout
        self._max_retries = max(0, settings.gemini_max_retries)
        self._retry_base_delay = max(0.0, settings.gemini_retry_base_delay)
        self._retry_max_delay = max(self._retry_base_delay, settings.gemini_retry_max_delay)

    @property
    def is_configured(self) -> bool:
        return bool(self._api_key)

    def generate_powershell_script(self, prompt: str) -> str:
        if not self._api_key:
            raise RuntimeError("Gemini API key is missing.")

        system_instructions = (
            "You are a PowerShell generator for Windows.\n"
            "Return ONLY the PowerShell script, no explanations, no markdown.\n"
            "Wrap the script in <powershell>...</powershell>.\n"
            "If the request is unsafe or impossible, return an empty <powershell></powershell>."
        )
        initial = self._generate_text(f"{system_instructions}\n\nUser request:\n{prompt}")
        script = _extract_powershell_script(initial)
        if not script:
            return ""

        ok, error_message = _powershell_parses(script)
        if ok:
            return script

        repair_prompt = (
            f"{system_instructions}\n\n"
            "The previous script had a PowerShell parse error.\n"
            f"Parse error:\n{error_message}\n\n"
            f"User request:\n{prompt}\n\n"
            "Return a corrected script that parses successfully."
        )
        repaired = self._generate_text(repair_prompt)
        repaired_script = _extract_powershell_script(repaired)
        if not repaired_script:
            return script

        ok, _ = _powershell_parses(repaired_script)
        return repaired_script if ok else script

    def _generate_text(self, prompt: str) -> str:
        last_error: GeminiApiError | None = None
        for model in self._models:
            try:
                return self._generate_text_with_model(model, prompt)
            except GeminiApiError as error:
                last_error = error
                if error.retryable and model != self._models[-1]:
                    continue
                raise
        raise last_error or GeminiApiError("Gemini API request failed.")

    def _generate_text_with_model(self, model_name: str, prompt: str) -> str:
        # Using the public Gemini API via Google Generative Language endpoint.
        # Keep the payload minimal to reduce compatibility issues.
        model = urllib.parse.quote(model_name, safe="")
        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{model}:generateContent?key={urllib.parse.quote(self._api_key, safe='')}"
        )
        payload = {
            "contents": [{"role": "user", "parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.2, "maxOutputTokens": 512},
        }
        body = json.dumps(payload).encode("utf-8")

        attempt = 0
        while True:
            request = urllib.request.Request(
                url,
                data=body,
                headers={
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                },
                method="POST",
            )
            try:
                with urllib.request.urlopen(request, timeout=self._timeout) as response:
                    raw = response.read().decode("utf-8", errors="replace")
                data = json.loads(raw or "{}")
                if not isinstance(data, dict):
                    raise GeminiApiError("Gemini API returned an unexpected payload.")
                return _extract_gemini_text(data)
            except urllib.error.HTTPError as error:
                status_code = getattr(error, "code", None)
                details = _read_http_error_body(error)
                retry_after = _parse_retry_after(error.headers.get("Retry-After"))
                retryable = bool(status_code in _RETRYABLE_HTTP_CODES)
                message = _format_gemini_http_error(status_code, details)
                if retryable and attempt < self._max_retries:
                    _sleep_before_retry(
                        attempt,
                        retry_after=retry_after,
                        base_delay=self._retry_base_delay,
                        max_delay=self._retry_max_delay,
                    )
                    attempt += 1
                    continue
                raise GeminiApiError(
                    message,
                    status_code=status_code,
                    retry_after=retry_after,
                    retryable=retryable,
                ) from error
            except (urllib.error.URLError, TimeoutError, OSError) as error:
                retryable = True
                message = f"Gemini API request failed. {error}".strip()
                if retryable and attempt < self._max_retries:
                    _sleep_before_retry(
                        attempt,
                        retry_after=None,
                        base_delay=self._retry_base_delay,
                        max_delay=self._retry_max_delay,
                    )
                    attempt += 1
                    continue
                raise GeminiApiError(message, retryable=retryable) from error
            except json.JSONDecodeError as error:
                raise GeminiApiError("Gemini API returned invalid JSON.") from error


def _extract_gemini_text(payload: dict) -> str:
    candidates = payload.get("candidates")
    if not isinstance(candidates, list) or not candidates:
        return ""
    first = candidates[0]
    if not isinstance(first, dict):
        return ""
    content = first.get("content")
    if not isinstance(content, dict):
        return ""
    parts = content.get("parts")
    if not isinstance(parts, list) or not parts:
        return ""
    texts: list[str] = []
    for part in parts:
        if isinstance(part, dict):
            text = part.get("text")
            if isinstance(text, str) and text:
                texts.append(text)
    return "\n".join(texts).strip()


def _extract_powershell_script(text: str) -> str:
    cleaned = (text or "").strip()
    if not cleaned:
        return ""

    match = _POWERSHELL_TAG_PATTERN.search(cleaned)
    if match:
        cleaned = match.group("script").strip()
    else:
        fenced = _FENCED_BLOCK_PATTERN.search(cleaned)
        if fenced:
            cleaned = fenced.group("script").strip()

    cleaned = _FENCE_PATTERN.sub("", cleaned).strip()
    return cleaned


def _powershell_parses(script: str) -> tuple[bool, str]:
    import base64
    import subprocess

    prepared_script = (
        "$ErrorActionPreference = 'Stop'\n"
        + "[ScriptBlock]::Create(@'\n"
        + script
        + "\n'@) | Out-Null\n"
    )
    encoded_script = base64.b64encode(prepared_script.encode("utf-16-le")).decode("ascii")
    command = [
        "powershell.exe",
        "-NoLogo",
        "-NoProfile",
        "-NonInteractive",
        "-ExecutionPolicy",
        "Bypass",
        "-EncodedCommand",
        encoded_script,
    ]

    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=8,
            shell=False,
            check=False,
        )
    except FileNotFoundError:
        return False, "PowerShell was not found on this Windows machine."
    except subprocess.TimeoutExpired:
        return False, "Parse check timed out."

    if completed.returncode == 0:
        return True, ""

    stderr = (completed.stderr or "").strip()
    stdout = (completed.stdout or "").strip()
    message = stderr or stdout or f"Parse check failed with exit code {completed.returncode}."
    return False, message


def _read_http_error_body(error: urllib.error.HTTPError) -> str:
    try:
        return error.read().decode("utf-8", errors="replace")
    except Exception:
        return ""


def _format_gemini_http_error(status_code: int | None, details: str) -> str:
    message = ""
    status = ""
    trimmed_details = (details or "").strip()
    if details:
        try:
            parsed = json.loads(details)
            if isinstance(parsed, dict):
                err = parsed.get("error")
                if isinstance(err, dict):
                    msg = err.get("message")
                    if isinstance(msg, str):
                        message = msg.strip()
                    st = err.get("status")
                    if isinstance(st, str):
                        status = st.strip()
        except json.JSONDecodeError:
            message = _truncate(trimmed_details, 800)

    parts: list[str] = []
    if status_code:
        parts.append(f"Gemini API error (HTTP {status_code}).")
    else:
        parts.append("Gemini API error.")
    if message:
        parts.append(message)
    elif trimmed_details:
        parts.append(_truncate(trimmed_details, 800))
    if status and status not in message:
        parts.append(f"Status: {status}.")
    return " ".join(parts).strip()


def _parse_retry_after(value: str | None) -> float | None:
    if not value:
        return None
    text = value.strip()
    if not text:
        return None
    if text.isdigit():
        seconds = int(text)
        return float(max(0, seconds))
    try:
        when = email.utils.parsedate_to_datetime(text)
    except (TypeError, ValueError):
        return None
    if when is None:
        return None
    if when.tzinfo is None:
        return None
    now = time.time()
    return float(max(0.0, when.timestamp() - now))


def _sleep_before_retry(
    attempt: int,
    *,
    retry_after: float | None,
    base_delay: float,
    max_delay: float,
) -> None:
    if retry_after is not None:
        delay = max(0.0, min(max_delay, retry_after))
    else:
        delay = base_delay * (2**attempt)
        delay = max(0.0, min(max_delay, delay))
        jitter = random.uniform(0.0, delay * 0.25)
        delay += jitter
    if delay > 0:
        time.sleep(delay)


def _truncate(value: str, limit: int) -> str:
    if len(value) <= limit:
        return value
    return value[: max(0, limit - 1)].rstrip() + "…"
