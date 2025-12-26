"""
Database Keywords Library for Robot Framework
Supports PostgreSQL operations for test data validation and manipulation
"""

import psycopg2
from psycopg2.extras import RealDictCursor
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime


class DatabaseKeywords:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.connection = None
        self.cursor = None
        self.db_host = None
        self.db_port = 5432
        self.db_name = None
        self.db_user = None
        self.db_password = None
        self.last_query_result = None

    @keyword
    def connect_to_database(self, db_host, db_name, db_user, db_password, db_port=5432):
        """Connect to PostgreSQL database

        Args:
            db_host: Database hostname/IP
            db_name: Database name
            db_user: Database user
            db_password: Database password
            db_port: Database port (default: 5432)
        """
        self.db_host = db_host
        self.db_name = db_name
        self.db_user = db_user
        self.db_password = db_password
        self.db_port = int(db_port)

        try:
            self.connection = psycopg2.connect(
                host=self.db_host,
                database=self.db_name,
                user=self.db_user,
                password=self.db_password,
                port=self.db_port,
            )
            self.cursor = self.connection.cursor(cursor_factory=RealDictCursor)
            BuiltIn().log(
                f"Connected to database: {self.db_name} on {self.db_host}:{self.db_port}"
            )
        except Exception as e:
            BuiltIn().fail(f"Failed to connect to database: {str(e)}")

    @keyword
    def disconnect_from_database(self):
        """Disconnect from database"""
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
            BuiltIn().log("Disconnected from database")
        except Exception as e:
            BuiltIn().fail(f"Failed to disconnect from database: {str(e)}")

    @keyword
    def execute_query(self, query):
        """Execute SELECT query and return results

        Args:
            query: SQL SELECT query

        Returns:
            List of result rows (as dictionaries)
        """
        if not self.connection:
            BuiltIn().fail("Not connected to database")

        try:
            self.cursor.execute(query)
            self.last_query_result = self.cursor.fetchall()
            BuiltIn().log(f"Query executed: {query}")
            BuiltIn().log(f"Rows returned: {len(self.last_query_result)}")
            return self.last_query_result
        except Exception as e:
            BuiltIn().fail(f"Query execution failed: {str(e)}")

    @keyword
    def execute_update(self, query):
        """Execute INSERT, UPDATE, or DELETE query

        Args:
            query: SQL INSERT/UPDATE/DELETE query

        Returns:
            Number of rows affected
        """
        if not self.connection:
            BuiltIn().fail("Not connected to database")

        try:
            self.cursor.execute(query)
            self.connection.commit()
            rows_affected = self.cursor.rowcount
            BuiltIn().log(f"Update executed: {query}")
            BuiltIn().log(f"Rows affected: {rows_affected}")
            return rows_affected
        except Exception as e:
            self.connection.rollback()
            BuiltIn().fail(f"Update execution failed: {str(e)}")

    @keyword
    def table_row_should_exist(self, table_name, where_clause):
        """Verify that a row exists in the table

        Args:
            table_name: Name of the table
            where_clause: WHERE clause conditions (e.g., 'id = 5 AND name = "test"')
        """
        query = f"SELECT COUNT(*) as count FROM {table_name} WHERE {where_clause}"
        result = self.execute_query(query)

        if result and result[0]["count"] > 0:
            BuiltIn().log(f"Row exists in {table_name} where {where_clause}")
        else:
            BuiltIn().fail(f"No row found in {table_name} where {where_clause}")

    @keyword
    def table_row_should_not_exist(self, table_name, where_clause):
        """Verify that a row does NOT exist in the table

        Args:
            table_name: Name of the table
            where_clause: WHERE clause conditions
        """
        query = f"SELECT COUNT(*) as count FROM {table_name} WHERE {where_clause}"
        result = self.execute_query(query)

        if result and result[0]["count"] == 0:
            BuiltIn().log(f"Row does not exist in {table_name} where {where_clause}")
        else:
            BuiltIn().fail(f"Row found in {table_name} where {where_clause}")

    @keyword
    def table_row_count_should_be(self, table_name, expected_count, where_clause=None):
        """Verify row count in table

        Args:
            table_name: Name of the table
            expected_count: Expected number of rows
            where_clause: Optional WHERE clause
        """
        if where_clause:
            query = f"SELECT COUNT(*) as count FROM {table_name} WHERE {where_clause}"
        else:
            query = f"SELECT COUNT(*) as count FROM {table_name}"

        result = self.execute_query(query)
        actual_count = result[0]["count"] if result else 0

        if actual_count == int(expected_count):
            BuiltIn().log(f"Row count {actual_count} matches expected {expected_count}")
        else:
            BuiltIn().fail(f"Expected {expected_count} rows, but found {actual_count}")

    @keyword
    def table_row_column_value_should_be(
        self, table_name, where_clause, column_name, expected_value
    ):
        """Verify specific column value in a row

        Args:
            table_name: Name of the table
            where_clause: WHERE clause to identify the row
            column_name: Name of the column to check
            expected_value: Expected value
        """
        query = f"SELECT {column_name} FROM {table_name} WHERE {where_clause}"
        result = self.execute_query(query)

        if not result:
            BuiltIn().fail(f"No row found in {table_name} where {where_clause}")

        actual_value = result[0][column_name]
        if str(actual_value) == str(expected_value):
            BuiltIn().log(f"Column {column_name} = {expected_value}")
        else:
            BuiltIn().fail(
                f"Expected {column_name} = {expected_value}, but got {actual_value}"
            )

    @keyword
    def get_table_row_by_id(self, table_name, id_column, id_value):
        """Get a specific row from table by ID

        Args:
            table_name: Name of the table
            id_column: Name of the ID column
            id_value: Value of the ID

        Returns:
            Row data as dictionary
        """
        query = f"SELECT * FROM {table_name} WHERE {id_column} = {id_value}"
        result = self.execute_query(query)

        if not result:
            BuiltIn().fail(
                f"No row found in {table_name} where {id_column} = {id_value}"
            )

        return dict(result[0])

    @keyword
    def get_query_result(self):
        """Get the last query result"""
        return self.last_query_result

    @keyword
    def get_first_row(self):
        """Get the first row from last query result"""
        if not self.last_query_result or len(self.last_query_result) == 0:
            BuiltIn().fail("No query results available")
        return dict(self.last_query_result[0])

    @keyword
    def delete_table_data(self, table_name, where_clause=None):
        """Delete rows from table

        Args:
            table_name: Name of the table
            where_clause: Optional WHERE clause (if not provided, all rows will be deleted)

        Returns:
            Number of rows deleted
        """
        if where_clause:
            query = f"DELETE FROM {table_name} WHERE {where_clause}"
        else:
            BuiltIn().log("WARNING: Deleting all rows from table without WHERE clause")
            query = f"DELETE FROM {table_name}"

        return self.execute_update(query)

    @keyword
    def truncate_table(self, table_name):
        """Truncate table (delete all rows)

        Args:
            table_name: Name of the table
        """
        try:
            query = f"TRUNCATE TABLE {table_name} CASCADE"
            self.cursor.execute(query)
            self.connection.commit()
            BuiltIn().log(f"Table {table_name} truncated")
        except Exception as e:
            self.connection.rollback()
            BuiltIn().fail(f"Failed to truncate table: {str(e)}")

    @keyword
    def verify_record_change(
        self, table_name, id_column, id_value, column_name, old_value, new_value
    ):
        """Verify that a record was changed

        Args:
            table_name: Name of the table
            id_column: Name of the ID column
            id_value: Value of the ID
            column_name: Name of the column that changed
            old_value: Previous value (before change)
            new_value: New value (after change)
        """
        row = self.get_table_row_by_id(table_name, id_column, id_value)
        current_value = row[column_name]

        if str(current_value) == str(new_value):
            BuiltIn().log(
                f"Record {id_column}={id_value} updated: {column_name} changed from {old_value} to {new_value}"
            )
        else:
            BuiltIn().fail(
                f"Expected {column_name} = {new_value}, but got {current_value}"
            )

    @keyword
    def verify_record_created(self, table_name, id_column, id_value):
        """Verify that a new record was created

        Args:
            table_name: Name of the table
            id_column: Name of the ID column
            id_value: Value of the ID
        """
        query = (
            f"SELECT COUNT(*) as count FROM {table_name} WHERE {id_column} = {id_value}"
        )
        result = self.execute_query(query)

        if result and result[0]["count"] > 0:
            BuiltIn().log(f"Record created in {table_name} with {id_column}={id_value}")
        else:
            BuiltIn().fail(
                f"Record not found in {table_name} with {id_column}={id_value}"
            )

    @keyword
    def verify_record_deleted(self, table_name, id_column, id_value):
        """Verify that a record was deleted

        Args:
            table_name: Name of the table
            id_column: Name of the ID column
            id_value: Value of the ID
        """
        query = (
            f"SELECT COUNT(*) as count FROM {table_name} WHERE {id_column} = {id_value}"
        )
        result = self.execute_query(query)

        if result and result[0]["count"] == 0:
            BuiltIn().log(
                f"Record deleted from {table_name} with {id_column}={id_value}"
            )
        else:
            BuiltIn().fail(
                f"Record still exists in {table_name} with {id_column}={id_value}"
            )

    @keyword
    def verify_table_row_matches_expected_data(
        self, table_name, where_clause, expected_data
    ):
        """Verify that all key-value pairs in expected_data match the database record

        Args:
            table_name: Name of the table
            where_clause: WHERE clause to identify the row (e.g., 'film_id = 1001')
            expected_data: Dictionary with expected column-value pairs
        """
        query = f"SELECT * FROM {table_name} WHERE {where_clause}"
        result = self.execute_query(query)

        if not result:
            BuiltIn().fail(f"No row found in {table_name} where {where_clause}")

        actual_row = dict(result[0])
        mismatches = []

        # Compare each expected key-value pair
        for column, expected_value in expected_data.items():
            if column not in actual_row:
                mismatches.append(f"Column '{column}' not found in database row")
                continue

            actual_value = actual_row[column]

            # Convert both to string for comparison (handles different data types)
            if str(actual_value) != str(expected_value):
                mismatches.append(
                    f"Column '{column}': Expected '{expected_value}', but got '{actual_value}'"
                )

        if mismatches:
            error_msg = (
                f"Database validation failed for {table_name} where {where_clause}:\n"
            )
            error_msg += "\n".join(mismatches)
            BuiltIn().fail(error_msg)
        else:
            BuiltIn().log(
                f"All {len(expected_data)} expected values match in {table_name} where {where_clause}"
            )
