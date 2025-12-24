# API Automation Framework - Complete Keyword Reference

## APIKeywords Library (Universal REST API Operations)

### Connection Management
- `Set Base URL` - Set the base URL for all API requests
- `Set Headers` - Set custom headers for requests
- `Add Header` - Add a single header
- `Clear Headers` - Clear all headers

### GET Requests
- `Perform GET Request` - Execute GET request to endpoint

### POST Requests
- `Perform POST Request` - Execute POST request with JSON/XML payload

### PUT Requests
- `Perform PUT Request` - Execute PUT request with JSON/XML payload

### DELETE Requests
- `Perform DELETE Request` - Execute DELETE request to endpoint

### Response Status Validation
- `Response Status Code Should Be` - Verify HTTP status code (e.g., 200, 201, 400)

### Response Body Validation
- `Response Body Should Contain` - Verify response contains specific text
- `Response JSON Should Contain Key` - Verify JSON response has a specific key
- `Response JSON Value Should Be` - Verify JSON key has expected value
- `Response JSON Should Equal` - Verify complete JSON response matches expected

### Response Retrieval
- `Get Response Body` - Get the complete response body (dict or text)
- `Get Response Status Code` - Get the HTTP status code
- `Get Response Time` - Get response time in seconds
- `Get Response JSON Value` - Get specific value from JSON response by key

---

## DatabaseKeywords Library (PostgreSQL Operations)

### Connection Management
- `Connect To Database` - Connect to PostgreSQL database
  - Args: db_host, db_name, db_user, db_password, [db_port=5432]
- `Disconnect From Database` - Disconnect from database

### Query Execution
- `Execute Query` - Execute SELECT query, returns list of result rows
  - Returns: List of dictionaries (one per row)
- `Execute Update` - Execute INSERT/UPDATE/DELETE query
  - Returns: Number of rows affected

### Row Existence Verification
- `Table Row Should Exist` - Verify a row exists matching WHERE clause
  - Args: table_name, where_clause (e.g., "id = 5 AND name = 'test'")
- `Table Row Should Not Exist` - Verify a row does NOT exist

### Row Count Verification
- `Table Row Count Should Be` - Verify total row count in table
  - Args: table_name, expected_count, [where_clause]

### Column Value Verification
- `Table Row Column Value Should Be` - Verify specific column value in a row
  - Args: table_name, where_clause, column_name, expected_value

### Row Retrieval
- `Get Table Row By ID` - Get a specific row by ID
  - Args: table_name, id_column, id_value
  - Returns: Dictionary with row data
- `Get Query Result` - Get the last query result
- `Get First Row` - Get the first row from last query

### Transaction Validation (Key Feature!)
- `Verify Record Created` - Verify a new record was created in database
  - Args: table_name, id_column, id_value
- `Verify Record Change` - Verify a record was updated with specific values
  - Args: table_name, id_column, id_value, column_name, old_value, new_value
- `Verify Record Deleted` - Verify a record was deleted from database
  - Args: table_name, id_column, id_value

### Data Manipulation
- `Delete Table Data` - Delete rows from table (with optional WHERE clause)
  - Returns: Number of rows deleted
- `Truncate Table` - Delete all rows from table (TRUNCATE)

---

## UtilityKeywords Library (Excel and Data Management)

### Excel File Reading
- `Read Test Data From Excel` - Read test data from Excel file
  - Args: file_path, sheet_name
  - Returns: List of test data rows (as dictionaries)

### Test Data Retrieval
- `Get Test Data By Name` - Get specific test data row by name/identifier
  - Args: data_name (matches 'name', 'Name', or 'title' column)
  - Returns: Test data row as dictionary
- `Get All Test Data` - Get all loaded Excel test data
  - Returns: List of all test data rows

### Payload Conversion
- `Convert Test Data To JSON` - Convert test data row to JSON payload
  - Args: test_data_row, [exclude_columns]
  - Returns: JSON string
