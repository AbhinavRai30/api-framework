SELECT  title, COUNT(*) AS CountOfDuplicates
FROM film
GROUP BY title
HAVING COUNT(*) > 1
Order by COUNT(*) DESC