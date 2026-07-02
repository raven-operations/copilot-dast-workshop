# Elimina contenedores, redes y volumenes creados por el laboratorio.

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Set-Location $ProjectDir

Write-Host "[cleanup] Eliminando contenedores, redes y volumenes..."
docker compose down -v --remove-orphans

Write-Host "[cleanup] Laboratorio limpio."
