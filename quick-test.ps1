<#
.SYNOPSIS
    Prueba rápida de JMeter sin verificación de umbrales
.EXAMPLE
    .\quick-test.ps1
#>

Write-Host "=== PRUEBA RÁPIDA JMETER ===" -ForegroundColor Cyan

Remove-Item -Path "results" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "results" -Force | Out-Null

Write-Host "Ejecutando prueba rápida..." -ForegroundColor Yellow
docker run --rm `
  -v "${PWD}\test-plans:/test-plans" `
  -v "${PWD}\results:/results" `
  justb4/jmeter:5.5 `
  -n -t /test-plans/api-performance.jmx `
  -l /results/results.jtl `
  -Jthreads=2 `
  -Jrampup=5 `
  -Jduration=15

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Prueba completada" -ForegroundColor Green
    Get-ChildItem "results"
} else {
    Write-Host "❌ Prueba falló" -ForegroundColor Red
}