# Ejecuta un escaneo DAST (baseline por defecto) con OWASP ZAP contra
# la instancia local de Juice Shop.
#
# Uso:
#   ./scripts/scan.ps1              # baseline (rapido, pasivo)
#   ./scripts/scan.ps1 full         # full scan (activo, mas lento)

param(
    [ValidateSet("baseline", "full")]
    [string]$Mode = "baseline"
)

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Set-Location $ProjectDir

Write-Host "[scan] Verificando que juice-shop este corriendo..."
$running = docker compose ps --status running --services
if ($running -notcontains "juice-shop") {
    Write-Host "[scan] juice-shop no esta activo. Levantandolo..."
    docker compose up -d juice-shop
}

New-Item -ItemType Directory -Force -Path "reports" | Out-Null

switch ($Mode) {
    "baseline" {
        Write-Host "[scan] Ejecutando ZAP baseline scan..."
        docker compose --profile scan run --rm zap `
            zap-baseline.py `
            -t http://juice-shop:3000 `
            -c /zap/config/rules.tsv `
            -r zap-baseline-report.html `
            -J zap-baseline-report.json `
            -w zap-baseline-report.md `
            -I
    }
    "full" {
        Write-Host "[scan] Ejecutando ZAP full scan (esto puede tardar 10-30 min)..."
        docker compose --profile scan run --rm zap `
            zap-full-scan.py `
            -t http://juice-shop:3000 `
            -c /zap/config/rules.tsv `
            -r zap-full-report.html `
            -J zap-full-report.json `
            -w zap-full-report.md `
            -I
    }
}

Write-Host ""
Write-Host "[scan] Reportes disponibles en: $ProjectDir\reports\"
Get-ChildItem -Path "reports" | ForEach-Object { Write-Host "  - $($_.Name)" }
