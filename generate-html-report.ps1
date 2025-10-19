Write-Host "=== GENERANDO REPORTE HTML ===" -ForegroundColor Cyan

# Limpiar resultados anteriores
Remove-Item -Path "results" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "results" -Force | Out-Null

Write-Host "1. Ejecutando JMeter y generando reporte HTML..." -ForegroundColor Yellow
docker-compose up

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error ejecutando JMeter" -ForegroundColor Red
    exit 1
}

Write-Host "2. Verificando reporte HTML..." -ForegroundColor Yellow

if (Test-Path "results/html-report/index.html") {
    $reportPath = Resolve-Path "results/html-report/index.html"
    Write-Host "✅ Reporte HTML generado exitosamente!" -ForegroundColor Green
    Write-Host "📊 Archivo: $reportPath" -ForegroundColor Gray
    
    # Mostrar contenido del reporte
    Write-Host "`n📁 Contenido del reporte:" -ForegroundColor Yellow
    Get-ChildItem "results/html-report" -Recurse | Select-Object Name, Length | Format-Table -AutoSize
    
    # Intentar abrir en el navegador
    Write-Host "`n🌐 Abriendo en el navegador..." -ForegroundColor Cyan
    try {
        Start-Process "chrome.exe" "file://$reportPath"
        Write-Host "✅ Abierto en Chrome" -ForegroundColor Green
    } catch {
        try {
            Start-Process "msedge.exe" "file://$reportPath"  
            Write-Host "✅ Abierto en Edge" -ForegroundColor Green
        } catch {
            Write-Host "📧 Para ver el reporte manualmente:" -ForegroundColor Yellow
            Write-Host "   Abre este archivo en tu navegador: results\html-report\index.html" -ForegroundColor White
        }
    }
} else {
    Write-Host "❌ No se generó el reporte HTML" -ForegroundColor Red
    Write-Host "📁 Contenido de results/:" -ForegroundColor Yellow
    Get-ChildItem "results" -Recurse
}