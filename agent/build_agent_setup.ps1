param(
  [string]$PythonCommand = "python",
  [string]$InnoSetupCompiler,
  [string]$AppVersion = "1.0.0",
  [switch]$SkipAgentBuild
)

$ErrorActionPreference = "Stop"
$agentRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $agentRoot

if (-not $SkipAgentBuild) {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $agentRoot "build_agent.ps1") -PythonCommand $PythonCommand
  if ($LASTEXITCODE -ne 0) {
    throw "Agent packaging failed before the installer step."
  }
}

$distDir = Join-Path $agentRoot "dist"
$installerScript = Join-Path $agentRoot "installer\controlix-agent.iss"
$outputDir = Join-Path $agentRoot "installer-output"

$requiredFiles = @(
  (Join-Path $distDir "controlix-agent.exe"),
  (Join-Path $distDir ".env.example"),
  (Join-Path $distDir "data\tasks.json"),
  (Join-Path $distDir "data\execution_logs.json"),
  $installerScript
)

$missingFiles = $requiredFiles | Where-Object { -not (Test-Path $_) }
if ($missingFiles.Count -gt 0) {
  throw "Installer prerequisites are missing:`n - $($missingFiles -join "`n - ")"
}

New-Item -ItemType Directory -Force $outputDir | Out-Null

$compilerCandidates = @()
if ($InnoSetupCompiler) {
  $compilerCandidates += $InnoSetupCompiler
}

$commandCompiler = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
if ($commandCompiler) {
  $compilerCandidates += $commandCompiler.Source
}

$commandCompilerLower = Get-Command "iscc.exe" -ErrorAction SilentlyContinue
if ($commandCompilerLower) {
  $compilerCandidates += $commandCompilerLower.Source
}

$compilerCandidates += @(
  (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe"),
  (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe")
)

$compiler = $compilerCandidates |
  Where-Object { $_ -and (Test-Path $_) } |
  Select-Object -First 1

if (-not $compiler) {
  throw "Inno Setup compiler not found. Install Inno Setup 6 or pass -InnoSetupCompiler with the full path to ISCC.exe."
}

$normalizedAgentRoot = (Resolve-Path $agentRoot).Path
$normalizedOutputDir = (Resolve-Path $outputDir).Path

& $compiler `
  $installerScript `
  "/DSourceRoot=$normalizedAgentRoot" `
  "/DOutputDir=$normalizedOutputDir" `
  "/DMyAppVersion=$AppVersion"

if ($LASTEXITCODE -ne 0) {
  throw "Inno Setup compilation failed."
}

Write-Host ""
Write-Host "Installer executable created:"
Write-Host "  $outputDir\controlix-agent-setup.exe"
Write-Host ""
Write-Host "Install behavior:"
Write-Host "  - Per-user install under LocalAppData\Programs\Controlix Agent"
Write-Host "  - Creates .env from .env.example on first install"
Write-Host "  - Preserves .env and data files on reinstall/uninstall"
