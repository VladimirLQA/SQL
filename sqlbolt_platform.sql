List all movies that were released on even number years 

SELECT title, year FROM movies
    WHERE year % 2 = 0;
---------------------------------------------------------------------------------------------------------------------------------------
Find the total number of years employed by all Engineers

SELECT role, SUM(years_employed) FROM employees
    GROUP BY role
        HAVING role = "Engineer";
---------------------------------------------------------------------------------------------------------------------------------------
Find the total domestic and international sales that can be attributed to each director 

SELECT director, SUM(Domestic_sales + International_sales) as total_sum FROM movies
    JOIN  boxoffice
        ON movies.id = boxoffice.movie_id
            GROUP BY director;
---------------------------------------------------------------------------------------------------------------------------------------
Both the title and director for Toy Story 8 is incorrect! The title should be "Toy Story 3" and it was directed by Lee Unkrich

UPDATE movies
    SET title = "Toy Story 3", 
        director = "Lee Unkrich"
            WHERE id = 11;