CREATE DATABASE IF NOT EXISTS Netflix;
USE Netflix;
SELECT * 
FROM netflix_titles; 

-- Drop the unwanted columns.
ALTER TABLE netflix_titles
DROP  description;

-- Drop the null columns.
DELETE FROM netflix_titles
WHERE show_id IS NULL
OR type IS NULL
OR title IS NULL
OR director IS NULL
OR cast IS NULL
OR country IS NULL
OR date_added IS NULL
OR release_year IS NULL
OR rating IS NULL
OR duration IS NULL
OR listed_in IS NULL;


-- Finding the duplicates value in table.
SELECT *, COUNT(*) AS count
FROM netflix_titles
GROUP BY show_id, type, title,director,cast, country, date_added, release_year, rating, duration, listed_in
HAVING COUNT(*)>1; 
-- We have no duplicate values in the table.


-- Converting the date columns into date format from text.
  
ALTER TABLE netflix_titles
ADD COLUMN date_added1 DATE;
UPDATE netflix_titles
SET date_added1= STR_TO_DATE(date_added,'%M %d,%Y');
ALTER TABLE netflix_titles
MODIFY release_year YEAR;
ALTER TABLE netflix_titles
DROP date_added;
ALTER TABLE netflix_titles
CHANGE date_added1 date_added DATE;

-- DATA IS PREPROCESSED AND READY FOR RETRIEVING THE INSIGHTS.
-- Now we retrieve the insights from our cleaned datasets.

-- 1. Count the number of Movies vs TV Shows.
SELECT
COUNT(CASE WHEN type = "Movie" then 1 END) AS movies_count,
COUNT(CASE WHEN type="TV show" THEN 1 END ) AS TV_show
FROM netflix_titles;

-- 2. Find the most common rating for movies and TV shows
SELECT MAX(rating) AS common_rating
FROM netflix_titles;

-- 3.List all movies released in a specific year (e.g., 2020,2021) 
SELECT release_year, title
FROM netflix_titles
WHERE type="Movie" AND release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix.

WITH RECURSIVE country_split AS (
  -- Step 1: Assign a unique ID to each row
  SELECT show_id, title, country,
         1 AS pos,
         SUBSTRING_INDEX(country, ',', 1) AS single_country
  FROM netflix_titles
  WHERE country IS NOT NULL

  UNION ALL

  -- Step 2: Recursively split the remaining countries
  SELECT cs.show_id,
         cs.title,
         cs.country,
         pos + 1,
         TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cs.country, ',', pos + 1), ',', -1)) AS single_country
  FROM country_split cs
  WHERE pos < LENGTH(cs.country) - LENGTH(REPLACE(cs.country, ',', '')) + 1
)

SELECT single_country AS country,
       COUNT(*) AS total_titles
FROM country_split
GROUP BY single_country
ORDER BY total_titles DESC
LIMIT 5;

-- 5. Identify the longest movie 
SELECT title, duration
FROM netflix_titles
WHERE type="Movie"
HAVING duration=(SELECT MAX(Duration) FROM netflix_titles);

-- 6. Find content added in the last 5 years.
SELECT *
FROM netflix_titles
WHERE date_added>=Curdate()- INTERVAL 5 year 
AND type="Movie";

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT type, title
FROM netflix_titles
WHERE director="Rajiv chilaka";

-- 8. List all TV shows with more than 5 seasons.
SELECT title, duration
FROM netflix_titles
WHERE type="TV show"
AND duration>="5 seasons";  

-- 9. Count the number of content items in each genre.
SELECT COUNT(*) AS content_items , listed_in AS genre
FROM netflix_titles 
GROUP BY genre
ORDER BY COUNT(*) DESC;

-- 10.Find each year and the average numbers of content release in India on netflix. 
SELECT AVG(title_count) AS avg_release
FROM (
    SELECT release_year, COUNT(*) AS title_count
    FROM netflix_titles
    WHERE country LIKE '%India%'
    GROUP BY release_year
) AS yearly_counts;
 