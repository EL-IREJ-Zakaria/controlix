from __future__ import annotations

from flask import Blueprint, current_app, jsonify, request
from werkzeug.exceptions import BadRequest, BadGateway, ServiceUnavailable, TooManyRequests

from ..utils.security import ensure_authorized
from ..services.gemini_assistant_service import GeminiApiError

assistant_blueprint = Blueprint("assistant", __name__)


@assistant_blueprint.post("/assistant/gemini/powershell")
def gemini_powershell() -> tuple[object, int] | object:
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)

    payload = request.get_json(silent=True) or {}
    prompt = payload.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip():
        raise BadRequest("prompt is required.")

    gemini_service = current_app.extensions["gemini_assistant_service"]
    if not gemini_service.is_configured:
        raise ServiceUnavailable(
            "Gemini is not configured. Set CONTROLIX_GEMINI_API_KEY in agent/.env."
        )

    try:
        script = gemini_service.generate_powershell_script(prompt.strip())
    except GeminiApiError as error:
        if error.status_code == 429:
            raise TooManyRequests(str(error)) from error
        if error.status_code in (500, 502, 503, 504) or error.retryable:
            raise ServiceUnavailable(str(error)) from error
        raise BadGateway(str(error)) from error
    except RuntimeError as error:
        raise BadGateway(str(error)) from error

    if not script.strip():
        raise BadRequest("Gemini could not produce a PowerShell script for this request.")

    return jsonify({"success": True, "script": script})
