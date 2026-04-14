$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

flutter config --enable-windows-desktop | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "Unable to enable Windows desktop support in Flutter."
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
  throw "flutter pub get failed."
}

flutter build windows --release
if ($LASTEXITCODE -ne 0) {
  throw "flutter build windows failed. Install the missing Visual Studio Desktop C++ workload and try again."
}

$outputDir = Join-Path $projectRoot "build\windows\x64\runner\Release"

Write-Host ""
Write-Host "Windows desktop executable created:"
Write-Host "  $outputDir\controlix.exe"
