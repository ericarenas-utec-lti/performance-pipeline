@echo off
chcp 65001 >nul
echo ======================
echo   QUICK JMETER TEST
echo ======================
echo.
echo "⚡ Quick test: 5 users, 10s ramp-up, 30s duration"
echo.

echo Cleaning...
if exist results rmdir /s /q results
mkdir results

echo Running quick test...
docker run --rm -v "%CD%\test-plans:/test-plans" -v "%CD%\results:/results" justb4/jmeter:5.5 -n -t /test-plans/api-performance.jmx -l /results/results.jtl -e -o /results/html-report -Jthreads=5 -Jrampup=10 -Jduration=30

if %errorlevel% equ 0 (
    echo ✅ Quick test completed
    echo 📁 Generated files:
    dir results
) else (
    echo ❌ Quick test failed
)

pause