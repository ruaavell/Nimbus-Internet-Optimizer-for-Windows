@echo off
REM Windows Gaming Optimizer Launcher
REM Automatically requests Administrator privileges and launches the application

echo.
echo ========================================
echo  Windows Gaming Optimizer Pro v1.0
echo ========================================
echo.
echo Checking for Administrator privileges...
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running as Administrator
    echo.
    echo Starting Gaming Optimizer...
    echo.
    python main.py
    if %errorLevel% NEQ 0 (
        echo.
        echo [ERROR] Failed to start application!
        echo Make sure Python is installed and in PATH.
        echo.
        pause
    )
) else (
    echo [WARN] Not running as Administrator
    echo Requesting elevation...
    echo.
    powershell -Command "Start-Process python -ArgumentList 'main.py' -Verb RunAs"
)

REM Pause only if there was an error
if %errorLevel% NEQ 0 (
    pause
)
