from __future__ import annotations

import os
import socket
import sys
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = (
    Path(sys.executable).resolve().parent
    if getattr(sys, "frozen", False)
    else Path(__file__).resolve().parent.parent
)
ENV_FILE = BASE_DIR / ".env"
DATA_DIR = BASE_DIR / "data"
TASKS_FILE = DATA_DIR / "tasks.json"
LOGS_FILE = DATA_DIR / "execution_logs.json"
SCRIPTS_DIR = BASE_DIR / "scripts"

if ENV_FILE.exists():
    load_dotenv(ENV_FILE)


@dataclass(frozen=True, slots=True)
class Settings:
    secret_key: str
    host: str
    port: int
    execution_timeout: int
    max_log_entries: int
    machine_name: str
    tasks_file: Path
    logs_file: Path
    scripts_dir: Path


def load_settings() -> Settings:
    secret_key = os.getenv("CONTROLIX_SECRET_KEY", "").strip()
    if not secret_key:
        raise RuntimeError(
            "CONTROLIX_SECRET_KEY is missing. Copy agent/.env.example to agent/.env "
            "and configure a strong shared secret before starting the server."
        )

    DATA_DIR.mkdir(parents=True, exist_ok=True)
    SCRIPTS_DIR.mkdir(parents=True, exist_ok=True)

    return Settings(
        secret_key=secret_key,
        host=os.getenv("CONTROLIX_HOST", "0.0.0.0").strip(),
        port=int(os.getenv("CONTROLIX_PORT", "8765")),
        execution_timeout=int(os.getenv("CONTROLIX_EXECUTION_TIMEOUT", "90")),
        max_log_entries=int(os.getenv("CONTROLIX_MAX_LOG_ENTRIES", "100")),
        machine_name=socket.gethostname(),
        tasks_file=TASKS_FILE,
        logs_file=LOGS_FILE,
        scripts_dir=SCRIPTS_DIR,
    )
