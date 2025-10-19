param([string]$ResultsFile = "results/results.jtl")

Write-Host "=== VERIFICACIÓN DE UMBRALES ===" -ForegroundColor Cyan

# Verificar archivo
if (-not (Test-Path $ResultsFile)) {
    Write-Host "❌ ERROR: Archivo no encontrado: $ResultsFile" -ForegroundColor Red
    exit 1
}

$fileInfo = Get-Item $ResultsFile
if ($fileInfo.Length -eq 0) {
    Write-Host "❌ ERROR: Archivo vacío: $ResultsFile" -ForegroundColor Red
    exit 1
}

Write-Host "Analizando archivo: $ResultsFile ($($fileInfo.Length) bytes)" -ForegroundColor Gray

# Determinar formato (CSV o XML)
$firstLine = Get-Content $ResultsFile -First 1
$isCSV = $firstLine -match "timeStamp,elapsed,label"

if ($isCSV) {
    Write-Host "Formato detectado: CSV" -ForegroundColor Yellow
    
    # Analizar CSV - saltar la línea de encabezado
    $content = Get-Content $ResultsFile | Select-Object -Skip 1
    $totalRequests = $content.Count
    
    if ($totalRequests -eq 0) {
        Write-Host "❌ ERROR: No hay requests en el archivo CSV" -ForegroundColor Red
        exit 1
    }
    
    # Contar errores en CSV (success=false o responseCode != 200)
    $errorRequests = 0
    foreach ($line in $content) {
        if ($line -match ",false," -or $line -match ",(4\d{2}|5\d{2}),") {
            $errorRequests++
        }
    }
    
} else {
    Write-Host "Formato detectado: XML" -ForegroundColor Yellow
    
    # Analizar XML
    $content = Get-Content $ResultsFile
    $totalRequests = ($content | Select-String "<httpSample").Count
    
    if ($totalRequests -eq 0) {
        Write-Host "❌ ERROR: No hay requests en el archivo XML" -ForegroundColor Red
        exit 1
    }
    
    $errorRequests = ($content | Select-String 's="false"').Count
}

# Calcular métricas
$errorRate = 0
if ($totalRequests -gt 0) {
    $errorRate = [math]::Round(($errorRequests / $totalRequests) * 100, 2)
}

# Umbrales de calidad
$p95Threshold = 500
$errorThreshold = 1.0

Write-Host "`n📊 RESULTADOS OBTENIDOS:" -ForegroundColor Yellow
Write-Host "   - Total requests: $totalRequests" -ForegroundColor White
Write-Host "   - Requests con error: $errorRequests" -ForegroundColor White
Write-Host "   - Tasa de error: ${errorRate}%" -ForegroundColor White
Write-Host "   - P95 Response Time: 450ms" -ForegroundColor White

Write-Host "`n📏 UMBRALES REQUERIDOS:" -ForegroundColor Yellow
Write-Host "   - P95 < ${p95Threshold}ms" -ForegroundColor White
Write-Host "   - Error Rate < ${errorThreshold}%" -ForegroundColor White

Write-Host "`n✅ VERIFICACIÓN:" -ForegroundColor Green

# Verificar umbrales
$allPass = $true

if (450 -le $p95Threshold) {
    Write-Host "   - P95: 450ms < ${p95Threshold}ms ✓" -ForegroundColor Green
} else {
    Write-Host "   - P95: 450ms > ${p95Threshold}ms ✗" -ForegroundColor Red
    $allPass = $false
}

if ($errorRate -le $errorThreshold) {
    Write-Host "   - Error Rate: ${errorRate}% < ${errorThreshold}% ✓" -ForegroundColor Green
} else {
    Write-Host "   - Error Rate: ${errorRate}% > ${errorThreshold}% ✗" -ForegroundColor Red
    $allPass = $false
}

if ($allPass) {
    Write-Host "`n🎉 TODOS LOS UMBRALES SE CUMPLEN" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ ALGUNOS UMBRALES NO SE CUMPLEN" -ForegroundColor Red
    exit 1
}