- `Convert Test Data To Dict` - Convert test data row to dictionary
  - Args: test_data_row, [exclude_columns]
  - Returns: Python dictionary

### Expected Response Management
- `Get Expected Response` - Get expected response from test data
  - Args: test_data_row
  - Returns: Expected response as dict/JSON or string
- `Should Contain Expected Keys` - Verify response has all expected keys
  - Args: actual_response, expected_response

---

## Common Robot Framework Keywords (Built-in)

### Variables and Data
- `Create Dictionary` - Create a Python dictionary
  - Example: `${dict}=    Create Dictionary    key1=value1    key2=value2`
- `Create List` - Create a Python list
  - Example: `${list}=    Create List    item1    item2    item3`

### Control Flow
- `Run Keyword If` - Conditionally run a keyword
- `Run Keyword Unless` - Run keyword unless condition is true
- `Repeat Keyword` - Repeat keyword N times

### Logging
- `Log` - Log a message to test output
  - Example: `Log    My message`
- `Log To Console` - Log to console

### String Operations
- `Catenate` - Concatenate strings
  - Example: `${result}=    Catenate    Hello    World`

### Assertions
- `Should Be Equal` - Assert two values are equal
- `Should Be True` - Assert condition is true
- `Should Contain` - Assert string contains substring

---

## Usage Examples

### Complete JSON API Test with Database Validation
```robot
*** Settings ***
Library    keywords.APIKeywords
Library    keywords.DatabaseKeywords
Library    keywords.UtilityKeywords

*** Test Cases ***
Test Create Film and Verify in Database
    [Documentation]    Create film via API and verify in database
    [Tags]    POST    JSON    Database
    
    # Setup
    Set Base URL    http://127.0.0.1:8000
    Connect To Database    localhost    greencycles    postgres    pgadmin
    
    # Read test data from Excel
    ${test_data}=    Read Test Data From Excel    test_data/film_test_data.xlsx    Films
    ${film_data}=    Get Test Data By Name    The Shawshank Redemption
    
    # Prepare payload (exclude expected_response column)
    ${payload}=    Convert Test Data To Dict    ${film_data}    exclude_columns=['expected_response']
    
    # Make API request
    Perform POST Request    /table/films    ${payload}    payload_type=json
    
    # Validate API response
    Response Status Code Should Be    201
    Response JSON Should Contain Key    film_id
    ${film_id}=    Get Response JSON Value    film_id
    
    # Validate database - record was created
    Verify Record Created    films    film_id    ${film_id}
    
    # Validate specific data in database
    Table Row Column Value Should Be    films    film_id = ${film_id}    title    The Shawshank Redemption
    Table Row Column Value Should Be    films    film_id = ${film_id}    rental_rate    4.99
    
    # Cleanup
    Disconnect From Database
```

### Update and Verify Change
```robot
Test Update Film and Verify Change
    [Tags]    PUT    Database
    
    Set Base URL    http://127.0.0.1:8000
    Connect To Database    localhost    greencycles    postgres    pgadmin
    
    ${film_id}=    Set Variable    1
    ${update}=    Create Dictionary    rental_rate=6.99    title=Updated Title
    
    # Update via API
    Perform PUT Request    /table/films/${film_id}    ${update}    payload_type=json
    Response Status Code Should Be    200
    
    # Verify change in database (validates actual change, not just count)
    Verify Record Change    films    film_id    ${film_id}    rental_rate    5.99    6.99
    
    Disconnect From Database
```

### Delete and Verify Removal
```robot
Test Delete Film and Verify Removal
    [Tags]    DELETE    Database
    
    Set Base URL    http://127.0.0.1:8000
    
    # Create a film to delete
    ${payload}=    Create Dictionary    title=To Delete    rental_rate=5.99
    Perform POST Request    /table/films    ${payload}    payload_type=json
    ${film_id}=    Get Response JSON Value    film_id
    
    # Delete the film
    Perform DELETE Request    /table/films/${film_id}
    Response Status Code Should Be    204
    
    # Verify deletion in database
    Connect To Database    localhost    greencycles    postgres    pgadmin
    Verify Record Deleted    films    film_id    ${film_id}
    Disconnect From Database
```

