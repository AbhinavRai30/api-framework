DELETE FROM film
WHERE film_id IN (
    WITH DuplicateCTE AS (
        SELECT
            film_id
        FROM (
            SELECT
                film_id,
                ROW_NUMBER() OVER (
                    PARTITION BY title -- Columns that define a duplicate
                    ORDER BY film_id -- Column to decide which one to keep
                ) AS RowNumber
            FROM
                film
        ) AS s
        WHERE
            RowNumber > 1
    )
    SELECT film_id FROM DuplicateCTE
);
