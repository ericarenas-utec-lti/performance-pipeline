<#
.SYNOPSIS
    Pipeline completo de pruebas de rendimiento JMeter con reportes HTML
#>

Write-Host "=== PIPELINE DE PRUEBAS DE RENDIMIENTO JMETER ===" -ForegroundColor Cyan
Write-Host "📊 Configuración: 50 usuarios, 2min ramp-up, 5min duración" -ForegroundColor Yellow

Write-Host "=== PIPELINE DE PRUEBAS DE RENDIMIENTO JMETER ===" -ForegroundColor Cyan

# 1. Limpiar entorno
Write-Host "`n1. PREPARANDO ENTORNO..." -ForegroundColor Yellow
Remove-Item -Path "results" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "results" -Force | Out-Null
docker-compose down

# 2. Ejecutar JMeter con reporte HTML
Write-Host "2. EJECUTANDO PRUEBAS Y GENERANDO REPORTE HTML..." -ForegroundColor Yellow
docker-compose up

# 3. Verificar resultados JMeter
Write-Host "`n3. ANALIZANDO RESULTADOS..." -ForegroundColor Yellow
if (Test-Path "results/results.jtl") {
    $fileInfo = Get-Item "results/results.jtl"
    Write-Host "✅ Archivo de resultados: $($fileInfo.Length) bytes" -ForegroundColor Green
} else {
    Write-Host "❌ No se generó archivo de resultados" -ForegroundColor Red
    exit 1
}

# 4. Verificar reporte HTML
Write-Host "`n4. VERIFICANDO REPORTE HTML..." -ForegroundColor Yellow
if (Test-Path "results/html-report/index.html") {
    Write-Host "✅ Reporte HTML generado correctamente" -ForegroundColor Green
    Write-Host "   📊 Disponible en: results/html-report/index.html" -ForegroundColor Gray
} else {
    Write-Host "⚠️  No se generó reporte HTML" -ForegroundColor Yellow
}

# 5. Verificar umbrales
Write-Host "`n5. VERIFICANDO UMBRALES DE CALIDAD..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -Command "& { . .\config\check-thresholds.ps1 'results/results.jtl' }"

$thresholdExitCode = $LASTEXITCODE

# 6. Resultado final
Write-Host "`n" + "="*50 -ForegroundColor Cyan
if ($thresholdExitCode -eq 0) {
    Write-Host "🎉 PIPELINE COMPLETADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host "`n📁 ARTEFACTOS GENERADOS:" -ForegroundColor Yellow
    Get-ChildItem "results" -Recurse | Format-Table Name, Length -AutoSize
    
    Write-Host "`n🌐 PARA VER EL REPORTE HTML:" -ForegroundColor Cyan
    Write-Host "   Abre en tu navegador: results/html-report/index.html" -ForegroundColor White
} else {
    Write-Host "❌ PIPELINE FALLÓ - No se cumplen los umbrales" -ForegroundColor Red
    exit 1
}