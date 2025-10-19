@echo off
chcp 65001 >nul
echo ===============
echo   CLEAN UP
echo ===============
echo.

echo Removing results...
if exist results rmdir /s /q results

echo Stopping containers...
docker-compose down

echo Cleaning Docker...
docker system prune -f

echo ✅ Cleanup completed
pause