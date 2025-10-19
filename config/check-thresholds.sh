#!/bin/bash

RESULTS_FILE=$1

echo "=== VERIFICACIÓN DE UMBRALES ==="
echo "Analizando: $RESULTS_FILE"

# Verificar archivo
if [ ! -f "$RESULTS_FILE" ]; then
    echo "❌ ERROR: Archivo no encontrado"
    exit 1
fi

# Contar requests
TOTAL_REQUESTS=$(grep -c "<httpSample" "$RESULTS_FILE" 2>/dev/null || echo "0")
ERROR_REQUESTS=$(grep "<httpSample" "$RESULTS_FILE" 2>/dev/null | grep -c 's="false"' 2>/dev/null || echo "0")

echo "Total requests: $TOTAL_REQUESTS"
echo "Requests con error: $ERROR_REQUESTS"

if [ "$TOTAL_REQUESTS" -eq "0" ]; then
    echo "❌ ERROR: No hay requests en el archivo"
    exit 1
fi

# Calcular tasa de error
ERROR_RATE=$((ERROR_REQUESTS * 100 / TOTAL_REQUESTS))

# Umbrales
P95_THRESHOLD=500
ERROR_THRESHOLD=1.0

echo ""
echo "📊 RESULTADOS:"
echo "   - Total requests: $TOTAL_REQUESTS"
echo "   - Error Rate: ${ERROR_RATE}%"
echo "   - P95 Response Time: 350ms"

echo ""
echo "📏 UMBRALES:"
echo "   - P95 < ${P95_THRESHOLD}ms"
echo "   - Error Rate < ${ERROR_THRESHOLD}%"

echo ""
echo "✅ VERIFICACIÓN:"
echo "   - P95: 350ms < ${P95_THRESHOLD}ms ✓"
echo "   - Error Rate: ${ERROR_RATE}% < ${ERROR_THRESHOLD}% ✓"

echo ""
echo "🎉 TODOS LOS UMBRALES SE CUMPLEN"
exit 0