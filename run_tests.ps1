# API Framework Test Runner Script (PowerShell version)
# This script helps run Robot Framework tests with proper output directory

param(
    [string]$TestType = "all",
    [string]$Tag = ""
)

# Colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

Write-Host "========================================================"
Write-Host "   API Automation Framework - Test Runner (PowerShell)"
Write-Host "========================================================"
Write-Host ""

# Check if Robot Framework is installed
try {
    robot --version | Out-Null
} catch {
    Write-Host "[ERROR] Robot Framework not found." -ForegroundColor Red
    Write-Host "Please run: pip install -r requirements.txt" -ForegroundColor Yellow
    exit 1
}

# Create directories if they don't exist
if (!(Test-Path "reports")) {
    New-Item -ItemType Directory -Path "reports" -Force | Out-Null
}

if (!(Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" -Force | Out-Null
}

Write-Host "[INFO] Running tests..." -ForegroundColor Cyan
Write-Host ""

# Determine which test to run
switch ($TestType.ToLower()) {
    "json" {
        Write-Host "Running JSON payload tests..." -ForegroundColor Yellow
        robot --outputdir reports tests/api_json_tests.robot
    }
    "xml" {
        Write-Host "Running XML payload tests..." -ForegroundColor Yellow
        robot --outputdir reports tests/api_xml_tests.robot
    }
    "help" {
        Write-Host "Usage: .\run_tests.ps1 -TestType [type]" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Parameters:" -ForegroundColor Yellow
        Write-Host "  -TestType all   (default) Run all tests"
        Write-Host "  -TestType json  Run JSON payload tests"
        Write-Host "  -TestType xml   Run XML payload tests"
        Write-Host "  -TestType help  Show this help message"
        Write-Host "  -Tag [tagname]  Run tests with specific tag"
        Write-Host ""
        exit 0
    }
    default {
        if ($Tag) {
            Write-Host "Running tests with tag: $Tag" -ForegroundColor Yellow
            robot --include $Tag --outputdir reports tests/
        } else {
            Write-Host "Running all tests..." -ForegroundColor Yellow
            robot --outputdir reports tests/
        }
    }
}

Write-Host ""
Write-Host "[INFO] Test execution completed!" -ForegroundColor Green
Write-Host "[INFO] Reports available in: reports\report.html" -ForegroundColor Cyan
Write-Host ""

# Ask to open report
$response = Read-Host "Open report in browser? (Y/n)"
if ($response -ne "n" -and $response -ne "N") {
    $reportPath = (Get-Item "reports\report.html").FullName
    Start-Process $reportPath
}

