*** Settings ***
Documentation    Common Configuration and Keywords for All API Tests

*** Variables ***
# API Configuration
${API_BASE_URL}           http://127.0.0.1:8000

# Database Configuration
${DB_HOST}                localhost
${DB_PORT}                5432
${DB_NAME}                greencycles
${DB_USER}                postgres
${DB_PASSWORD}            pgadmin

# File Paths
${TEST_DATA_DIR}          ${CURDIR}${/}..${/}test_data
${JSON_TEST_DATA}         ${TEST_DATA_DIR}${/}film_test_data.xlsx
${XML_TEST_DATA}          ${TEST_DATA_DIR}${/}film_xml_test_data.xlsx
${REPORTS_DIR}            ${CURDIR}${/}..${/}reports
${LOGS_DIR}               ${CURDIR}${/}..${/}logs

# HTTP Headers
&{JSON_HEADERS}           Content-Type=application/json    Accept=application/json
&{XML_HEADERS}            Content-Type=application/xml    Accept=application/xml

# Default Timeouts and Retries
${API_TIMEOUT}            30s
${DB_TIMEOUT}             10s
${RETRY_COUNT}            3
${RETRY_INTERVAL}         2s

# Test Table Names
${TABLE_FILMS}            films
${TABLE_LANGUAGES}        languages
${TABLE_CATEGORIES}       film_categories

