from __future__ import annotations

import base64
import json
import subprocess
import threading
import time
from datetime import datetime, timezone

from ..config import Settings


class ExecutionService:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._lock = threading.Lock()
        self._ensure_store()

    def execute_task(self, task: dict) -> dict:
        return self._run_script(
            script=task["script"],
            task_title=task["title"],
            task_id=task["id"],
        )

    def list_history(self, limit: int = 20) -> list[dict]:
        bounded_limit = max(1, min(limit, 100))
        with self._lock:
            history = self._read_history()
        return history[:bounded_limit]

    def _run_script(self, script: str, task_title: str, task_id: str) -> dict:
        encoded_script = base64.b64encode(script.encode("utf-16-le")).decode("ascii")
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
        executed_at = _utc_now()
        started_at = time.perf_counter()

        try:
            completed = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=self._settings.execution_timeout,
                shell=False,
                check=False,
            )
            stdout = (completed.stdout or "").strip()
            stderr = (completed.stderr or "").strip()
            error_code = completed.returncode
            success = error_code == 0
        except subprocess.TimeoutExpired as error:
            stdout = (error.stdout or "").strip() if isinstance(error.stdout, str) else ""
            stderr = (error.stderr or "").strip() if isinstance(error.stderr, str) else ""
            if not stderr:
                stderr = (
                    f"Execution exceeded the {self._settings.execution_timeout}-second timeout."
                )
            error_code = 124
            success = False
        except FileNotFoundError:
            stdout = ""
            stderr = "PowerShell was not found on this Windows machine."
            error_code = 9009
            success = False

        duration_ms = int((time.perf_counter() - started_at) * 1000)
        output = stdout or stderr

        result = {
            "success": success,
            "task_id": task_id,
            "task_title": task_title,
            "output": output,
            "stdout": stdout,
            "stderr": stderr,
            "error_code": error_code,
            "duration_ms": duration_ms,
            "executed_at": executed_at,
        }
        self._append_history({**result, "script": script})
        return result

    def _ensure_store(self) -> None:
        if self._settings.logs_file.exists():
            return
        self._write_history([])

    def _read_history(self) -> list[dict]:
        if not self._settings.logs_file.exists():
            return []
        with self._settings.logs_file.open("r", encoding="utf-8") as handle:
            data = json.load(handle)
        if not isinstance(data, list):
            raise ValueError("execution_logs.json must contain a JSON array.")
        return data

    def _write_history(self, history: list[dict]) -> None:
        with self._settings.logs_file.open("w", encoding="utf-8") as handle:
            json.dump(history, handle, indent=2)

    def _append_history(self, entry: dict) -> None:
        with self._lock:
            history = self._read_history()
            trimmed_history = [entry, *history][: self._settings.max_log_entries]
            self._write_history(trimmed_history)


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()
