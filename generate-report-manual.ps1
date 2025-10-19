Write-Host "=== GENERACIÓN MANUAL DE REPORTE HTML ===" -ForegroundColor Cyan

# 1. Primero generar solo el JTL
Remove-Item -Path "results" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "results" -Force | Out-Null

Write-Host "1. Generando archivo de resultados..." -ForegroundColor Yellow
docker run --rm `
  -v "${PWD}\test-plans:/test-plans" `
  -v "${PWD}\results:/results" `
  justb4/jmeter:5.5 `
  -n -t /test-plans/api-performance.jmx `
  -l /results/results.jtl `
  -Jthreads=5 `
  -Jrampup=10 `
  -Jduration=30

if (-not (Test-Path "results/results.jtl")) {
    Write-Host "❌ No se generó results.jtl" -ForegroundColor Red
    exit 1
}

# 2. Generar reporte HTML desde el JTL
Write-Host "2. Generando reporte HTML desde resultados..." -ForegroundColor Yellow
docker run --rm `
  -v "${PWD}\results:/results" `
  justb4/jmeter:5.5 `
  -g /results/results.jtl `
  -o /results/html-report

if (Test-Path "results/html-report/index.html") {
    $reportPath = Resolve-Path "results/html-report/index.html"
    Write-Host "✅ Reporte HTML generado!" -ForegroundColor Green
    Write-Host "📊 Abriendo: $reportPath" -ForegroundColor Gray
    
    # Abrir en navegador
    Start-Process "results\html-report\index.html"
} else {
    Write-Host "❌ Falló la generación del reporte HTML" -ForegroundColor Red
}