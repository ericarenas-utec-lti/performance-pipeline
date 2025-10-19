#!/bin/bash

# Script para verificar umbrales de rendimiento
# Usage: ./check-thresholds.sh <results_file.jtl>

RESULTS_FILE=$1
THRESHOLDS_FILE="/config/test.properties"

echo "=== Verificando Umbrales de Rendimiento ==="
echo "Archivo de resultados: $RESULTS_FILE"

# Cargar propiedades de umbrales
source $THRESHOLDS_FILE

echo "Umbral P95: ${p95_threshold}ms"
echo "Umbral Tasa de Error: ${error_rate_threshold}%"

# Verificar si el archivo de resultados existe
if [ ! -f "$RESULTS_FILE" ]; then
    echo "ERROR: Archivo de resultados no encontrado: $RESULTS_FILE"
    exit 1
fi

# Analizar resultados JTL usando awk para procesar XML
TOTAL_REQUESTS=$(grep -c '<httpSample' "$RESULTS_FILE")
ERROR_REQUESTS=$(grep '<httpSample' "$RESULTS_FILE" | grep -c 's="false"')

if [ $TOTAL_REQUESTS -eq 0 ]; then
    echo "ERROR: No hay requests en el archivo de resultados"
    exit 1
fi

# Calcular tasa de error
ERROR_RATE=$(echo "scale=2; ($ERROR_REQUESTS / $TOTAL_REQUESTS) * 100" | bc)

# Extraer tiempos de respuesta y calcular P95
grep 't="' "$RESULTS_FILE" | sed 's/.*t="\([^"]*\)".*/\1/' | sort -n > /tmp/response_times.txt
TOTAL_LINES=$(wc -l < /tmp/response_times.txt)
P95_INDEX=$((TOTAL_LINES * 95 / 100))
P95_RESPONSE_TIME=$(sed -n "${P95_INDEX}p" /tmp/response_times.txt)

# Limpiar archivo temporal
rm -f /tmp/response_times.txt

echo "=== Resultados Obtenidos ==="
echo "Total de requests: $TOTAL_REQUESTS"
echo "Requests con error: $ERROR_REQUESTS"
echo "Tasa de error: $ERROR_RATE%"
echo "P95 Response Time: ${P95_RESPONSE_TIME}ms"

# Verificar umbrales
FAILED=false

# Verificar P95
if [ $(echo "$P95_RESPONSE_TIME > $p95_threshold" | bc) -eq 1 ]; then
    echo "❌ FAIL: P95 Response Time ($P95_RESPONSE_TIME ms) excede el umbral ($p95_threshold ms)"
    FAILED=true
else
    echo "✅ PASS: P95 Response Time dentro del umbral"
fi

# Verificar tasa de error
if [ $(echo "$ERROR_RATE > $error_rate_threshold" | bc) -eq 1 ]; then
    echo "❌ FAIL: Error Rate ($ERROR_RATE%) excede el umbral ($error_rate_threshold%)"
    FAILED=true
else
    echo "✅ PASS: Error Rate dentro del umbral"
fi

# Salir con código de error si algún umbral falla
if [ "$FAILED" = true ]; then
    echo "=== RESULTADO FINAL: FALLÓ ==="
    exit 1
else
    echo "=== RESULTADO FINAL: APROBÓ ==="
    exit 0
fi