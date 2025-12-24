*** Settings ***
Documentation    API Automation Tests - POST, GET, PUT, DELETE with JSON Payload
Library          ../keywords/APIKeywords.py
Library          ../keywords/DatabaseKeywords.py
Library          ../keywords/UtilityKeywords.py

Suite Setup      Suite Setup Steps
Suite Teardown   Suite Teardown Steps

*** Variables ***
${BASE_URL}           http://127.0.0.1:8000
${TABLE_ENDPOINT}     /table/actor
${DB_HOST}            localhost
${DB_NAME}            greencycles
${DB_USER}            postgres
${DB_PASSWORD}        pgadmin
${TEST_DATA_FILE}     ${CURDIR}${/}..${/}test_data${/}actor_test_data.xlsx
${SHEET_NAME}         Actors


*** Test Cases ***
Test POST New Actor with JSON Payload
    [Documentation]    Create new actor records via POST request and validate in database
    [Tags]    POST    JSON    Database

    # Read all test data rows
    ${test_data_list}=    Read Test Data From Excel    ${TEST_DATA_FILE}    ${SHEET_NAME}

    # Loop through each row and create a film record
    FOR    ${actor_data}    IN    @{test_data_list}
        # Prepare payload for this row
        ${exclude_cols}=    Create List    expected_response  
        ${payload}=    Convert Test Data To Dict    ${actor_data}    ${exclude_cols}

        # Make POST request
        Perform POST Request    ${TABLE_ENDPOINT}    ${payload}    payload_type=json
        Response Status Code Should Be    200

        # Verify response contains expected fields
        Response JSON Should Contain Key    actor_id
        ${actor_id}=    Get Response JSON Value    actor_id

        # Verify in database - record was created
        Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
        Verify Record Created    actor    actor_id    ${actor_id}

        # Verify specific data
        Table Row Column Value Should Be    actor    actor_id = ${actor_id}    first_name    ${actor_data}[first_name]

        Disconnect From Database

        Log    Successfully created actor with ID: ${actor_id}
    END


Test GET All Actors
    [Documentation]    Retrieve all actors via GET request
    [Tags]    GET    JSON

    set base url    ${BASE_URL}
    Perform GET Request    ${TABLE_ENDPOINT}
    Response Status Code Should Be    200

    # Verify response is a list/contains films
    ${response}=        Get Response Body
    Log    ${response}    console=True
    Should Be True    ${response} is not None
    Log    Retrieved films successfully


Test GET Single Actor
    [Documentation]    Retrieve a specific actor via GET request
    [Tags]    GET    JSON

    Set Base URL    ${BASE_URL}
    Perform GET Request    ${TABLE_ENDPOINT}/100
    Response Status Code Should Be    200
    ${response}=        Get Response Body
    Log    ${response}    console=True
    

    # Verify we got a film
    Response JSON Should Contain Key    actor_id


Test PUT Update Actor with JSON
    [Documentation]    Update an existing actor and validate changes in database
    [Tags]    PUT    JSON    Database

    Set Base URL    ${BASE_URL}

    # First, get actor data
    ${actor_id}=    Set Variable    100

    # Prepare update payload
    ${update_payload}=    Create Dictionary
    ...    first_name=Steve
    ...    last_name=Rogers
 
           
    # Make PUT request
    Perform PUT Request    ${TABLE_ENDPOINT}/${actor_id}    ${update_payload}    payload_type=json
    Response Status Code Should Be    200
    ${response}=        Get Response Body
    Log    ${response}    console=True

    # Verify in database - record was updated
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Change    actor    actor_id    ${actor_id}    first_name    (any)    Steve
    Table Row Column Value Should Be    actor    actor_id = ${actor_id}    last_name    Rogers

    Disconnect From Database


Test DELETE Actor Record
    [Documentation]    Delete an actor record and validate deletion in database
    [Tags]    DELETE    Database

    Set Base URL    ${BASE_URL}

    # First create an actor to delete
    ${payload}=    Create Dictionary
    ...    first_name=Ivaan
    ...    last_name=Rai

    Perform POST Request    ${TABLE_ENDPOINT}    ${payload}    payload_type=json
    ${actor_id}=    Get Response JSON Value    actor_id
    ${response}=        Get Response Body
    Log    Created film to delete: ${response}    console=True

    # Delete the actor
    Perform DELETE Request    ${TABLE_ENDPOINT}/${actor_id}
    Response Status Code Should Be    200
    ${Delete_response}=        Get Response Body
    Log    Deleted actor response: ${Delete_response}    console=True

    # Verify in database - record was deleted
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Verify Record Deleted    actor    actor_id    ${actor_id}
    Disconnect From Database


Test POST Actor Without Required Field
    [Documentation]    Verify API validation for required fields
    [Tags]    POST    Validation

    Set Base URL    ${BASE_URL}

    ${invalid_payload}=    Create Dictionary
    ...    last_name=NoFirstName

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

