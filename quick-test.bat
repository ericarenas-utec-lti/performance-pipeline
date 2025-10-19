@echo off
chcp 65001 >nul
echo ======================
echo   QUICK JMETER TEST
echo ======================
echo.

echo Cleaning...
if exist results rmdir /s /q results
mkdir results

echo Running quick test...
docker run --rm -v "%CD%\test-plans:/test-plans" -v "%CD%\results:/results" justb4/jmeter:5.5 -n -t /test-plans/api-performance.jmx -l /results/results.jtl -Jthreads=2 -Jrampup=5 -Jduration=15

if %errorlevel% equ 0 (
    echo ✅ Quick test completed
    dir results
) else (
    echo ❌ Quick test failed
)

pause