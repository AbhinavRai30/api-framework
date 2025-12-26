*** Settings ***
Documentation    API Automation Tests - POST, GET, PUT, DELETE with JSON Payload
Library          ../keywords/APIKeywords.py
Library          ../keywords/DatabaseKeywords.py
Library          ../keywords/UtilityKeywords.py
Library          Collections
Library          OperatingSystem
Resource         ../keywords/common_keyword.robot

Suite Setup      Suite Setup Steps
Suite Teardown   Suite Teardown Steps

*** Variables ***
${BASE_URL}           http://127.0.0.1:8000
${TABLE_ENDPOINT}     /table/film
${DB_HOST}            localhost
${DB_NAME}            greencycles
${DB_USER}            postgres
${DB_PASSWORD}        pgadmin
${TEST_DATA_FILE}     ${CURDIR}${/}..${/}test_data${/}film_test_data.xlsx
${SHEET_NAME}         Films
${DB_EXPECTEDSHEET_NAME}    expected_film_db
${SQL_FILE_PATH}       ${CURDIR}${/}..${/}test_data${/}deletedupquery.sql
${DupCheckQuery}       ${CURDIR}${/}..${/}test_data${/}duplicatecheckquery.sql 


*** Test Cases ***
Test POST New Film with JSON Payload
    [Documentation]    Create new film records via POST request and validate in database
    [Tags]    post    json    database

    # Read all test data rows
    ${test_data_list}=    Read Test Data From Excel    ${TEST_DATA_FILE}    ${SHEET_NAME}
    ${expected_db_data_list}=    Read Test Data From Excel    ${TEST_DATA_FILE}    ${DB_EXPECTEDSHEET_NAME}

    # Get the length to ensure both lists have same count
    ${test_data_count}=    Get Length    ${test_data_list}
    ${expected_data_count}=    Get Length    ${expected_db_data_list}
    Should Be Equal As Numbers    ${test_data_count}    ${expected_data_count}    
    ...    msg=Test data and expected data counts don't match

    # Loop through each row using index
    FOR    ${index}    IN RANGE    ${test_data_count}
        ${film_data}=    Get From List    ${test_data_list}    ${index}
        ${expected_db_data}=    Get From List    ${expected_db_data_list}    ${index}
        
        # Prepare payload for this row
        ${exclude_cols}=    Create List    expected_response    special_features    fulltext
        ${payload}=    Convert Test Data To Dict    ${film_data}    ${exclude_cols}
        ${expected_db_data}=    Convert Test Data To Dict    ${expected_db_data}

        # Make POST request
        Perform POST Request    ${TABLE_ENDPOINT}    ${payload}    payload_type=json
        Response Status Code Should Be    200

        # Get the actual response from the POST request
        ${actual_response}=    Get Response Body
        Log    ${actual_response}    console=True
        
        # Get expected response from this specific row's excel data
        ${expected_response}=    Get Expected Response    ${film_data}
        Log    ${expected_response}    console=True

        # Compare actual response with expected response for this row
        Should Contain Expected Keys    ${actual_response}    ${expected_response}

        # Verify response contains expected fields
        Response JSON Should Contain Key    film_id
        ${film_id}=    Get Response JSON Value    film_id

        # Verify in database - record was created
        DatabaseKeywords.Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
        Verify Record Created    film    film_id    ${film_id}

        # Verify expected data with database record

        Verify Table Row Matches Expected Data    film    film_id = ${film_id}    ${expected_db_data}

        # Verify specific data using the matching expected_db_data for this iteration
        Table Row Column Value Should Be    film    film_id = ${film_id}    title    ${expected_db_data}[title]

        DatabaseKeywords.Disconnect From Database

        Log    Successfully created and validated film with ID: ${film_id}
    END

Delete duplicate records before running other tests
    Read SQL file and Execute Delete Query          ${SQL_FILE_PATH}

Test GET All Films
    [Documentation]    Retrieve all films via GET request
    [Tags]    GET    JSON

    set base url    ${BASE_URL}
    Perform GET Request    ${TABLE_ENDPOINT}
    Response Status Code Should Be    200

    # Verify response is a list/contains films
    ${response}=        Get Response Body
    Log    ${response}    console=True
    Should Be True    ${response} is not None
    Log    Retrieved films successfully


