*** Settings ***
Documentation    API Automation Tests - POST, GET, PUT, DELETE with JSON Payload
Library          ../keywords/APIKeywords.py
Library          ../keywords/DatabaseKeywords.py
Library          ../keywords/UtilityKeywords.py

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


*** Test Cases ***
Test POST New Film with JSON Payload
    [Documentation]    Create new film records via POST request and validate in database
    [Tags]    POST    JSON    Database

    # Read all test data rows
    ${test_data_list}=    Read Test Data From Excel    ${TEST_DATA_FILE}    ${SHEET_NAME}

    # Loop through each row and create a film record
    FOR    ${film_data}    IN    @{test_data_list}
        # Prepare payload for this row
        ${exclude_cols}=    Create List    expected_response      special_features    fulltext    
        ${payload}=    Convert Test Data To Dict    ${film_data}    ${exclude_cols}

        # Make POST request
        Perform POST Request    ${TABLE_ENDPOINT}    ${payload}    payload_type=json
        Response Status Code Should Be    200

        # Verify response contains expected fields
        Response JSON Should Contain Key    film_id
        ${film_id}=    Get Response JSON Value    film_id

        # Verify in database - record was created
        Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
        Verify Record Created    film    film_id    ${film_id}

        # Verify specific data
        Table Row Column Value Should Be    film    film_id = ${film_id}    title    ${film_data}[title]

        Disconnect From Database

        Log    Successfully created film with ID: ${film_id}
    END


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
    ...    rental_duration=5
    ...    rental_rate=5.99
    ...    replacement_cost=19.99
    ...    rating=PG-13
           
    # Make PUT request
    Perform PUT Request    ${TABLE_ENDPOINT}/${film_id}    ${update_payload}    payload_type=json
    Response Status Code Should Be    200
    ${response}=        Get Response Body
    Log    ${response}    console=True

    # Verify in database - record was updated
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Change    film    film_id    ${film_id}    title    (any)    Captain America
    Table Row Column Value Should Be    film    film_id = ${film_id}    rental_rate    5.99

    Disconnect From Database


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
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Deleted    film    film_id    ${film_id}

    Disconnect From Database


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

