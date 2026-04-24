from __future__ import annotations

from flask import Flask, jsonify, request
from werkzeug.exceptions import HTTPException

from .config import load_settings
from .routes.assistant import assistant_blueprint
from .routes.execute import execute_blueprint
from .routes.system import system_blueprint
from .routes.tasks import tasks_blueprint
from .services.execution_service import ExecutionService
from .services.gemini_assistant_service import GeminiAssistantService
from .services.task_service import TaskService
from .utils.security import ensure_lan_request


def create_app() -> Flask:
    app = Flask(__name__)
    settings = load_settings()

    app.config["SETTINGS"] = settings
    app.extensions["task_service"] = TaskService(settings.tasks_file)
    app.extensions["execution_service"] = ExecutionService(settings)
    app.extensions["gemini_assistant_service"] = GeminiAssistantService(settings)

    @app.before_request
    def restrict_to_lan() -> None:
        ensure_lan_request(request)

    @app.errorhandler(HTTPException)
    def handle_http_error(error: HTTPException):
        return (
            jsonify(
                {
                    "success": False,
                    "message": error.description,
                    "error_code": error.code,
                }
            ),
            error.code,
        )

    @app.errorhandler(KeyError)
    def handle_key_error(error: KeyError):
        return (
            jsonify(
                {
                    "success": False,
                    "message": str(error).strip("'"),
                    "error_code": 404,
                }
            ),
            404,
        )

    @app.errorhandler(ValueError)
    def handle_value_error(error: ValueError):
        return (
            jsonify(
                {
                    "success": False,
                    "message": str(error),
                    "error_code": 400,
                }
            ),
            400,
        )

    @app.errorhandler(Exception)
    def handle_unexpected_error(error: Exception):
        app.logger.exception("Unhandled Controlix agent error")
        return (
            jsonify(
                {
                    "success": False,
                    "message": "Unexpected server error.",
                    "error_code": 500,
                }
            ),
            500,
        )

    app.register_blueprint(system_blueprint)
    app.register_blueprint(tasks_blueprint)
    app.register_blueprint(execute_blueprint)
    app.register_blueprint(assistant_blueprint)
    return app
