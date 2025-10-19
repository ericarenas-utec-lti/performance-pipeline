@echo off
chcp 65001 >nul
echo ================================
echo   GENERATE HTML REPORT
echo ================================
echo.

echo [1/4] Cleaning previous results...
if exist results rmdir /s /q results
mkdir results

echo [2/4] Running JMeter with HTML report...
docker-compose up

echo [3/4] Checking HTML report...
if exist results\html-report\index.html (
    echo ✅ HTML report generated successfully!
    echo.
    echo 📊 Report location: results\html-report\index.html
    echo.
    echo [4/4] Opening in browser...
    start results\html-report\index.html
) else (
    echo ❌ HTML report not generated
    echo 📁 Files in results:
    dir results
)

pause