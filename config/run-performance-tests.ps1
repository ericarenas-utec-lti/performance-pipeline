# Script completo para ejecutar pruebas de rendimiento en Windows
param(
    [int]$Threads = 50,
    [int]$Rampup = 120,
    [int]$Duration = 300
)

Write-Host "=== Iniciando Pruebas de Rendimiento ===" -ForegroundColor Green

# Verificar que Docker esté funcionando
try {
    $dockerVersion = docker --version
    Write-Host "Docker detectado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker no está disponible. Por favor inicia Docker Desktop." -ForegroundColor Red
    exit 1
}

# Verificar que la imagen JMeter existe
Write-Host "Verificando imagen JMeter..." -ForegroundColor Yellow
$imageExists = docker images --format "table {{.Repository}}:{{.Tag}}" | Select-String "apache/jmeter:5.6.3"

if (-not $imageExists) {
    Write-Host "Descargando imagen JMeter oficial..." -ForegroundColor Yellow
    docker pull apache/jmeter:5.6.3
}

# Crear directorios si no existen
$directories = @("test-plans", "config", "results")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
        Write-Host "Directorio creado: $dir" -ForegroundColor Green
    }
}

# Verificar archivos esenciales
$essentialFiles = @(
    "test-plans/api-performance.jmx",
    "config/test.properties",
    "config/check-thresholds.ps1"
)

foreach ($file in $essentialFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "ADVERTENCIA: Archivo no encontrado: $file" -ForegroundColor Yellow
    }
}

# Ejecutar pruebas JMeter
Write-Host "Ejecutando pruebas de rendimiento..." -ForegroundColor Cyan

docker run --rm `
  -v "${PWD}/test-plans:/test-plans" `
  -v "${PWD}/results:/results" `
  -v "${PWD}/config:/config" `
  apache/jmeter:5.6.3 `
  -n -t /test-plans/api-performance.jmx `
  -p /config/test.properties `
  -q /test-plans/user.properties `
  -l /results/results.jtl `
  -e -o /results/html-report `
  -Jthreads=$Threads -Jrampup=$Rampup -Jduration=$Duration

# Verificar si las pruebas se completaron
if ($LASTEXITCODE -eq 0) {
    Write-Host "Pruebas JMeter completadas exitosamente" -ForegroundColor Green
    
    # Verificar umbrales
    Write-Host "Verificando umbrales de rendimiento..." -ForegroundColor Cyan
    .\config\check-thresholds.ps1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ TODAS LAS PRUEBAS APROBARON" -ForegroundColor Green
        Write-Host "Reporte HTML disponible en: results/html-report/index.html" -ForegroundColor Yellow
    } else {
        Write-Host "❌ ALGUNAS PRUEBAS FALLARON" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: Las pruebas JMeter fallaron" -ForegroundColor Red
    exit 1
}