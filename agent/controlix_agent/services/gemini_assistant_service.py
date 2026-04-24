from __future__ import annotations

import json
import re
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


class GeminiAssistantService:
    def __init__(self, settings: Settings) -> None:
        self._api_key = settings.gemini_api_key
        self._model = settings.gemini_model
        self._timeout = settings.gemini_timeout

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
        # Using the public Gemini API via Google Generative Language endpoint.
        # We keep the payload minimal to reduce compatibility issues.
        model = urllib.parse.quote(self._model, safe="")
        url = (
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{model}:generateContent?key={urllib.parse.quote(self._api_key, safe='')}"
        )
        payload = {
            "contents": [
                {
                    "role": "user",
                    "parts": [{"text": prompt}],
                }
            ],
            "generationConfig": {
                "temperature": 0.2,
                "maxOutputTokens": 512,
            },
        }
        body = json.dumps(payload).encode("utf-8")
        request = urllib.request.Request(
            url,
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=self._timeout) as response:
                raw = response.read().decode("utf-8", errors="replace")
        except urllib.error.HTTPError as error:
            details = ""
            try:
                details = error.read().decode("utf-8", errors="replace")
            except Exception:
                details = ""
            raise RuntimeError(
                f"Gemini API error (HTTP {error.code}). {details}".strip()
            ) from error
        except urllib.error.URLError as error:
            raise RuntimeError(f"Gemini API request failed. {error}".strip()) from error

        try:
            data = json.loads(raw or "{}")
        except json.JSONDecodeError as error:
            raise RuntimeError("Gemini API returned invalid JSON.") from error

        if not isinstance(data, dict):
            raise RuntimeError("Gemini API returned an unexpected payload.")

        return _extract_gemini_text(data)


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
