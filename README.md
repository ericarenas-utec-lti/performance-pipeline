# 🚀 Performance Pipeline

Pipeline de pruebas de performance automatizado con JMeter, Docker y reportes HTML.

## 📋 Características

- ✅ Ejecución automatizada de pruebas de carga
- ✅ Configuración para 50 usuarios simultáneos
- ✅ Reportes HTML interactivos
- ✅ Verificación automática de umbrales de performance
- ✅ Entorno containerizado con Docker

## 🛠️ Requisitos Previos

- **Docker Desktop** instalado y ejecutándose
- **Windows 10/11** (para `run.bat`) o adaptar para otros SO
- **Git** para clonar el repositorio

## 🚀 Ejecución Rápida

### Opción 1: Ejecución Automática (Recomendada)

```bash
# Clonar el repositorio
git clone https://github.com/ericarenas-utec-lti/performance-pipeline.git
cd performance-pipeline

# Ejecutar el pipeline completo
run.bat
```

### Opción 2: Ejecución Manual con Docker

```bash
# Limpiar y ejecutar
docker-compose down --remove-orphans
docker-compose up
```

## 📊 Configuración de la Prueba

La prueba está configurada para:

- **Usuarios simultáneos:** 50
- **Ramp-up:** 2 minutos (120 segundos)
- **Duración:** 5 minutos (300 segundos)
- **Endpoint de prueba:** https://httpbin.org/get

### Modificar Configuración

Edita `docker-compose.yml` para cambiar parámetros:

```yaml
command: [
  "-Jthreads=50",      # Número de usuarios
  "-Jrampup=120",      # Tiempo de ramp-up (segundos)
  "-Jduration=300",    # Duración total (segundos)
]
```

## 📈 Resultados y Reportes

### Reporte HTML Interactivo

Al finalizar la ejecución, se abrirá automáticamente:
```
results/html-report/index.html
```

**Contenido del reporte:**
- 📊 Dashboard general
- ⏱️ Tiempos de respuesta
- 📈 Throughput (peticiones/segundo)
- ❌ Análisis de errores
- 📋 Estadísticas detalladas

### Archivos de Resultados

- **`results/results.jtl`**: Datos brutos de JMeter
- **`results/html-report/`**: Reporte HTML completo

### Umbrales de Performance

El pipeline verifica automáticamente:
- **P95 Response Time:** < 5000ms
- **Error Rate:** < 5%

Modifica `config/check-thresholds.ps1` para ajustar umbrales.

## 🗂️ Estructura del Proyecto

```
performance-pipeline/
├── run.bat                          # Script de ejecución principal
├── docker-compose.yml               # Configuración Docker
├── test-plans/
│   └── api-performance.jmx          # Test plan de JMeter
├── config/
│   └── check-thresholds.ps1         # Verificación de umbrales
└── results/                         # Resultados (generado)
    ├── results.jtl                  # Datos brutos
    └── html-report/                 # Reporte HTML
        └── index.html
```

## 🔧 Personalización

### Modificar el Test Plan

1. Abre `test-plans/api-performance.jmx` con JMeter GUI
2. Modifica requests, usuarios, duración
3. Guarda y ejecuta `run.bat`

### Cambiar Endpoint de Prueba

Edita el HTTP Request en el test plan JMeter o modifica:

```xml
<stringProp name="HTTPSampler.domain">tu-api.com</stringProp>
<stringProp name="HTTPSampler.path">/tu-endpoint</stringProp>
```

### Ajustar Umbrales

Edita `config/check-thresholds.ps1`:

```powershell
$P95Threshold = 5000      # P95 en milisegundos
$ErrorRateThreshold = 5   # Tasa de error en porcentaje
```

## 🐛 Solución de Problemas

### Error: "Container name already in use"
```bash
docker-compose down --remove-orphans
docker rm jmeter-performance-test
```

### Error: "Folder is not empty"
```bash
rmdir /s /q results
```

### El reporte HTML no se genera
- Verifica que el comando incluya `-e -o /results/html-report`
- Revisa que el volumen Docker esté mapeado correctamente

### La ejecución no termina
- Verifica que el Thread Group tenga Duration configurado
- Presiona `Ctrl + C` para detener manualmente

## 📝 Flujo de Trabajo Típico

1. **Desarrollo**: Modificar test plan en JMeter GUI
2. **Prueba**: Ejecutar `run.bat` 
3. **Análisis**: Revisar reporte HTML automático
4. **Ajuste**: Modificar configuración según resultados
5. **Commit**: Guardar cambios en el repositorio

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es para fines educativos en UTEC. Son casi las 5 de la manana y aprendi demasiado de performance en un par de horas. Nos vemos el miercoles en la prueba.
