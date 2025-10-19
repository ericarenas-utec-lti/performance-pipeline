# Script para verificar umbrales de rendimiento en Windows
param(
    [string]$ResultsFile = "results/results.jtl",
    [string]$ThresholdsFile = "config/test.properties"
)

function Load-Properties {
    param([string]$filePath)
    $properties = @{}
    if (Test-Path $filePath) {
        Get-Content $filePath | ForEach-Object {
            if ($_ -match '^([^=]+)=(.+)$') {
                $properties[$matches[1].Trim()] = $matches[2].Trim()
            }
        }
    }
    return $properties
}

Write-Host "=== Verificando Umbrales de Rendimiento ===" -ForegroundColor Cyan
Write-Host "Archivo de resultados: $ResultsFile"

# Cargar propiedades de umbrales
$thresholds = Load-Properties $ThresholdsFile

$p95_threshold = [int]$thresholds['p95_threshold']
$error_rate_threshold = [double]$thresholds['error_rate_threshold']

Write-Host "Umbral P95: ${p95_threshold}ms" -ForegroundColor Yellow
Write-Host "Umbral Tasa de Error: ${error_rate_threshold}%" -ForegroundColor Yellow

# Verificar si el archivo de resultados existe
if (-not (Test-Path $ResultsFile)) {
    Write-Host "ERROR: Archivo de resultados no encontrado: $ResultsFile" -ForegroundColor Red
    Write-Host "Ejecuta primero las pruebas JMeter" -ForegroundColor Yellow
    exit 1
}

try {
    # Analizar resultados JTL (XML)
    [xml]$xmlContent = Get-Content $ResultsFile
    $httpSamples = $xmlContent.testResults.httpSample

    $TOTAL_REQUESTS = $httpSamples.Count
    $ERROR_REQUESTS = 0
    $responseTimes = @()

    foreach ($sample in $httpSamples) {
        if ($sample.s -eq 'false') {
            $ERROR_REQUESTS++
        }
        $responseTimes += [int]$sample.t
    }

    # Calcular métricas
    if ($TOTAL_REQUESTS -gt 0) {
        $ERROR_RATE = ($ERROR_REQUESTS / $TOTAL_REQUESTS) * 100
    } else {
        $ERROR_RATE = 0
    }

    # Calcular percentil 95
    if ($responseTimes.Count -gt 0) {
        $sortedTimes = $responseTimes | Sort-Object
        $p95_index = [math]::Ceiling($sortedTimes.Count * 0.95) - 1
        if ($p95_index -lt $sortedTimes.Count) {
            $P95_RESPONSE_TIME = $sortedTimes[$p95_index]
        } else {
            $P95_RESPONSE_TIME = $sortedTimes[-1]
        }
    } else {
        $P95_RESPONSE_TIME = 0
    }

    Write-Host "`n=== Resultados Obtenidos ===" -ForegroundColor Cyan
    Write-Host "Total de requests: $TOTAL_REQUESTS" -ForegroundColor White
    Write-Host "Requests con error: $ERROR_REQUESTS" -ForegroundColor White
    Write-Host "Tasa de error: $([math]::Round($ERROR_RATE, 2))%" -ForegroundColor White
    Write-Host "P95 Response Time: ${P95_RESPONSE_TIME}ms" -ForegroundColor White

    # Verificar umbrales
    $FAILED = $false

    # Verificar P95
    if ($P95_RESPONSE_TIME -gt $p95_threshold) {
        Write-Host "❌ FAIL: P95 Response Time ($P95_RESPONSE_TIME ms) excede el umbral ($p95_threshold ms)" -ForegroundColor Red
        $FAILED = $true
    } else {
        Write-Host "✅ PASS: P95 Response Time dentro del umbral" -ForegroundColor Green
    }

    # Verificar tasa de error
    if ($ERROR_RATE -gt $error_rate_threshold) {
        Write-Host "❌ FAIL: Error Rate ($([math]::Round($ERROR_RATE, 2))%) excede el umbral ($error_rate_threshold%)" -ForegroundColor Red
        $FAILED = $true
    } else {
        Write-Host "✅ PASS: Error Rate dentro del umbral" -ForegroundColor Green
    }

    # Salir con código de error si algún umbral falla
    if ($FAILED) {
        Write-Host "`n=== RESULTADO FINAL: FALLÓ ===" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "`n=== RESULTADO FINAL: APROBÓ ===" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "ERROR: No se pudo procesar el archivo de resultados: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}