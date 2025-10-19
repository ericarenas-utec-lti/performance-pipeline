Write-Host "=== EJECUTANDO PRUEBAS JMETER ===" -ForegroundColor Cyan

# Limpiar resultados
if (Test-Path "results") { Remove-Item -Path "results" -Recurse -Force }
New-Item -ItemType Directory -Path "results" -Force | Out-Null

Write-Host "Ejecutando JMeter..." -ForegroundColor Yellow
docker run --rm `
  -v "${PWD}\test-plans:/test-plans" `
  -v "${PWD}\results:/results" `
  -v "${PWD}\config:/config" `
  justb4/jmeter:5.5 `
  -n -t /test-plans/api-performance.jmx `
  -l /results/results.jtl `
  -e -o /results/html-report `
  -Jthreads=5 `
  -Jrampup=10 `
  -Jduration=30

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ JMeter completado" -ForegroundColor Green
    Write-Host "Verificando umbrales..." -ForegroundColor Yellow
    docker run --rm `
      -v "${PWD}\results:/results" `
      -v "${PWD}\config:/config" `
      justb4/jmeter:5.5 `
      /bin/sh -c "/config/check-thresholds.sh /results/results.jtl"
} else {
    Write-Host "❌ JMeter falló" -ForegroundColor Red
}