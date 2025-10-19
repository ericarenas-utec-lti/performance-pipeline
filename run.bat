@echo off
chcp 65001 >nul
echo ================================
echo   PERFORMANCE PIPELINE RUNNER
echo ================================
echo.

echo [1/5] Cleaning previous results...
if exist results rmdir /s /q results
mkdir results

echo [2/5] Stopping Docker containers...
docker-compose down

echo [3/5] Running JMeter tests with HTML report...
docker-compose up

echo [4/5] Checking HTML report...
if exist results\html-report\index.html (
    echo ✅ HTML report generated
) else (
    echo ⚠️  HTML report not generated
)

echo [5/5] Checking thresholds...
powershell -ExecutionPolicy Bypass -Command "& { . .\config\check-thresholds.ps1 'results/results.jtl' }"

if %errorlevel% equ 0 (
    echo.
    echo ✅ PIPELINE COMPLETED SUCCESSFULLY
    echo.
    echo 📊 HTML Report: results\html-report\index.html
    echo 📈 Results: results\results.jtl
) else (
    echo.
    echo ❌ PIPELINE FAILED
    exit /b 1
)

pause