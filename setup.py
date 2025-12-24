"""
Setup script for API Framework
Run this to initialize the framework and generate sample test data
"""

import os
import sys
import subprocess

def setup_framework():
    """Initialize framework"""
    print("=" * 60)
    print("   API Automation Framework - Setup")
    print("=" * 60)
    print()

    # Create necessary directories
    print("[1/4] Creating directories...")
    directories = ['reports', 'logs', 'test_data']
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"  ✓ Created: {directory}")

    # Install dependencies
    print("\n[2/4] Installing dependencies...")
    try:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-q', '-r', 'requirements.txt'])
        print("  ✓ Dependencies installed")
    except subprocess.CalledProcessError:
        print("  ✗ Failed to install dependencies")
        return False

    # Generate sample test data
    print("\n[3/4] Creating sample test data...")
    try:
        subprocess.check_call([sys.executable, 'create_sample_test_data.py'])
        print("  ✓ Sample test data created")
    except subprocess.CalledProcessError:
        print("  ✗ Failed to create sample test data")
        return False

    # Display summary
    print("\n[4/4] Setup Summary")
    print("-" * 60)
    print("\n✓ Framework setup completed successfully!")
    print("\nNext steps:")
    print("  1. Update database credentials in tests/common.robot")
    print("  2. Update test data in test_data/film_test_data.xlsx")
    print("  3. Ensure your API server is running at http://127.0.0.1:8000")
    print("  4. Run tests using:")
    print("     PowerShell: .\\run_tests.ps1")
    print("     Command Prompt: run_tests.bat")
    print("     Direct: robot --outputdir reports tests/")
    print()
    print("For more information, see README.md")
    print()
    return True


if __name__ == "__main__":
    success = setup_framework()
    sys.exit(0 if success else 1)

