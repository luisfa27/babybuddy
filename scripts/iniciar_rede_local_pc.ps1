$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$PythonExe = Join-Path $ProjectRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    Write-Host "Ambiente virtual .venv nao encontrado em $ProjectRoot" -ForegroundColor Red
    exit 1
}

$LocalIPs = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Select-Object -ExpandProperty IPAddress

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Baby Buddy Ocean — Rede Local (PC)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Neste PC:              http://127.0.0.1:8000"
foreach ($ip in $LocalIPs) {
    Write-Host "  Android / iPhone / Tablet (Wi-Fi): http://${ip}:8000" -ForegroundColor Green
}
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Obs.: Se o celular nao conectar, libere a porta 8000 no Firewall do Windows." -ForegroundColor Yellow
Write-Host ""

& $PythonExe manage.py runserver 0.0.0.0:8000
