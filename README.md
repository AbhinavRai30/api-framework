# API Framework - Quick Start Guide

## Overview
API automation framework with robotframework with taking payloads from Excel and sending as JSON or XML

## Framework Structure

```
api-framework/
├── keywords/                    # Custom Robot Framework Libraries
│   ├── APIKeywords.py          # API operations (GET, POST, PUT, DELETE)
│   ├── DatabaseKeywords.py     # Database operations (PostgreSQL)
│   └── UtilityKeywords.py      # Utility functions (Excel, data conversion)
│
├── tests/                       # Test files
│   ├── api_json_tests.robot    # JSON payload test cases
│   ├── api_xml_tests.robot     # XML payload test cases
│   └── common.robot            # Common configuration
│
├── test_data/                   # Test data files
│   ├── film_test_data.xlsx     # JSON test data (pre-created)
│   └── film_xml_test_data.xlsx # XML test data (pre-created)
│
├── reports/                     # Test execution reports (auto-generated)
├── logs/                        # Test logs (auto-generated)
├── requirements.txt             # Python dependencies
└── README.md                    # Detailed documentation
```

## Installation & Setup

### Step 1: Install Dependencies
The requirements are already listed in `requirements.txt`. If not installed:

```bash
pip install -r requirements.txt
```

### Step 2: Configure Database Connection
Edit `tests/common.robot` and update your database credentials:

```robot
${DB_HOST}        localhost          # Your DB host
${DB_NAME}        greencycles        # Your DB name
${DB_USER}        ******           # Your DB user
${DB_PASSWORD}    ******            # Your DB password
${DB_PORT}        5432               # Your DB port
```

### Step 3: Verify API Server
Ensure your API server is running:
 
```bash
# Test connection
curl http://127.0.0.1:8000/tables
```

## Running Tests

### Run All Tests
```bash
# PowerShell
.\run_tests.ps1

# Command Prompt
run_tests.bat

# Direct Robot Framework
robot --outputdir reports tests/
```

### Run Specific Test File
```bash
# JSON tests only
robot --outputdir reports tests/api_json_tests.robot

# XML tests only
robot --outputdir reports tests/api_xml_tests.robot
```

### Run Tests by Tag
```bash
# Run only POST tests
robot --include POST --outputdir reports tests/

# Run only Database validation tests
robot --include Database --outputdir reports tests/

# Run JSON tests only
robot --include JSON --outputdir reports tests/
```

## Key Libraries & Keywords

### APIKeywords - Universal API Operations

**Connection Setup:**
```robot
Set Base URL    http://127.0.0.1:8000
Set Headers     {'Content-Type': 'application/json'}
Add Header      Authorization    Bearer token123
```

**GET Request:**
```robot
Perform GET Request    /table/films
Response Status Code Should Be    200
${response}=    Get Response Body
```

**POST Request:**
```robot
${payload}=    Create Dictionary    title=My Film    rental_rate=5.99
Perform POST Request    /table/films    ${payload}    payload_type=json
Response Status Code Should Be    201
${film_id}=    Get Response JSON Value    film_id
```

**PUT Request:**
```robot
Perform PUT Request    /table/films/1    ${update_payload}    payload_type=json
Response Status Code Should Be    200
```

**DELETE Request:**
```robot
Perform DELETE Request    /table/films/1
Response Status Code Should Be    204
```

### DatabaseKeywords - PostgreSQL Operations

**Connection:**
```robot
Connect To Database    localhost    greencycles    {username}    {password}
# ... perform database operations ...
Disconnect From Database
```

**Verification:**
```robot
# Verify record exists
Table Row Should Exist    films    film_id = 1

# Verify record was created
Verify Record Created    films    film_id    ${new_id}

# Verify record was updated
Verify Record Change    films    film_id    1    rental_rate    5.99    6.99

# Verify record was deleted
Verify Record Deleted    films    film_id    ${deleted_id}

# Verify column value
Table Row Column Value Should Be    films    film_id = 1    title    My Film

# Check row count
Table Row Count Should Be    films    10
```

**Query Execution:**
```robot
${results}=    Execute Query    SELECT * FROM films WHERE language_id = 1
${rows_affected}=    Execute Update    DELETE FROM films WHERE film_id = 999
```

### UtilityKeywords - Data Management

**Read Test Data from Excel:**
```robot
${test_data}=    Read Test Data From Excel    test_data/film_test_data.xlsx    Films
${film}=         Get Test Data By Name        Test Film Title
${all_data}=     Get All Test Data
```

**Convert Data:**
```robot
${json_payload}=    Convert Test Data To JSON    ${film}    exclude_columns=['expected_response']
${dict_payload}=    Convert Test Data To Dict    ${film}
```

## Complete Example Test Case

```robot
*** Settings ***
Library    keywords.APIKeywords
Library    keywords.DatabaseKeywords
Library    keywords.UtilityKeywords

*** Test Cases ***
Test Complete Film Workflow
    [Documentation]    Create, verify, update, and delete a film record
    [Tags]    Complete    Database    JSON
    
    # Setup
    Set Base URL    http://127.0.0.1:8000
    Connect To Database    localhost    greencycles    {username}    {password}
    
    # Create new film via API
    ${payload}=    Create Dictionary
    ...    title=Test Film
    ...    rental_duration=4
    ...    rental_rate=5.99
    ...    replacement_cost=19.99
    
    Perform POST Request    /table/films    ${payload}    payload_type=json
    Response Status Code Should Be    201
    ${film_id}=    Get Response JSON Value    film_id
    
    # Verify in database
    Verify Record Created    films    film_id    ${film_id}
    Table Row Column Value Should Be    films    film_id = ${film_id}    title    Test Film
    
    # Update film
    ${update}=    Create Dictionary    rental_rate=6.99
    Perform PUT Request    /table/films/${film_id}    ${update}    payload_type=json
    Response Status Code Should Be    200
    
    # Verify update in database
    Table Row Column Value Should Be    films    film_id = ${film_id}    rental_rate    6.99
    
    # Delete film
    Perform DELETE Request    /table/films/${film_id}
    Response Status Code Should Be    204
    
    # Verify deletion
    Verify Record Deleted    films    film_id    ${film_id}
    
    # Cleanup
    Disconnect From Database
```


## Reports

After running tests, reports are generated in the `reports/` folder:
- `report.html` - Summary report
- `log.html` - Detailed logs
- `output.xml` - Machine-readable results

Open reports in a browser:
```bash
# Windows
start reports\report.html

# Linux/Mac
open reports/report.html
```


### Add New Test Cases
Create a new file in `tests/` directory or add cases to existing files following Robot Framework syntax.

## Best Practices

1. **Use Variables** - Define configurations in `common.robot`
2. **Reuse Keywords** - Create custom keywords for common operations
3. **Separate Concerns** - One test case = one feature
4. **Meaningful Names** - Use descriptive test and keyword names
5. **Database Cleanup** - Always disconnect and clean test data
6. **Error Handling** - Verify both API and database responses
7. **Test Data** - Keep test data in Excel for easy maintenance
```

## Support & Documentation

- Full documentation: See `README.md`
- Robot Framework docs: https://robotframework.org
- PostgreSQL docs: https://www.postgresql.org/docs/

## Quick Commands Reference

```bash
# Install dependencies
pip install -r requirements.txt

# Run all tests
robot --outputdir reports tests/

# Run with tags
robot --include POST --outputdir reports tests/

# Run specific file
robot --outputdir reports tests/api_json_tests.robot

# View help
robot --help

# Run with custom variables
robot --variable DB_HOST:remote_host --outputdir reports tests/
```


**Version:** 1.0

