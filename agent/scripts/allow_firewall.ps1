param(
  [int]$Port = 8765,
  [string]$RuleName = ""
)

$ErrorActionPreference = "Stop"

if (-not $RuleName) {
  $RuleName = "Controlix Agent (TCP $Port)"
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run this script in an elevated PowerShell (Run as Administrator)."
  exit 1
}

$existing = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
if ($null -ne $existing) {
  Write-Host "Firewall rule already exists: $RuleName"
  exit 0
}

New-NetFirewallRule `
  -DisplayName $RuleName `
  -Direction Inbound `
  -Action Allow `
  -Protocol TCP `
  -LocalPort $Port `
  -Profile Any | Out-Null

Write-Host "Added firewall rule: $RuleName"