Test GET Single Film
    [Documentation]    Retrieve a specific film via GET request
    [Tags]    GET    JSON

    Set Base URL    ${BASE_URL}
    Perform GET Request    ${TABLE_ENDPOINT}/1001
    Response Status Code Should Be    200
    ${response}=        Get Response Body
    Log    ${response}    console=True

    ${expected_resonse}=    Create Dictionary
    ...    film_id=1001
    ...    title=Captain America
    ...    description=An updated description for Captain America movie
    ...    release_year=2011
    ...    rental_duration=5
    ...    rental_rate=5.99
    ...    replacement_cost=19.99
    ...    rating=PG-13

    Should Contain Expected Keys     ${response}    ${expected_resonse}
    

    # Verify we got a film
    Response JSON Should Contain Key    film_id


Test PUT Update Film with JSON
    [Documentation]    Update an existing film and validate changes in database
    [Tags]    PUT    JSON    Database

    Set Base URL    ${BASE_URL}

    # First, get film data
    ${film_id}=    Set Variable    1001

    # Prepare update payload
    ${update_payload}=    Create Dictionary
    ...    title=Captain America
    ...    description=An updated description for Captain America movie
    ...    release_year=2011
    ...    language_id=1
    ...    rental_duration=5
    ...    rental_rate=5.99
    ...    replacement_cost=19.99
    ...    rating=PG-13
           
    # Make PUT request
    Perform PUT Request    ${TABLE_ENDPOINT}/${film_id}    ${update_payload}    payload_type=json
    Response Status Code Should Be    200
    ${response}=        Get Response Body
    Log    ${response}    console=True

    ${expected_resonse}=    Create Dictionary
    ...    film_id=1001
    ...    title=Captain America
    ...    description=An updated description for Captain America movie
    ...    release_year=2011
    ...    language_id=1
    ...    rental_duration=5
    ...    rental_rate=5.99
    ...    replacement_cost=19.99
    ...    rating=PG-13

    Should Contain Expected Keys     ${response}    ${expected_resonse}

    # Verify in database - record was updated
    DatabaseKeywords.Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Change    film    film_id    ${film_id}    title    (any)    Captain America
    Table Row Column Value Should Be    film    film_id = ${film_id}    rental_rate    5.99

    DatabaseKeywords.Disconnect From Database


Test DELETE Film Record
    [Documentation]    Delete a film record and validate deletion in database
    [Tags]    DELETE    Database

    Set Base URL    ${BASE_URL}

    # First create a film to delete
    ${payload}=    Create Dictionary
    ...    title=Jurassic Park
    ...    description=A science fiction adventure film
    ...    release_year=1993
    ...    language_id=1
    ...    rental_duration=3
    ...    rental_rate=4.99
    ...    replacement_cost=19.99

    Perform POST Request    ${TABLE_ENDPOINT}    ${payload}    payload_type=json
    ${film_id}=    Get Response JSON Value    film_id
    ${response}=        Get Response Body
    Log    Created film to delete: ${response}    console=True

    # Delete the film
    Perform DELETE Request    ${TABLE_ENDPOINT}/${film_id}
    Response Status Code Should Be    200
    ${Delete_response}=        Get Response Body
    Log    Deleted film response: ${Delete_response}    console=True

    # Verify in database - record was deleted
    DatabaseKeywords.Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Deleted    film    film_id    ${film_id}

    DatabaseKeywords.Disconnect From Database


Test POST Film Without Required Field
    [Documentation]    Verify API validation for required fields
    [Tags]    POST    Validation

    Set Base URL    ${BASE_URL}

    ${invalid_payload}=    Create Dictionary
    ...    description=Test GET All Films
    ...    release_year=2020
    ...    language_id=1
    ...    rental_duration=3

    Perform POST Request    ${TABLE_ENDPOINT}    ${invalid_payload}    payload_type=json
    Response Status Code Should Be    500


*** Keywords ***
Suite Setup Steps
    [Documentation]    Setup before test suite
    set base url    ${BASE_URL}
    Log    API Automation Framework Started


Suite Teardown Steps
    [Documentation]    Cleanup after test suite
    Log    Test Suite Completed

