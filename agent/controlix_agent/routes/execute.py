from __future__ import annotations

from flask import Blueprint, current_app, jsonify, request
from werkzeug.exceptions import BadRequest, NotFound

from ..utils.security import ensure_authorized

execute_blueprint = Blueprint("execute", __name__)


@execute_blueprint.post("/execute")
def execute():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    payload = request.get_json(silent=True) or {}
    task_id = payload.get("task_id")

    if not isinstance(task_id, str) or not task_id.strip():
        raise BadRequest("task_id is required.")

    task_service = current_app.extensions["task_service"]
    task = task_service.get_task(task_id.strip())
    if task is None:
        raise NotFound(f"Task '{task_id}' was not found.")

    execution_service = current_app.extensions["execution_service"]
    result = execution_service.execute_task(task)
    return jsonify(result)
