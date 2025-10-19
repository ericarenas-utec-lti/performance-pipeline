param(
    [string]$JtlFile = "results/results.jtl"
)

Write-Output "=== VERIFICACIÓN DE UMBRALES ==="

if (-not (Test-Path $JtlFile)) {
    Write-Error "❌ ERROR: Archivo no encontrado: $JtlFile"
    exit 1
}

# Leer archivo
$lines = Get-Content $JtlFile
Write-Output "Archivo: $JtlFile ($($lines.Length) líneas)"

# Procesar datos (saltar header)
$data = $lines | Select-Object -Skip 1
$totalRequests = $data.Count
$errorRequests = 0
$responseTimes = @()

foreach ($line in $data) {
    $fields = $line -split ','
    
    # Campo success (índice 7)
    $success = $fields[7] -eq 'true'
    
    # Campo responseCode (índice 3)  
    $responseCode = $fields[3]
    
    # Campo elapsed (índice 1)
    $elapsed = [int]$fields[1]
    $responseTimes += $elapsed
    
    # Contar errores
    if (-not $success -or $responseCode -match '^[45]') {
        $errorRequests++
    }
}

# Calcular métricas
$errorRate = if ($totalRequests -gt 0) { ($errorRequests / $totalRequests) * 100 } else { 0 }

# Calcular P95
$p95 = 0
if ($responseTimes.Count -gt 0) {
    $sorted = $responseTimes | Sort-Object
    $index = [Math]::Min([Math]::Ceiling($sorted.Count * 0.95) - 1, $sorted.Count - 1)
    $p95 = $sorted[$index]
}

Write-Output ""
Write-Output "📊 RESULTADOS:"
Write-Output "   - Total: $totalRequests requests"
Write-Output "   - Errores: $errorRequests"
Write-Output "   - Error Rate: $([math]::Round($errorRate, 2))%"
Write-Output "   - P95: ${p95}ms"

# Umbrales REALISTAS para 50 usuarios
$P95Threshold = 5000  # 5 segundos
$ErrorRateThreshold = 5  # 5% de tasa de error

Write-Output ""
Write-Output "📏 UMBRALES:"
Write-Output "   - P95 < ${P95Threshold}ms"
Write-Output "   - Error Rate < ${ErrorRateThreshold}%"

Write-Output ""
Write-Output "✅ VERIFICACIÓN:"

$allPassed = $true

if ($p95 -lt $P95Threshold) {
    Write-Output "   - P95: ${p95}ms < ${P95Threshold}ms ✓"
} else {
    Write-Output "   - P95: ${p95}ms >= ${P95Threshold}ms ✗"
    $allPassed = $false
}

if ($errorRate -lt $ErrorRateThreshold) {
    Write-Output "   - Error Rate: $([math]::Round($errorRate, 2))% < ${ErrorRateThreshold}% ✓"
} else {
    Write-Output "   - Error Rate: $([math]::Round($errorRate, 2))% >= ${ErrorRateThreshold}% ✗"
    $allPassed = $false
}

if ($allPassed) {
    Write-Output ""
    Write-Output "✅ TODOS LOS UMBRALES SE CUMPLEN"
    exit 0
} else {
    Write-Output ""
    Write-Output "❌ ALGUNOS UMBRALES NO SE CUMPLEN"
    exit 1
}