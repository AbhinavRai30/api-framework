#!/usr/bin/env python
"""
Verification Script - Check that all framework components are in place
Run this to verify the framework is correctly set up
"""

import os
import sys
from pathlib import Path


def check_file(filepath, description):
    """Check if a file exists"""
    if os.path.exists(filepath):
        size = os.path.getsize(filepath)
        print(f"  ✅ {description:<50} ({size:,} bytes)")
        return True
    else:
        print(f"  ❌ {description:<50} MISSING")
        return False


def check_directory(dirpath, description):
    """Check if a directory exists"""
    if os.path.isdir(dirpath):
        print(f"  ✅ {description:<50} (directory)")
        return True
    else:
        print(f"  ❌ {description:<50} MISSING")
        return False


def verify_framework():
    """Verify framework installation"""
    print("\n" + "=" * 80)
    print(" API AUTOMATION FRAMEWORK - VERIFICATION SCRIPT")
    print("=" * 80)

    all_good = True

    # Check directories
    print("\n📁 Checking Directories...")
    all_good &= check_directory("keywords", "Keywords library")
    all_good &= check_directory("tests", "Tests directory")
    all_good &= check_directory("test_data", "Test data directory")

    # Check main files
    print("\n📄 Checking Main Configuration Files...")
    all_good &= check_file("requirements.txt", "Python dependencies")
    all_good &= check_file("README.md", "Main documentation")
    all_good &= check_file("QUICKSTART.md", "Quick start guide")
    all_good &= check_file("IMPLEMENTATION_SUMMARY.md", "Implementation summary")

    # Check keywords
    print("\n🔑 Checking Custom Keywords...")
    all_good &= check_file("keywords/APIKeywords.py", "API Keywords")
    all_good &= check_file("keywords/DatabaseKeywords.py", "Database Keywords")
    all_good &= check_file("keywords/UtilityKeywords.py", "Utility Keywords")
    all_good &= check_file("keywords/__init__.py", "Keywords package init")

    # Check tests
    print("\n🧪 Checking Test Cases...")
    all_good &= check_file("tests/api_json_tests.robot", "JSON test cases")
    all_good &= check_file("tests/api_xml_tests.robot", "XML test cases")
    all_good &= check_file("tests/common.robot", "Common configuration")

    # Check test data
    print("\n📊 Checking Test Data Files...")
    all_good &= check_file("test_data/film_test_data.xlsx", "JSON test data")
    all_good &= check_file("test_data/film_xml_test_data.xlsx", "XML test data")
    all_good &= check_file("test_data/README.md", "Test data documentation")

    # Check utility scripts
    print("\n⚙️  Checking Utility Scripts...")
    all_good &= check_file("setup.py", "Setup script")
    all_good &= check_file("create_sample_test_data.py", "Data generation script")
    all_good &= check_file("run_tests.ps1", "PowerShell test runner")
    all_good &= check_file("run_tests.bat", "Batch test runner")

    # Check dependencies
    print("\n📦 Checking Python Dependencies...")
    try:
        import robotframework
        print(f"  ✅ Robot Framework            (installed)")
    except ImportError:
        print(f"  ❌ Robot Framework            NOT INSTALLED")
        all_good = False

    try:
        import requests
        print(f"  ✅ Requests                   (installed)")
    except ImportError:
        print(f"  ❌ Requests                   NOT INSTALLED")
        all_good = False

    try:
        import psycopg2
        print(f"  ✅ psycopg2                   (installed)")
    except ImportError:
        print(f"  ❌ psycopg2                   NOT INSTALLED")
        all_good = False

    try:
        import openpyxl
        print(f"  ✅ openpyxl                   (installed)")
    except ImportError:
        print(f"  ❌ openpyxl                   NOT INSTALLED")
        all_good = False

    try:
        import xmltodict
        print(f"  ✅ xmltodict                  (installed)")
    except ImportError:
        print(f"  ❌ xmltodict                  NOT INSTALLED")
        all_good = False

    try:
        from dotenv import load_dotenv
        print(f"  ✅ python-dotenv              (installed)")
    except ImportError:
        print(f"  ❌ python-dotenv              NOT INSTALLED")
        all_good = False

    # Summary
    print("\n" + "=" * 80)
    if all_good:
        print(" ✅ FRAMEWORK VERIFICATION PASSED - ALL COMPONENTS PRESENT")
        print("=" * 80)
        print("\n🚀 Next Steps:")
        print("  1. Edit tests/common.robot with your database credentials")
        print("  2. Update test_data/film_test_data.xlsx with your test cases")
        print("  3. Run: robot --outputdir reports tests/")
        print("  4. View results: start reports\\report.html")
        return 0
    else:
        print(" ❌ FRAMEWORK VERIFICATION FAILED - MISSING COMPONENTS")
        print("=" * 80)
        print("\n⚠️  Please fix the missing files/dependencies above")
        print("\nTo install dependencies:")
        print("  pip install -r requirements.txt")
        return 1


if __name__ == "__main__":
    exit_code = verify_framework()
    sys.exit(exit_code)

