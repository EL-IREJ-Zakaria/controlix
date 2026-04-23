from __future__ import annotations

import json
import os
import urllib.error
import urllib.request

from flask import Blueprint, current_app, jsonify, request
from werkzeug.exceptions import BadRequest, InternalServerError, ServiceUnavailable

from ..utils.security import ensure_authorized

chat_blueprint = Blueprint("chat", __name__)


def _normalize_messages(raw_messages: object) -> list[dict]:
    if raw_messages is None:
        return []
    if not isinstance(raw_messages, list):
        raise BadRequest('"messages" must be a JSON array.')

    normalized: list[dict] = []
    for item in raw_messages:
        if not isinstance(item, dict):
            continue
        role = item.get("role")
        content = item.get("content")
        if role not in ("user", "assistant"):
            continue
        if not isinstance(content, str):
            continue
        stripped = content.strip()
        if not stripped:
            continue
        normalized.append({"role": role, "content": stripped})

    return normalized[-24:]


def _gemini_contents(messages: list[dict]) -> list[dict]:
    contents: list[dict] = []
    for message in messages:
        role = message.get("role")
        text = message.get("content")
        if not isinstance(text, str) or not text.strip():
            continue
        if role == "user":
            gemini_role = "user"
        elif role == "assistant":
            gemini_role = "model"
        else:
            continue
        contents.append({"role": gemini_role, "parts": [{"text": text.strip()}]})
    return contents


def _call_gemini(api_key: str, model: str, messages: list[dict]) -> str:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    payload = {
        "system_instruction": {
            "parts": [
                {
                    "text": (
                        "Tu es Controlix Assistant, un assistant professionnel et concis pour une application "
                        "d'automatisation Windows. Réponds en français. Sois clair, pratique et prudent. "
                        "Quand c'est utile, pose une seule question de clarification courte."
                    )
                }
            ]
        },
        "contents": _gemini_contents(messages),
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json", "x-goog-api-key": api_key},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as response:
            body = response.read().decode("utf-8")
    except urllib.error.HTTPError as error:
        detail = ""
        try:
            detail = error.read().decode("utf-8")
        except Exception:  # noqa: BLE001
            detail = ""
        raise ServiceUnavailable(
            f"Gemini API error ({getattr(error, 'code', 'unknown')}): {detail or error.reason}"
        ) from error
    except Exception as error:  # noqa: BLE001
        raise ServiceUnavailable(f"Gemini API request failed: {error}") from error

    try:
        data = json.loads(body)
        candidates = data.get("candidates") or []
        first = candidates[0] if candidates else {}
        content = first.get("content") or {}
        parts = content.get("parts") or []
        text = "".join(part.get("text", "") for part in parts if isinstance(part, dict))
        return text.strip()
    except Exception as error:  # noqa: BLE001
        raise ServiceUnavailable(f"Gemini API returned an invalid response: {error}") from error


@chat_blueprint.post("/api/chat")
def create_chat_reply():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)

    payload = request.get_json(silent=True) or {}
    normalized_messages = _normalize_messages(payload.get("messages"))

    gemini_key = os.getenv("GEMINI_API_KEY", "").strip()
    gemini_model = os.getenv("GEMINI_MODEL", "gemini-2.0-flash").strip() or "gemini-2.0-flash"
    if gemini_key:
        reply = _call_gemini(gemini_key, gemini_model, normalized_messages)
        if not reply:
            raise ServiceUnavailable("Gemini returned an empty reply.")
        return jsonify({"success": True, "reply": reply})

    openai_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not openai_key:
        raise InternalServerError(
            "OPENAI_API_KEY/GEMINI_API_KEY is missing on the server. Configure it in agent/.env."
        )

    model = os.getenv("OPENAI_MODEL", "gpt-5").strip() or "gpt-5"

    try:
        from openai import OpenAI
    except ImportError as error:
        raise ServiceUnavailable(
            "OpenAI SDK is not installed on the server. Install it with: pip install openai"
        ) from error

    client = OpenAI(api_key=openai_key)
    try:
        response = client.responses.create(
            model=model,
            input=[
                {
                    "role": "developer",
                    "content": (
                        "Tu es Controlix Assistant, un assistant professionnel et concis pour une application "
                        "d'automatisation Windows. Réponds en français. Sois clair, pratique et prudent. "
                        "Quand c'est utile, pose une seule question de clarification courte."
                    ),
                },
                *normalized_messages,
            ],
            store=False,
        )
    except Exception as error:  # noqa: BLE001
        raise ServiceUnavailable(f"AI provider error: {error}") from error

    reply = (getattr(response, "output_text", "") or "").strip()
    if not reply:
        raise ServiceUnavailable("The AI provider returned an empty reply.")

    return jsonify({"success": True, "reply": reply})