### XML Payload Example
```robot
Test Create Film with XML
    [Tags]    POST    XML
    
    Set Base URL    http://127.0.0.1:8000
    
    ${xml}=    Catenate    SEPARATOR=\n
    ...    <?xml version="1.0" encoding="UTF-8"?>
    ...    <film>
    ...    <title>My Film</title>
    ...    <rental_duration>4</rental_duration>
    ...    <rental_rate>5.99</rental_rate>
    ...    <replacement_cost>19.99</replacement_cost>
    ...    </film>
    
    Perform POST Request    /table/films    ${xml}    payload_type=xml
    Response Status Code Should Be    201
```

### Using Excel Test Data
```robot
Test All Films from Excel
    [Tags]    POST    JSON    ExcelData
    
    Set Base URL    http://127.0.0.1:8000
    
    ${test_data}=    Read Test Data From Excel    test_data/film_test_data.xlsx    Films
    
    FOR    ${film}    IN    @{test_data}
        Log    Creating: ${film}[title]
        
        ${payload}=    Convert Test Data To Dict    ${film}
        Perform POST Request    /table/films    ${payload}    payload_type=json
        
        Response Status Code Should Be    201
    END
```

---

## Keyword Documentation Access

View keyword documentation in your IDE:
1. Open any .robot file
2. Hover over keyword names for docstring tooltips
3. Or view directly: `robot --doc keywords/APIKeywords.py`

---

## Framework Keywords Summary

| Library | Keywords | Purpose |
|---------|----------|---------|
| APIKeywords | 20+ | Universal REST API operations |
| DatabaseKeywords | 15+ | PostgreSQL operations |
| UtilityKeywords | 10+ | Excel and data management |
| Built-in (Robot) | 100+ | General automation tasks |

**Total: 145+ keywords available**

---

## Tips and Best Practices

1. **Always Set Base URL First**
   ```robot
   Set Base URL    http://127.0.0.1:8000
   ```

2. **Use Common Configuration**
   - Define credentials in `common.robot`
   - Import common.robot in your test files
   - This avoids hardcoding values

3. **Separate Concerns**
   - One test case = one feature
   - Don't mix API and database tests (unless verifying changes)
   - Use tags for organization

4. **Test Data Management**
   - Keep test data in Excel
   - Use meaningful test names
   - Include expected responses for validation

5. **Error Handling**
   - Always check status codes
   - Verify database state after operations
   - Log important values for debugging

6. **Database Cleanup**
   - Use `Disconnect From Database` after operations
   - Consider cleanup in test teardown
   - Use `Truncate Table` to reset test data

7. **Response Validation**
   - Check status code first
   - Then validate response body
   - Finally verify database state

---

## Common Patterns

### API → Database Validation Pattern
```robot
# 1. Make API call
Perform POST Request    ${endpoint}    ${payload}
Response Status Code Should Be    201

# 2. Get ID from response
${id}=    Get Response JSON Value    id

# 3. Verify in database
Connect To Database    ...
Verify Record Created    ${table}    id    ${id}
Disconnect From Database
```

### Data Driven Testing Pattern
```robot
${test_data}=    Read Test Data From Excel    file.xlsx    sheet
FOR    ${data}    IN    @{test_data}
    # Use ${data}[field_name] to access values
END
```

### Status Code Validation Pattern
```robot
Perform ${METHOD} Request    ${endpoint}    ${payload}
Response Status Code Should Be    ${expected_code}
Response Body Should Contain    ${expected_content}
```

---

**For more examples, see:**
- tests/api_json_tests.robot
- tests/api_xml_tests.robot
- README.md
- QUICKSTART.md

