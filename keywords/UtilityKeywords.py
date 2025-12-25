"""
Utility Keywords Library for Robot Framework
Provides utilities for reading Excel files, data handling, etc.
"""

import openpyxl
import json
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
import os


class UtilityKeywords:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.excel_data = None
        self.current_test_data = None

    @keyword
    def read_test_data_from_excel(self, file_path, sheet_name):
        """Read test data from Excel file

        Args:
            file_path: Path to Excel file
            sheet_name: Name of the sheet to read

        Returns:
            List of test data rows (as dictionaries)
        """
        if not os.path.exists(file_path):
            BuiltIn().fail(f"Excel file not found: {file_path}")

        try:
            workbook = openpyxl.load_workbook(file_path)
            worksheet = workbook[sheet_name]

            # Get headers from first row
            headers = []
            for cell in worksheet[1]:
                headers.append(cell.value)

            # Get data from remaining rows
            test_data = []
            for row_idx, row in enumerate(worksheet.iter_rows(min_row=2, values_only=True), start=2):
                row_data = {}
                for col_idx, cell_value in enumerate(row):
                    if col_idx < len(headers) and headers[col_idx]:
                        row_data[headers[col_idx]] = cell_value

                # Only add non-empty rows
                if any(v is not None for v in row_data.values()):
                    test_data.append(row_data)

            self.excel_data = test_data
            workbook.close()

            BuiltIn().log(f"Read {len(test_data)} rows from {sheet_name}")
            return test_data

        except Exception as e:
            BuiltIn().fail(f"Failed to read Excel file: {str(e)}")

    @keyword
    def get_test_data_by_name(self, data_name):
        """Get specific test data row by name/identifier

        Args:
            data_name: Name or identifier of the test data

        Returns:
            Test data row as dictionary
        """
        if not self.excel_data:
            BuiltIn().fail("No Excel data loaded")

        for row in self.excel_data:
            # Check if 'name' or 'Name' or first column matches
            if 'name' in row and str(row['name']).lower() == str(data_name).lower():
                self.current_test_data = row
                return row
            elif 'Name' in row and str(row['Name']).lower() == str(data_name).lower():
                self.current_test_data = row
                return row
            elif 'title' in row and str(row['title']).lower() == str(data_name).lower():
                self.current_test_data = row
                return row

        BuiltIn().fail(f"Test data '{data_name}' not found")

    @keyword
    def get_all_test_data(self):
        """Get all loaded Excel test data

        Returns:
            List of all test data rows
        """
        if not self.excel_data:
            BuiltIn().fail("No Excel data loaded")
        return self.excel_data

    @keyword
    def convert_test_data_to_json(self, test_data_row, exclude_columns=None):
        """Convert test data row to JSON payload

        Args:
            test_data_row: Dictionary of test data
            exclude_columns: List of column names to exclude (e.g., ['expected_response', 'title'])

        Returns:
            JSON string of the payload
        """
        if exclude_columns is None:
            exclude_columns = ['expected_response', 'expected_response']

        payload = {}
        for key, value in test_data_row.items():
            if key not in exclude_columns and value is not None:
                payload[key] = value

        return json.dumps(payload)

    @keyword
    def convert_test_data_to_dict(self, test_data_row, exclude_columns=None):
        """Convert test data row to dictionary payload

        Args:
            test_data_row: Dictionary of test data
            exclude_columns: List of column names to exclude

        Returns:
            Dictionary of the payload
        """
        if exclude_columns is None:
            exclude_columns = ['expected_response']

        payload = {}
        for key, value in test_data_row.items():
            if key not in exclude_columns and value is not None:
                payload[key] = value

        return payload

    @keyword
    def get_expected_response(self, test_data_row):
        """Get expected response from test data

        Args:
            test_data_row: Dictionary of test data

        Returns:
            Expected response as dictionary/JSON
        """
        if 'expected_response' not in test_data_row:
            BuiltIn().fail("'expected_response' column not found in test data")

        expected = test_data_row['expected_response']

        # If it's a string that looks like JSON, try to parse it
        if isinstance(expected, str):
            try:
                return json.loads(expected)
            except:
                return expected

        return expected

    @keyword
    def should_contain_expected_keys(self, actual_response, expected_response):
        """Verify that actual response contains all keys from expected response
        
        The actual response can have additional fields not in expected response.
        This only checks that expected keys exist in actual response.
    
        Args:
            actual_response: Actual response dictionary
            expected_response: Expected response dictionary (can be subset of actual)
        """
        if isinstance(expected_response, str):
            expected_response = json.loads(expected_response)
        
        if isinstance(actual_response, str):
            actual_response = json.loads(actual_response)
    
        missing_keys = []
        for key in expected_response.keys():
            if key not in actual_response:
                missing_keys.append(key)
    
        if missing_keys:
            BuiltIn().fail(f"Missing keys in response: {missing_keys}")
    
        BuiltIn().log(f"All expected keys found in actual response")
        BuiltIn().log(f"Expected keys: {list(expected_response.keys())}")
        BuiltIn().log(f"Actual response has {len(actual_response)} total keys")