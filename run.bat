@echo off
chcp 65001 >nul
echo ================================
echo   PERFORMANCE PIPELINE RUNNER
echo ================================
echo.
echo "📊 Load: 50 users, 2min ramp-up, 5min duration"
echo.

echo [1/5] Cleaning previous results...
if exist results rmdir /s /q results
mkdir results
mkdir results\html-report 2>nul

echo [2/5] Stopping Docker containers...
docker-compose down --remove-orphans

echo [3/5] Running JMeter tests with HTML report...
docker-compose up --abort-on-container-exit --timeout 60

echo [4/5] Checking HTML report...
if exist results\html-report\index.html (
    echo ✅ HTML report generated
) else (
    echo ⚠️  HTML report not generated
)

echo [5/5] Checking thresholds...
powershell -ExecutionPolicy Bypass -File .\config\check-thresholds.ps1 "results/results.jtl"
set THRESHOLD_ERROR=%errorlevel%

if %THRESHOLD_ERROR% equ 0 (
    echo.
    echo ✅ PIPELINE COMPLETED SUCCESSFULLY
) else (
    echo.
    echo ⚠️  PIPELINE COMPLETED WITH THRESHOLD WARNINGS
)

echo.
echo 📊 HTML Report: results\html-report\index.html
echo 📈 Results: results\results.jtl
echo 👥 Load: 50 users, 2min ramp-up, 5min duration

echo.
echo 🌐 Abriendo reporte HTML en el navegador...
start results\html-report\index.html

pause