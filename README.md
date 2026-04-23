# Controlix

Controlix is a LAN-only remote control system made of:

- A Flutter mobile client with clean architecture, modern glassmorphism UI, dark/light themes, local config storage, task CRUD, and one-tap execution.
- A Python Flask Windows agent that validates a shared secret, rejects non-LAN traffic, stores tasks in JSON, and executes PowerShell scripts with structured JSON responses.

## Architecture

```text
controlix/
├─ lib/
│  ├─ core/
│  ├─ data/
│  ├─ domain/
│  └─ presentation/
├─ agent/
│  ├─ controlix_agent/
│  │  ├─ routes/
│  │  ├─ services/
│  │  └─ utils/
│  ├─ data/
│  ├─ scripts/
│  ├─ requirements.txt
│  └─ run_agent.py
└─ pubspec.yaml
```

## Features

- Animated splash screen with premium gradient background
- Connection screen with IP address and shared secret persistence
- Responsive dashboard with add, edit, delete, and execute task flows
- Premium AI assistant chat UI (mobile) calling `POST /api/chat`
- Local execution history stored on the mobile device
- Flask REST API with `/health`, `/tasks`, `/execute`, and `/history`
- Shared secret authentication through `X-Controlix-Key`
- LAN-only access enforcement using the client IP address
- PowerShell execution with `subprocess.run(..., shell=False)`

## Flutter setup

1. Install Flutter `3.38.x` or later.
2. From the repository root, install dependencies:

```bash
flutter pub get
```

3. Run the mobile app on a device connected to the same LAN as the Windows machine:

```bash
flutter run
```

## Windows agent setup

1. Install Python `3.11+` on the Windows machine and make sure `python` or `py` is available in PowerShell.
2. Create and activate a virtual environment inside `agent/`:

```powershell
cd agent
python -m venv .venv
.venv\Scripts\Activate.ps1
```

3. Install the backend dependencies:

```powershell
pip install -r requirements.txt
```

4. Copy the sample environment file and define a strong shared secret:

```powershell
Copy-Item .env.example .env
```

5. Edit `agent/.env` and update at least:

```env
CONTROLIX_SECRET_KEY=your-strong-shared-secret
CONTROLIX_HOST=0.0.0.0
CONTROLIX_PORT=8765
CONTROLIX_EXECUTION_TIMEOUT=90
CONTROLIX_MAX_LOG_ENTRIES=100
```

6. Start the Windows agent:

```powershell
python run_agent.py
```

The agent will listen on `http://0.0.0.0:8765` and accept requests from the local network only.

## Mobile connection flow

1. Launch the Flutter app.
2. Enter the Windows machine LAN IP address, for example `192.168.1.24`.
3. Enter the same shared secret configured in `agent/.env`.
4. Tap `Save & connect`.
5. The dashboard will load the seeded tasks from the Windows agent.

## REST API contract

### `GET /health`

Headers:

```http
X-Controlix-Key: your-strong-shared-secret
```

Response:

```json
{
  "success": true,
  "machine_name": "DESKTOP-1234",
  "port": 8765,
  "tasks_count": 3
}
```

### `GET /tasks`

Response:

```json
{
  "success": true,
  "tasks": [
    {
      "id": "restart-explorer",
      "title": "Restart Explorer",
      "description": "Restarts Windows Explorer and refreshes the shell.",
      "script": "Stop-Process -Name explorer -Force; Start-Process explorer.exe",
      "accent_hex": "#7C3AED",
      "icon": "rocket",
      "created_at": "2026-04-14T00:00:00+00:00",
      "updated_at": "2026-04-14T00:00:00+00:00"
    }
  ]
}
```

### `POST /tasks`

Request:

```json
{
  "title": "Open Notepad",
  "description": "Launches Notepad on the Windows machine.",
  "script": "Start-Process notepad.exe",
  "accent_hex": "#2563EB",
  "icon": "desktop"
}
```

### `PUT /tasks/<task_id>`

Same payload as `POST /tasks`, but updates an existing task.

### `DELETE /tasks/<task_id>`

Deletes a task from the Windows agent.

### `POST /execute`

Request:

```json
{
  "task_id": "restart-explorer"
}
```

Response:

```json
{
  "success": true,
  "task_id": "restart-explorer",
  "task_title": "Restart Explorer",
  "output": "",
  "stdout": "",
  "stderr": "",
  "error_code": 0,
  "duration_ms": 918,
  "executed_at": "2026-04-14T09:55:11.241190+00:00"
}
```

### `POST /api/chat`

This endpoint is consumed by the Flutter AI chat screen and must be implemented server-side
(never call OpenAI directly from the mobile app).

Requirements on the agent machine:

- `OPENAI_API_KEY` (OpenAI) or `GEMINI_API_KEY` (Gemini) set in `agent/.env`
- `pip install -r agent/requirements.txt` (includes `openai` for the OpenAI provider)

Request:

```json
{
  "messages": [
    { "role": "user", "content": "Rédige un script PowerShell pour lister les processus." }
  ]
}
```

Response:

```json
{
  "success": true,
  "reply": "…"
}
```

## Security notes

- The agent checks that the client IP is private or loopback before it handles a request.
- Every protected endpoint validates the shared secret.
- PowerShell commands are executed with `shell=False` and `-EncodedCommand` to avoid shell interpolation.
- For extra hardening, use a Windows Firewall rule to restrict inbound access to your LAN subnet only.

## Useful commands

From the repo root:

```bash
flutter pub get
dart format lib test
flutter analyze
```

From `agent/`:

```powershell
pip install -r requirements.txt
python run_agent.py
```

## Build Windows executables

This project can be packaged into two Windows executables:

- `controlix.exe`: the Flutter desktop controller application
- `controlix-agent.exe`: the Windows agent that executes PowerShell tasks

### 1. Build the Flutter Windows desktop `.exe`

Prerequisites:

- Flutter installed
- Visual Studio with the `Desktop development with C++` workload

Build command:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_windows_client.ps1
```

Expected output:

```text
build\windows\x64\runner\Release\controlix.exe
```

### 2. Build the Windows agent `.exe`

Prerequisites:

- Python 3.11+ installed and available in `PATH`

Build command:

```powershell
cd agent
powershell -ExecutionPolicy Bypass -File .\build_agent.ps1
```

Expected output:

```text
agent\dist\controlix-agent.exe
```

The build script also prepares:

- `agent\dist\.env.example`
- `agent\dist\data\tasks.json`
- `agent\dist\data\execution_logs.json`

Before running the packaged agent:

1. Copy `agent\dist\.env.example` to `agent\dist\.env`
2. Set a real `CONTROLIX_SECRET_KEY`
3. Start `controlix-agent.exe`

### 2.1 Build a real Windows installer for the agent

Prerequisites:

- Inno Setup 6 installed on the build machine

Build command:

```powershell
cd agent
powershell -ExecutionPolicy Bypass -File .\build_agent_setup.ps1
```

Expected output:

```text
agent\installer-output\controlix-agent-setup.exe
```

Installer behavior:

- Installs per-user into `%LOCALAPPDATA%\Programs\Controlix Agent`
- Creates `.env` from `.env.example` on first install
- Preserves `.env`, `data\tasks.json`, and `data\execution_logs.json` across reinstalls
- Can create desktop and startup shortcuts

The installer intentionally uses `LocalAppData` instead of `Program Files` because the current agent stores writable runtime files next to the executable.

### 3. Important note

The desktop controller and the Windows agent are separate executables. This matches the current architecture:

- the controller sends HTTP requests
- the agent receives and executes PowerShell commands

If you want, the next step can be to package both into a single Windows installer.
