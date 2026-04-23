param(
  [string]$PythonCommand = "python"
)

$ErrorActionPreference = "Stop"
$agentRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $agentRoot

$venvPython = Join-Path $agentRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $venvPython)) {
  & $PythonCommand -m venv .venv
  if ($LASTEXITCODE -ne 0) {
    throw "Unable to create the Python virtual environment. Verify that Python is installed and available in PATH."
  }
}

& $venvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
  throw "pip upgrade failed."
}

& $venvPython -m pip install -r requirements.txt pyinstaller
if ($LASTEXITCODE -ne 0) {
  throw "Dependency installation failed."
}

& $venvPython -m PyInstaller `
  --noconfirm `
  --clean `
  --onefile `
  --name controlix-agent `
  --hidden-import waitress `
  --hidden-import dotenv `
  run_agent.py
if ($LASTEXITCODE -ne 0) {
  throw "PyInstaller packaging failed."
}

$distDir = Join-Path $agentRoot "dist"
$runtimeDataDir = Join-Path $distDir "data"

New-Item -ItemType Directory -Force $runtimeDataDir | Out-Null
Copy-Item (Join-Path $agentRoot ".env.example") (Join-Path $distDir ".env.example") -Force
Copy-Item (Join-Path $agentRoot "data\tasks.json") (Join-Path $runtimeDataDir "tasks.json") -Force
Copy-Item (Join-Path $agentRoot "data\execution_logs.json") (Join-Path $runtimeDataDir "execution_logs.json") -Force

Write-Host ""
Write-Host "Agent executable created:"
Write-Host "  $distDir\controlix-agent.exe"
Write-Host ""
Write-Host "Next step:"
Write-Host "  Copy .env.example to .env next to the exe, then edit CONTROLIX_SECRET_KEY."
