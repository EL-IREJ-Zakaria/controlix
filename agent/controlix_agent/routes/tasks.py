from __future__ import annotations

from flask import Blueprint, current_app, jsonify, request

from ..utils.security import ensure_authorized

tasks_blueprint = Blueprint("tasks", __name__)


@tasks_blueprint.get("/tasks")
def get_tasks():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    task_service = current_app.extensions["task_service"]
    return jsonify({"success": True, "tasks": task_service.list_tasks()})


@tasks_blueprint.post("/tasks")
def create_task():
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    task_service = current_app.extensions["task_service"]
    payload = request.get_json(silent=True) or {}
    task = task_service.save_task(payload)
    return jsonify({"success": True, "task": task}), 201


@tasks_blueprint.put("/tasks/<task_id>")
def update_task(task_id: str):
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    task_service = current_app.extensions["task_service"]
    payload = request.get_json(silent=True) or {}
    payload["id"] = task_id
    task = task_service.save_task(payload)
    return jsonify({"success": True, "task": task})


@tasks_blueprint.delete("/tasks/<task_id>")
def delete_task(task_id: str):
    settings = current_app.config["SETTINGS"]
    ensure_authorized(request, settings.secret_key)
    task_service = current_app.extensions["task_service"]
    task_service.delete_task(task_id)
    return jsonify({"success": True})
