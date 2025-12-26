*** Settings ***
Library     ../keywords/APIKeywords.py
Library     ../keywords/DatabaseKeywords.py
Library     ../keywords/UtilityKeywords.py
Library     Collections
Library     OperatingSystem
Library     DatabaseLibrary


*** Variables ***
# Database Configuration
${DB_HOST}              127.0.0.1
${DB_PORT}              5432
${DB_NAME}              greencycles
${DB_USER}              postgres
${DB_PASSWORD}          pgadmin

# file path for SQL commands
${SQL_FILE_PATH}        ../test_data/duplicatecheckquery.sql
${SQL_FILE_PATH_2}      ../test_data/deletedupquery.sql




*** Keywords ***
Read SQL file and Execute SQL Query
    [Documentation]    Read SQL commands from a file and return as a single string.
    [Arguments]    ${file_path}
    ${sql_commands}=    Get File    ${file_path}
    DatabaseKeywords.Connect To Database    ${DB_HOST}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}
    Log    Database connection established    console=True
    ${query_result}=    Execute Query    ${sql_commands}
    Log    SQL commands executed successfully and result obtained : ${query_result}    console=True
    DatabaseKeywords.Disconnect From Database
    Log    Database connection closed    console=True
    RETURN    ${sql_commands}

Read SQL file and Execute Delete Query
    [Documentation]    Read SQL commands from a file and return as a single string.
    [Arguments]    ${file_path}
    ${sql_commands}=    Get File    ${file_path}
    DatabaseLibrary.Connect To Database     psycopg2    ${DB_NAME}      ${DB_USER}    ${DB_PASSWORD}   ${DB_HOST}    ${DB_PORT}
    Log    Database connection established    console=True
    ${query_result}=    Execute Sql String    ${sql_commands}
    Log    SQL commands executed successfully and result obtained : ${query_result}    console=True
    DatabaseLibrary.Disconnect From Database
    Log    Database connection closed    console=True
    RETURN    ${sql_commands}
