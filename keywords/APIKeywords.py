"""
API Keywords Library for Robot Framework
Supports GET, POST, PUT, DELETE operations with JSON and XML payloads
"""

import requests
import json
import xml.etree.ElementTree as ET
import xmltodict
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime
import os


class APIKeywords:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.session = requests.Session()
        self.last_response = None
        self.last_response_body = None
        self.last_status_code = None
        self.base_url = None
        self.headers = {}
        self.response_time = None

    @keyword
    def set_base_url(self, url):
        """Set the base URL for API requests"""
        self.base_url = url
        BuiltIn().log(f"Base URL set to: {self.base_url}")

    @keyword
    def set_headers(self, headers_dict):
        """Set custom headers for requests

        Args:
            headers_dict: Dictionary of headers (e.g., {'Content-Type': 'application/json'})
        """
        if isinstance(headers_dict, str):
            self.headers = json.loads(headers_dict)
        else:
            self.headers = headers_dict
        BuiltIn().log(f"Headers set: {self.headers}")

    @keyword
    def add_header(self, key, value):
        """Add a single header"""
        self.headers[key] = value
        BuiltIn().log(f"Header added: {key}: {value}")

    @keyword
    def clear_headers(self):
        """Clear all headers"""
        self.headers = {}
        BuiltIn().log("All headers cleared")

    @keyword
    def perform_get_request(self, endpoint, headers=None):
        """Perform GET request

        Args:
            endpoint: API endpoint (relative or absolute URL)
            headers: Optional custom headers

        Returns:
            Response status code
        """
        url = self._build_url(endpoint)
        req_headers = headers if headers else self.headers

        try:
            self.last_response = self.session.get(url, headers=req_headers, timeout=30)
            self.last_status_code = self.last_response.status_code
            self.last_response_body = self._parse_response_body(self.last_response)
            self.response_time = self.last_response.elapsed.total_seconds()

            BuiltIn().log(f"GET request to {url}")
            BuiltIn().log(f"Status Code: {self.last_status_code}")
            BuiltIn().log(f"Response Time: {self.response_time}s")

            return self.last_status_code
        except Exception as e:
            BuiltIn().fail(f"GET request failed: {str(e)}")

    @keyword
    def perform_post_request(self, endpoint, payload, payload_type='json', headers=None):
        """Perform POST request

        Args:
            endpoint: API endpoint
            payload: Request payload (JSON string or XML string)
            payload_type: 'json' or 'xml'
            headers: Optional custom headers

        Returns:
            Response status code
        """
        url = self._build_url(endpoint)
        req_headers = headers if headers else self.headers.copy()

        # Set content type based on payload type
        if payload_type.lower() == 'json':
            if 'Content-Type' not in req_headers:
                req_headers['Content-Type'] = 'application/json'
            request_body = json.dumps(payload) if isinstance(payload, dict) else payload
        elif payload_type.lower() == 'xml':
            if 'Content-Type' not in req_headers:
                req_headers['Content-Type'] = 'application/xml'
            request_body = payload if isinstance(payload, str) else ET.tostring(payload, encoding='unicode')
        else:
            request_body = payload

        try:
            self.last_response = self.session.post(url, data=request_body, headers=req_headers, timeout=30)
            self.last_status_code = self.last_response.status_code
            self.last_response_body = self._parse_response_body(self.last_response)
            self.response_time = self.last_response.elapsed.total_seconds()

            BuiltIn().log(f"POST request to {url}")
            BuiltIn().log(f"Payload Type: {payload_type}")
            BuiltIn().log(f"Status Code: {self.last_status_code}")
            BuiltIn().log(f"Response Time: {self.response_time}s")

            return self.last_status_code
        except Exception as e:
            BuiltIn().fail(f"POST request failed: {str(e)}")

    @keyword
    def perform_put_request(self, endpoint, payload, payload_type='json', headers=None):
        """Perform PUT request

        Args:
            endpoint: API endpoint
            payload: Request payload
            payload_type: 'json' or 'xml'
            headers: Optional custom headers

        Returns:
            Response status code
        """
        url = self._build_url(endpoint)
        req_headers = headers if headers else self.headers.copy()

        if payload_type.lower() == 'json':
            if 'Content-Type' not in req_headers:
                req_headers['Content-Type'] = 'application/json'
            request_body = json.dumps(payload) if isinstance(payload, dict) else payload
        elif payload_type.lower() == 'xml':
            if 'Content-Type' not in req_headers:
                req_headers['Content-Type'] = 'application/xml'
            request_body = payload if isinstance(payload, str) else ET.tostring(payload, encoding='unicode')
        else:
            request_body = payload

        try:
            self.last_response = self.session.put(url, data=request_body, headers=req_headers, timeout=30)
            self.last_status_code = self.last_response.status_code
            self.last_response_body = self._parse_response_body(self.last_response)
            self.response_time = self.last_response.elapsed.total_seconds()

            BuiltIn().log(f"PUT request to {url}")
            BuiltIn().log(f"Status Code: {self.last_status_code}")
            BuiltIn().log(f"Response Time: {self.response_time}s")

            return self.last_status_code
        except Exception as e:
            BuiltIn().fail(f"PUT request failed: {str(e)}")

    @keyword
    def perform_delete_request(self, endpoint, headers=None):
        """Perform DELETE request

        Args:
            endpoint: API endpoint
            headers: Optional custom headers

        Returns:
            Response status code
        """
        url = self._build_url(endpoint)
        req_headers = headers if headers else self.headers

        try:
            self.last_response = self.session.delete(url, headers=req_headers, timeout=30)
            self.last_status_code = self.last_response.status_code
            self.last_response_body = self._parse_response_body(self.last_response)
            self.response_time = self.last_response.elapsed.total_seconds()

            BuiltIn().log(f"DELETE request to {url}")
            BuiltIn().log(f"Status Code: {self.last_status_code}")
            BuiltIn().log(f"Response Time: {self.response_time}s")

            return self.last_status_code
        except Exception as e:
            BuiltIn().fail(f"DELETE request failed: {str(e)}")

    @keyword
    def response_status_code_should_be(self, expected_status_code):
        """Verify response status code

        Args:
            expected_status_code: Expected HTTP status code
        """
        expected = int(expected_status_code)
        if self.last_status_code != expected:
            BuiltIn().fail(f"Expected status code {expected}, but got {self.last_status_code}")
        BuiltIn().log(f"Status code {self.last_status_code} matches expected {expected}")

    @keyword
    def response_body_should_contain(self, expected_text):
        """Verify response body contains expected text"""
        if isinstance(self.last_response_body, dict):
            body_str = json.dumps(self.last_response_body)
        else:
            body_str = str(self.last_response_body)

        if expected_text not in body_str:
            BuiltIn().fail(f"Expected text '{expected_text}' not found in response body")
        BuiltIn().log(f"Response body contains: {expected_text}")

    @keyword
    def response_json_should_equal(self, expected_json):
        """Verify response JSON matches expected JSON

        Args:
            expected_json: Expected JSON as string or dict
        """
        if isinstance(expected_json, str):
            expected = json.loads(expected_json)
        else:
            expected = expected_json

        if isinstance(self.last_response_body, dict):
            actual = self.last_response_body
        else:
            BuiltIn().fail("Response body is not JSON")

        self._compare_json(actual, expected)
        BuiltIn().log("Response JSON matches expected JSON")

    @keyword
    def response_json_should_contain_key(self, key):
        """Verify response JSON contains a specific key"""
        if not isinstance(self.last_response_body, dict):
            BuiltIn().fail("Response body is not JSON")

        if key not in self.last_response_body:
            BuiltIn().fail(f"Key '{key}' not found in response JSON")
        BuiltIn().log(f"Response JSON contains key: {key}")

    @keyword
    def response_json_value_should_be(self, key, expected_value):
        """Verify response JSON value for a specific key"""
        if not isinstance(self.last_response_body, dict):
            BuiltIn().fail("Response body is not JSON")

        if key not in self.last_response_body:
            BuiltIn().fail(f"Key '{key}' not found in response JSON")

        actual_value = self.last_response_body[key]
        if str(actual_value) != str(expected_value):
            BuiltIn().fail(f"Expected '{key}' = {expected_value}, but got {actual_value}")
        BuiltIn().log(f"JSON key '{key}' = {expected_value}")

    @keyword
    def get_response_body(self):
        """Get the last response body"""
        return self.last_response_body

    @keyword
    def get_response_json_value(self, key):
        """Get value from response JSON by key"""
        if not isinstance(self.last_response_body, dict):
            BuiltIn().fail("Response body is not JSON")

        if key not in self.last_response_body:
            BuiltIn().fail(f"Key '{key}' not found in response JSON")

        return self.last_response_body[key]

    @keyword
    def get_response_status_code(self):
        """Get the last response status code"""
        return self.last_status_code

    @keyword
    def get_response_time(self):
        """Get the response time in seconds"""
        return self.response_time

    # Helper methods
    def _build_url(self, endpoint):
        """Build complete URL from base URL and endpoint"""
        if endpoint.startswith('http'):
            return endpoint
        if self.base_url:
            return f"{self.base_url.rstrip('/')}/{endpoint.lstrip('/')}"
        return endpoint

    def _parse_response_body(self, response):
        """Parse response body based on content type"""
        try:
            content_type = response.headers.get('Content-Type', '')

            if 'application/json' in content_type:
                return response.json()
            elif 'application/xml' in content_type or 'text/xml' in content_type:
                return xmltodict.parse(response.text)
            elif 'text/plain' in content_type or 'text/html' in content_type:
                return response.text
            else:
                # Try JSON first, then fall back to text
                try:
                    return response.json()
                except:
                    return response.text
        except Exception as e:
            BuiltIn().log(f"Could not parse response body: {str(e)}")
            return response.text

    def _compare_json(self, actual, expected, path=""):
        """Recursively compare JSON objects"""
        if type(actual) != type(expected):
            BuiltIn().fail(f"Type mismatch at {path}: expected {type(expected).__name__}, got {type(actual).__name__}")

        if isinstance(expected, dict):
            for key in expected:
                if key not in actual:
                    BuiltIn().fail(f"Missing key '{key}' at {path}")
                self._compare_json(actual[key], expected[key], f"{path}.{key}" if path else key)
        elif isinstance(expected, list):
            if len(actual) != len(expected):
                BuiltIn().fail(f"List length mismatch at {path}: expected {len(expected)}, got {len(actual)}")
            for i, (a, e) in enumerate(zip(actual, expected)):
                self._compare_json(a, e, f"{path}[{i}]")
        else:
            if actual != expected:
                BuiltIn().fail(f"Value mismatch at {path}: expected {expected}, got {actual}")

