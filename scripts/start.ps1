# Levanta el laboratorio DAST (OWASP Juice Shop) usando Docker Compose.

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Set-Location $ProjectDir

Write-Host "[start] Levantando OWASP Juice Shop..."
docker compose up -d

Write-Host "[start] Servicios en ejecucion:"
docker compose ps

Write-Host ""
Write-Host "[start] Listo. Abre http://localhost:3000 en tu navegador."
