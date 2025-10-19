<#
.SYNOPSIS
    Limpia todos los resultados y contenedores
.EXAMPLE
    .\clean.ps1
#>

Write-Host "=== LIMPIANDO ENTORNO ===" -ForegroundColor Yellow

Write-Host "Eliminando resultados..." -ForegroundColor Gray
Remove-Item -Path "results" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Deteniendo contenedores..." -ForegroundColor Gray
docker-compose down

Write-Host "Limpiando imágenes no utilizadas..." -ForegroundColor Gray
docker system prune -f

Write-Host "✅ Limpieza completada" -ForegroundColor Green