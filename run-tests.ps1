# Crear el archivo run-tests.ps1
@'
<#
.SYNOPSIS
    Script para ejecutar pruebas de rendimiento JMeter en Windows
.DESCRIPTION
    Este script automatiza la ejecución de pruebas JMeter usando Docker
#>

param(
    [int]$Threads = 50,
    [int]$Rampup = 120, 
    [int]$Duration = 300,
    [string]$HostUrl = "https://httpbin.org"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   PRUEBAS DE RENDIMIENTO AUTOMATIZADAS   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Función para mostrar mensajes de error
function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

# Función para mostrar mensajes de éxito
function Write-SuccessMsg {
    param([string]$Message)
    Write-Host "OK: $Message" -ForegroundColor Green
}

# 1. Verificar Docker
Write-Host "`n[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-SuccessMsg "Docker detectado: $dockerVersion"
} catch {
    Write-ErrorMsg "Docker no está disponible. Instala Docker Desktop"
    exit 1
}

# Verificar que Docker esté ejecutándose
try {
    docker ps > $null
    Write-SuccessMsg "Docker Desktop está ejecutándose"
} catch {
    Write-ErrorMsg "Docker Desktop no está ejecutándose"
    exit 1
}

# 2. Verificar y descargar imagen JMeter
Write-Host "`n[2/5] Configurando imagen JMeter..." -ForegroundColor Yellow
$JMETER_IMAGE = "justb4/jmeter:5.6.3"

# Verificar si la imagen existe localmente
$localImage = docker images --quiet $JMETER_IMAGE

if (-not $localImage) {
    Write-Host "Descargando imagen JMeter..." -ForegroundColor Yellow
    try {
        docker pull $JMETER_IMAGE
        Write-SuccessMsg "Imagen JMeter descargada"
    } catch {
        Write-ErrorMsg "No se pudo descargar la imagen JMeter"
        exit 1
    }
} else {
    Write-SuccessMsg "Imagen JMeter encontrada"
}

# 3. Verificar archivos de prueba
Write-Host "`n[3/5] Verificando archivos de prueba..." -ForegroundColor Yellow

if (-not (Test-Path "test-plans/api-performance.jmx")) {
    Write-ErrorMsg "No se encuentra test-plans/api-performance.jmx"
    Write-Host "Creando archivo básico de JMeter..." -ForegroundColor Yellow
    # Crearemos un archivo JMX básico
    @'
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Test Plan" enabled="true">
      <stringProp name="TestPlan.comments"></stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.tearDown_on_shutdown">true</boolProp>
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments" guiclass="ArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
        <collectionProp name="Arguments.arguments">
          <elementProp name="threads" elementType="Argument">
            <stringProp name="Argument.name">threads</stringProp>
            <stringProp name="Argument.value">50</stringProp>
          </elementProp>
          <elementProp name="rampup" elementType="Argument">
            <stringProp name="Argument.name">rampup</stringProp>
            <stringProp name="Argument.value">120</stringProp>
          </elementProp>
        </collectionProp>
      </elementProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Thread Group" enabled="true">
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController" guiclass="LoopControlPanel" testclass="LoopController" testname="Loop Controller" enabled="true">
          <boolProp name="LoopController.continue_forever">false</boolProp>
          <stringProp name="LoopController.loops">-1</stringProp>
        </elementProp>
        <stringProp name="ThreadGroup.num_threads">50</stringProp>
        <stringProp name="ThreadGroup.ramp_time">120</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
      </ThreadGroup>
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="HTTP Request" enabled="true">
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
            <collectionProp name="Arguments.arguments"/>
          </elementProp>
          <stringProp name="HTTPSampler.domain">httpbin.org</stringProp>
          <stringProp name="HTTPSampler.port"></stringProp>
          <stringProp name="HTTPSampler.protocol">https</stringProp>
          <stringProp name="HTTPSampler.contentEncoding"></stringProp>
          <stringProp name="HTTPSampler.path">/get</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
          <boolProp name="HTTPSampler.follow_redirects">true</boolProp>
          <boolProp name="HTTPSampler.auto_redirects">false</boolProp>
          <boolProp name="HTTPSampler.use_keepalive">true</boolProp>
          <boolProp name="HTTPSampler.DO_MULTIPART_POST">false</boolProp>
        </HTTPSamplerProxy>
        <hashTree/>
        <ResultCollector guiclass="TableVisualizer" testclass="ResultCollector" testname="View Results in Table" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>true</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <sentBytes>true</sentBytes>
              <url>true</url>
              <threadCounts>true</threadCounts>
              <idleTime>true</idleTime>
            </value>
          </objProp>
          <stringProp name="filename"></stringProp>
        </ResultCollector>
        <hashTree/>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
'@ | Out-File -FilePath "test-plans/api-performance.jmx" -Encoding UTF8
    Write-SuccessMsg "Archivo JMX básico creado"

# 4. Crear archivos de configuración
Write-Host "`n[4/5] Creando archivos de configuración..." -ForegroundColor Yellow

# Crear test.properties si no existe
if (-not (Test-Path "config/test.properties")) {
    @"
# JMeter Test Properties
threads=50
rampup=120
duration=300
host=https://httpbin.org

# Threshold configurations  
p95_threshold=500
error_rate_threshold=1.0
"@ | Out-File -FilePath "config/test.properties" -Encoding UTF8
    Write-SuccessMsg "config/test.properties creado"
}

# 5. Ejecutar pruebas JMeter
Write-Host "`n[5/5] Ejecutando pruebas de rendimiento..." -ForegroundColor Cyan

Write-Host "Parámetros:" -ForegroundColor White
Write-Host "  - Usuarios: $Threads" -ForegroundColor White
Write-Host "  - Ramp-up: $Rampup segundos" -ForegroundColor White
Write-Host "  - Duración: $Duration segundos" -ForegroundColor White

# Limpiar resultados anteriores
if (Test-Path "results") {
    Remove-Item -Path "results\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`nIniciando JMeter en Docker..." -ForegroundColor Yellow

$jmeterCommand = @"
jmeter -n -t /test-plans/api-performance.jmx \
  -p /config/test.properties \
  -l /results/results.jtl \
  -e -o /results/html-report \
  -Jthreads=$Threads \
  -Jrampup=$Rampup \
  -Jduration=$Duration
"@

Write-Host "Comando: $jmeterCommand" -ForegroundColor Gray

docker run --rm `
  -v "${PWD}/test-plans:/test-plans" `
  -v "${PWD}/results:/results" `
  -v "${PWD}/config:/config" `
  $JMETER_IMAGE `
  /bin/sh -c "$jmeterCommand"

# Verificar resultado
if ($LASTEXITCODE -eq 0) {
    Write-SuccessMsg "Pruebas JMeter completadas"
    
    # Verificar archivos generados
    if (Test-Path "results/results.jtl") {
        Write-SuccessMsg "Resultados: results/results.jtl"
    } else {
        Write-ErrorMsg "No se generó results.jtl"
    }
    
    if (Test-Path "results/html-report/index.html") {
        Write-SuccessMsg "Reporte HTML: results/html-report/index.html"
    }
    
    Write-Host "`n🎉 PRUEBAS COMPLETADAS EXITOSAMENTE" -ForegroundColor Green
    Write-Host "Puedes ver el reporte en: results/html-report/index.html" -ForegroundColor Yellow
    
} else {
    Write-ErrorMsg "Las pruebas JMeter fallaron"
    exit 1
}