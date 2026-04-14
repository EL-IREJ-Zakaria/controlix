from __future__ import annotations

import json
import re
import threading
import uuid
from datetime import datetime, timezone
from pathlib import Path


class TaskService:
    _accent_pattern = re.compile(r"^#[0-9A-Fa-f]{6}$")
    _icon_pattern = re.compile(r"^[a-z0-9_-]{2,32}$")

    def __init__(self, tasks_file: Path) -> None:
        self._tasks_file = tasks_file
        self._lock = threading.Lock()
        self._ensure_store()

    def list_tasks(self) -> list[dict]:
        with self._lock:
            tasks = self._read_tasks()
        return sorted(tasks, key=lambda item: item["title"].lower())

    def get_task(self, task_id: str) -> dict | None:
        with self._lock:
            for task in self._read_tasks():
                if task["id"] == task_id:
                    return task
        return None

    def save_task(self, payload: dict) -> dict:
        title = self._require_text(payload.get("title"), "title", 80)
        description = self._optional_text(payload.get("description"), 240)
        script = self._require_text(payload.get("script"), "script", 8000)
        accent_hex = self._normalize_accent(payload.get("accent_hex") or payload.get("accentHex"))
        icon = self._normalize_icon(payload.get("icon"))
        now = _utc_now()

        with self._lock:
            tasks = self._read_tasks()
            requested_id = payload.get("id")

            if isinstance(requested_id, str) and requested_id.strip():
                task_id = requested_id.strip()
                for index, existing in enumerate(tasks):
                    if existing["id"] == task_id:
                        updated_task = {
                            "id": task_id,
                            "title": title,
                            "description": description,
                            "script": script,
                            "accent_hex": accent_hex,
                            "icon": icon,
                            "created_at": existing["created_at"],
                            "updated_at": now,
                        }
                        tasks[index] = updated_task
                        self._write_tasks(tasks)
                        return updated_task
                raise KeyError(f"Task '{task_id}' was not found.")

            created_task = {
                "id": uuid.uuid4().hex,
                "title": title,
                "description": description,
                "script": script,
                "accent_hex": accent_hex,
                "icon": icon,
                "created_at": now,
                "updated_at": now,
            }
            tasks.append(created_task)
            self._write_tasks(tasks)
            return created_task

    def delete_task(self, task_id: str) -> None:
        with self._lock:
            tasks = self._read_tasks()
            next_tasks = [task for task in tasks if task["id"] != task_id]
            if len(next_tasks) == len(tasks):
                raise KeyError(f"Task '{task_id}' was not found.")
            self._write_tasks(next_tasks)

    def _ensure_store(self) -> None:
        if self._tasks_file.exists():
            return
        self._write_tasks(_default_tasks())

    def _read_tasks(self) -> list[dict]:
        if not self._tasks_file.exists():
            return _default_tasks()
        with self._tasks_file.open("r", encoding="utf-8") as handle:
            data = json.load(handle)
        if not isinstance(data, list):
            raise ValueError("tasks.json must contain a JSON array.")
        return data

    def _write_tasks(self, tasks: list[dict]) -> None:
        with self._tasks_file.open("w", encoding="utf-8") as handle:
            json.dump(tasks, handle, indent=2)

    @staticmethod
    def _require_text(raw_value: object, field_name: str, max_length: int) -> str:
        if not isinstance(raw_value, str) or not raw_value.strip():
            raise ValueError(f"{field_name} is required.")
        value = raw_value.strip()
        if len(value) > max_length:
            raise ValueError(f"{field_name} exceeds {max_length} characters.")
        return value

    @staticmethod
    def _optional_text(raw_value: object, max_length: int) -> str:
        if raw_value is None:
            return ""
        if not isinstance(raw_value, str):
            raise ValueError("description must be a string.")
        value = raw_value.strip()
        if len(value) > max_length:
            raise ValueError(f"description exceeds {max_length} characters.")
        return value

    def _normalize_accent(self, raw_value: object) -> str:
        if not isinstance(raw_value, str) or not raw_value.strip():
            return "#4F46E5"
        value = raw_value.strip()
        if not self._accent_pattern.match(value):
            raise ValueError("accent_hex must be a 6-digit hexadecimal color.")
        return value.upper()

    def _normalize_icon(self, raw_value: object) -> str:
        if not isinstance(raw_value, str) or not raw_value.strip():
            return "bolt"
        value = raw_value.strip().lower()
        if not self._icon_pattern.match(value):
            raise ValueError("icon must contain only lowercase letters, numbers, dashes, or underscores.")
        return value


def _default_tasks() -> list[dict]:
    now = _utc_now()
    return [
        {
            "id": "lock-workstation",
            "title": "Lock workstation",
            "description": "Locks the current Windows session immediately.",
            "script": "rundll32.exe user32.dll,LockWorkStation",
            "accent_hex": "#2563EB",
            "icon": "lock",
            "created_at": now,
            "updated_at": now,
        },
        {
            "id": "open-task-manager",
            "title": "Open Task Manager",
            "description": "Launches Task Manager for quick troubleshooting.",
            "script": "Start-Process taskmgr.exe",
            "accent_hex": "#14B8A6",
            "icon": "desktop",
            "created_at": now,
            "updated_at": now,
        },
        {
            "id": "restart-explorer",
            "title": "Restart Explorer",
            "description": "Restarts Windows Explorer and refreshes the shell.",
            "script": "Stop-Process -Name explorer -Force; Start-Process explorer.exe",
            "accent_hex": "#7C3AED",
            "icon": "rocket",
            "created_at": now,
            "updated_at": now,
        },
    ]


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()
