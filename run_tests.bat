@echo off
REM API Framework Test Runner Script
REM This script helps run Robot Framework tests with proper output directory

setlocal enabledelayedexpansion

REM Colors and formatting
color 0A

echo.
echo ===============================================
echo   API Automation Framework - Test Runner
echo ===============================================
echo.

REM Check if Robot Framework is installed
robot --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Robot Framework not found. Please run: pip install -r requirements.txt
    exit /b 1
)

REM Create directories if they don't exist
if not exist "reports" mkdir reports
if not exist "logs" mkdir logs

echo [INFO] Running tests...
echo.

REM Determine which test to run
if "%1"=="" (
    echo Running all tests...
    robot --outputdir reports tests\
) else if "%1"=="json" (
    echo Running JSON tests...
    robot --outputdir reports tests\api_json_tests.robot
) else if "%1"=="xml" (
    echo Running XML tests...
    robot --outputdir reports tests\api_xml_tests.robot
) else if "%1"=="help" (
    echo Usage: run_tests.bat [options]
    echo.
    echo Options:
    echo   (no args)  - Run all tests
    echo   json       - Run JSON payload tests
    echo   xml        - Run XML payload tests
    echo   help       - Show this help message
    echo.
    exit /b 0
) else (
    echo Running tests with tag: %1
    robot --include %1 --outputdir reports tests\
)

echo.
echo [INFO] Test execution completed!
echo [INFO] Reports available in: reports\report.html
echo.
pause

