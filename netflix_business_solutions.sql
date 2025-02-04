--1. Count the Number of Movies vs TV Shows
SELECT DISTINCT(type), count(*) as total_content
FROM netflix
group by 1;

--2. Find the Most Common Rating for Movies and TV Shows

with Rating_counts AS(
SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
	),
Ranked_Ratings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM Rating_counts
	)
SELECT 
    type,
    rating AS most_frequent_rating,
	rating_count
FROM Ranked_Ratings
WHERE rank = 1;

--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT title
from netflix
WHERE type = 'Movie'
and release_year = 2020;

--4. Find the Top 5 Countries with the Most Content on Netflix
--Since we have csv in some records, we have to initially convert the string into an array 
select new_country_list, count(*) as no_of_movies
from
(select UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country_list
from netflix)
group by 1
order by 2 desc
limit 5;

--5. Identify the Longest Movie
select type, title, duration
from netflix 
where type = 'Movie'
AND duration is not NULL
order by SPLIT_PART(duration, ' ', 1)::INT DESC
limit 1;

--6. Find Content Added in the Last 5 Years
select current_date - INTERVAL '5 Years';

select type,title,date_added
from netflix 
where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS'

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select type, title, director
from 
(select *, UNNEST(STRING_TO_ARRAY(director, ',')) as distinct_director_name
from netflix
)
where distinct_director_name = 'Rajiv Chilaka';

select type, title, director
FROM netflix
where director LIKE ('%Rajiv Chilaka%') --ILIKE for non case sensitive records

--8. List All TV Shows with More Than 5 Seasons
select type, title, duration
from netflix
where SPLIT_PART(duration, ' ', 1)::INT > 5
and type = 'TV Show'

--9. Count the Number of Content Items in Each Genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix 
GROUP BY 1;

--10.Find each year and the average numbers of content release in India on netflix.
select release_year, count(*)
from netflix
where country ilike ('%India%')
group by 1
order by 1 desc

--11. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select * 
from netflix 
where casts ilike ('%Salman Khan%')
and release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country ilike ('%India%')
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10; 

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
