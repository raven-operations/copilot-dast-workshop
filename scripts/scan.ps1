# Ejecuta un escaneo DAST (baseline por defecto) con OWASP ZAP.
#
# Uso:
#   ./scripts/scan.ps1                                 # baseline vs juice-shop
#   ./scripts/scan.ps1 full                            # full scan vs juice-shop
#   ./scripts/scan.ps1 baseline http://proxy:8080     # baseline vs proxy endurecido
#   ./scripts/scan.ps1 full     http://proxy:8080     # full scan vs proxy endurecido

param(
    [ValidateSet("baseline", "full")]
    [string]$Mode = "baseline",

    [string]$Target = "http://juice-shop:3000"
)

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Set-Location $ProjectDir

# Slug del target para nombrar los reportes.
$TargetSlug = ($Target -replace '^https?://', '') -replace '[/:]', '_'
$TargetSlug = $TargetSlug.TrimEnd('_')
$ReportBase = "zap-$Mode-$TargetSlug"

Write-Host "[scan] Verificando que juice-shop este corriendo..."
$running = docker compose ps --status running --services
if ($running -notcontains "juice-shop") {
    Write-Host "[scan] juice-shop no esta activo. Levantandolo..."
    docker compose up -d juice-shop
}

if ($Target -match "proxy") {
    $running = docker compose ps --status running --services
    if ($running -notcontains "proxy") {
        Write-Host "[scan] proxy no esta activo. Levantandolo (profile hardened)..."
        docker compose --profile hardened up -d proxy
    }
}

New-Item -ItemType Directory -Force -Path "reports" | Out-Null

switch ($Mode) {
    "baseline" {
        Write-Host "[scan] Ejecutando ZAP baseline scan contra $Target..."
        docker compose --profile scan run --rm zap `
            zap-baseline.py `
            -t $Target `
            -c /zap/config/rules.tsv `
            -r "$ReportBase.html" `
            -J "$ReportBase.json" `
            -w "$ReportBase.md" `
            -I
    }
    "full" {
        Write-Host "[scan] Ejecutando ZAP full scan contra $Target (puede tardar 10-30 min)..."
        docker compose --profile scan run --rm zap `
            zap-full-scan.py `
            -t $Target `
            -c /zap/config/rules.tsv `
            -r "$ReportBase.html" `
            -J "$ReportBase.json" `
            -w "$ReportBase.md" `
            -I
    }
}

Write-Host ""
Write-Host "[scan] Reportes disponibles en: $ProjectDir\reports\"
Get-ChildItem -Path "reports" | ForEach-Object { Write-Host "  - $($_.Name)" }
