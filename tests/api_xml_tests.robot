*** Settings ***
Documentation    API Automation Tests - POST, GET, PUT, DELETE with XML Payload
Library          ../keywords/APIKeywords.py
Library          ../keywords/DatabaseKeywords.py
Library          ../keywords/UtilityKeywords.py

Suite Setup      Suite Setup Steps
Suite Teardown   Suite Teardown Steps

*** Variables ***
${BASE_URL}           http://127.0.0.1:8000
${TABLE_ENDPOINT}     /table/films
${DB_HOST}            localhost
${DB_NAME}            greencycles
${DB_USER}            postgres
${DB_PASSWORD}        pgadmin
${TEST_DATA_FILE}     ${CURDIR}${/}..${/}test_data${/}film_xml_test_data.xlsx


*** Test Cases ***
Test POST Film with XML Payload
    [Documentation]    Create a new film record via POST with XML payload
    [Tags]    POST    XML    Database

    Set Base URL    ${BASE_URL}

    # Prepare XML payload
    ${xml_payload}=    Create Film XML Payload    Test Film    2023    1    4    5.99    120    25.99

    # Make POST request with XML
    Perform POST Request    ${TABLE_ENDPOINT}    ${xml_payload}    payload_type=xml
    Response Status Code Should Be    201

    # Verify in database
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    ${response}=    Get Response Body
    ${film_id}=    Get Response JSON Value    film_id

    Verify Record Created    films    film_id    ${film_id}
    Disconnect From Database


Test PUT Film with XML Payload
    [Documentation]    Update film record via PUT with XML payload
    [Tags]    PUT    XML    Database

    Set Base URL    ${BASE_URL}

    ${film_id}=    Set Variable    1
    ${xml_payload}=    Create Film XML Payload    Updated XML Film    2023    1    4    6.99    120    25.99

    # Make PUT request with XML
    Perform PUT Request    ${TABLE_ENDPOINT}/${film_id}    ${xml_payload}    payload_type=xml
    Response Status Code Should Be    200

    # Verify in database
    Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Table Row Column Value Should Be    films    film_id = ${film_id}    rental_rate    6.99
    Disconnect From Database


*** Keywords ***
Create Film XML Payload
    [Arguments]    ${title}    ${year}    ${language_id}    ${duration}    ${rate}    ${length}    ${replacement_cost}
    [Documentation]    Create XML payload for film

    ${xml}=    Catenate    SEPARATOR=\n
    ...    <?xml version="1.0" encoding="UTF-8"?>
    ...    <film>
    ...    <title>${title}</title>
    ...    <release_year>${year}</release_year>
    ...    <language_id>${language_id}</language_id>
    ...    <rental_duration>${duration}</rental_duration>
    ...    <rental_rate>${rate}</rental_rate>
    ...    <length>${length}</length>
    ...    <replacement_cost>${replacement_cost}</replacement_cost>
    ...    </film>

    [Return]    ${xml}


Suite Setup Steps
    [Documentation]    Setup before test suite
    Set Base URL    ${BASE_URL}
    Log    XML API Automation Tests Started


Suite Teardown Steps
    [Documentation]    Cleanup after test suite
    Log    XML Test Suite Completed

