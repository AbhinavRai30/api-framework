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
        ${exclude_cols}=    Create List    expected_response    special_features    fulltext
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
    ${response}=    Get Response Body
    Should Be True    ${response} is not None
    Log    Retrieved films successfully


Test GET Single Film
    [Documentation]    Retrieve a specific film via GET request
    [Tags]    GET    JSON

    Set Base URL    ${BASE_URL}
    Perform GET Request    ${TABLE_ENDPOINT}/1
    Response Status Code Should Be    200

    # Verify we got a film
    Response JSON Should Contain Key    film_id


Test PUT Update Film with JSON
    [Documentation]    Update an existing film and validate changes in database
    [Tags]    PUT    JSON    Database

    Set Base URL    ${BASE_URL}

    # First, get film data
    ${film_id}=    Set Variable    1

    # Prepare update payload
    ${update_payload}=    Create Dictionary
    ...    title=Updated Film Title
    ...    rental_rate=5.99
    ...    language_id=1

    # Make PUT request
    Perform PUT Request    ${TABLE_ENDPOINT}/${film_id}    ${update_payload}    payload_type=json
    Response Status Code Should Be    200

    # Verify in database - record was updated
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Change    films    film_id    ${film_id}    title    (any)    Updated Film Title
    Table Row Column Value Should Be    films    film_id = ${film_id}    rental_rate    5.99

    Disconnect From Database


Test DELETE Film Record
    [Documentation]    Delete a film record and validate deletion in database
    [Tags]    DELETE    Database

    Set Base URL    ${BASE_URL}

    # First create a film to delete
    ${payload}=    Create Dictionary
    ...    title=Film To Delete
    ...    rental_duration=3
    ...    rental_rate=4.99
    ...    replacement_cost=19.99

    Perform POST Request    ${TABLE_ENDPOINT}    ${payload}    payload_type=json
    ${film_id}=    Get Response JSON Value    film_id

    # Delete the film
    Perform DELETE Request    ${TABLE_ENDPOINT}/${film_id}
    Response Status Code Should Be    204

    # Verify in database - record was deleted
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Deleted    films    film_id    ${film_id}

    Disconnect From Database


Test POST Film Without Required Field
    [Documentation]    Verify API validation for required fields
    [Tags]    POST    Validation

    Set Base URL    ${BASE_URL}

    ${invalid_payload}=    Create Dictionary
    ...    description=Film without title

    Perform POST Request    ${TABLE_ENDPOINT}    ${invalid_payload}    payload_type=json
    Response Status Code Should Be    400
    Response Body Should Contain    required


*** Keywords ***
Suite Setup Steps
    [Documentation]    Setup before test suite
    set base url    ${BASE_URL}
    Log    API Automation Framework Started


Suite Teardown Steps
    [Documentation]    Cleanup after test suite
    Log    Test Suite Completed

