# Detiene los contenedores del laboratorio sin eliminar redes ni volumenes.

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Set-Location $ProjectDir

Write-Host "[stop] Deteniendo contenedores..."
docker compose stop

Write-Host "[stop] Estado actual:"
docker compose ps
