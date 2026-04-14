from __future__ import annotations

from flask import Blueprint, current_app, jsonify, request

from ..utils.security import ensure_authorized

system_blueprint = Blueprint("system", __name__)


@system_blueprint.get("/health")
def health():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    task_service = current_app.extensions["task_service"]
    return jsonify(
        {
            "success": True,
            "machine_name": settings.machine_name,
            "port": settings.port,
            "tasks_count": len(task_service.list_tasks()),
        }
    )


@system_blueprint.get("/history")
def history():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    execution_service = current_app.extensions["execution_service"]
    limit = int(request.args.get("limit", 20))
    return jsonify(
        {
            "success": True,
            "history": execution_service.list_history(limit),
        }
    )
