from __future__ import annotations

import os

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


@chat_blueprint.post("/api/chat")
def create_chat_reply():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)

    payload = request.get_json(silent=True) or {}
    normalized_messages = _normalize_messages(payload.get("messages"))

    api_key = os.getenv("OPENAI_API_KEY", "").strip()
    if not api_key:
        raise InternalServerError(
            "OPENAI_API_KEY is missing on the server. Configure it in agent/.env."
        )

    model = os.getenv("OPENAI_MODEL", "gpt-5").strip() or "gpt-5"

    try:
        from openai import OpenAI
    except ImportError as error:
        raise ServiceUnavailable(
            "OpenAI SDK is not installed on the server. Install it with: pip install openai"
        ) from error

    client = OpenAI(api_key=api_key)
    response = client.responses.create(
        model=model,
        input=[
            {
                "role": "developer",
                "content": (
                    "You are Controlix Assistant, a concise professional assistant for a Windows automation app. "
                    "Be clear, practical, and safe. When needed, ask one short clarifying question."
                ),
            },
            *normalized_messages,
        ],
        store=False,
    )

    reply = (getattr(response, "output_text", "") or "").strip()
    if not reply:
        raise ServiceUnavailable("The AI provider returned an empty reply.")

    return jsonify({"success": True, "reply": reply})

