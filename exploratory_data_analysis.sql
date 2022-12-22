-- figure out how many rows are in fortune500
SELECT COUNT(*)
From fortune500;

-- count missing values
SELECT COUNT(*) - COUNT(ticker) AS misssing
FROM fortune500

SELECT COUNT(*) - COUNT(profits_change) AS misssing
FROM fortune500;

SELECT COUNT(*) - COUNT(industry) AS misssing
FROM fortune500;

-- Joint tables
SELECT company.name
FROM company
INNER JOIN fortune500
ON company.ticker = fortune500.ticker;

-- cek duplikat
SELECT tag, COUNT(tag) d
FROM stackoverflow
GROUP BY tag
HAVING COUNT(tag)>1

-- What is the most common stackoverflow tag_type?
-- Count the number of tags with each type
SELECT type, count(tag) AS count
FROM tag_type
 -- To get the count for each type, what do you need to do?
GROUP BY type
 -- Order the results with the most common
 -- tag types listed first
ORDER BY COUNT DESC;

-- What companies have a tag of that type?
-- Read an entity relationship diagramp
-- select the 3 coloums desired
SELECT company.name, tag_type.tag, tag_type.type
from company
-- 	join to the tag_company table
INNER JOIN tag_company
ON company.id = tag_company.company_id
-- join the tag_type table
INNER JOIN tag_type
ON tag_company.tag = tag_type.tag
-- filter the most common type
WHERE type='cloud';

-- Use coalesce() to use the value of sector as the industry
-- when industry is NULL. Then find the most common industry
SELECT coalesce(industry, sector, 'Unknown') AS industry2,
       -- Don't forget to count!
       count(*) 
FROM fortune500 
GROUP BY industry2
-- Order results to see most common first
ORDER BY COUNT DESC
-- Limit results to get just the one value you want
LIMIT 3;
 
SELECT company_original.name, title, rank
  -- Start with original company information
FROM company AS company_original
       -- Join to another copy of company with parent
       -- company information
	   LEFT JOIN company AS company_parent
       ON company_original.parent_id = company_parent.id 
       -- Join to fortune500, only keep rows that match
       inner JOIN fortune500 
       -- Use parent ticker if there is one, 
       -- otherwise original ticker
       ON coalesce(company_parent.ticker, 
                   company_original.ticker) = 
             fortune500.ticker
 -- For clarity, order by rank
 ORDER BY rank;
 
-- Summarizing and aggregating numeric data

-- Select average revenue per employee by sector
-- use casting to produce a numeric result
SELECT sector, 
       avg(revenues/employees::numeric) AS avg_rev_employee
-- 	   Compute revenue per employee by dividing revenues by employees
FROM fortune500
GROUP BY sector
 -- Use the column alias to order the results
ORDER BY avg_rev_employee;
 
 -- Select min, avg, max, and stddev of fortune500 profits
SELECT min(profits),
       avg(profits),
       max(profits),
       stddev(profits)
FROM fortune500;
   
 -- Select sector and summary measures of fortune500 profits
SELECT min(profits),
       avg(profits),
       max(profits),
       stddev(profits),
       sector
  FROM fortune500
 -- What to group by?
 GROUP BY sector
 -- Order by the average profits
 ORDER BY avg;

-- Compute standard deviation of maximum values
SELECT stddev(maxval),
       -- min
       min(maxval),
       -- max
       max(maxval),
       -- avg
       avg(maxval)
-- Subquery to compute max of question_count by tag
FROM (SELECT max(question_count) AS maxval
FROM stackoverflow
         -- Compute max by...
GROUP BY tag) AS max_results; -- alias for subquery


-- Truncate employees
SELECT trunc(employees, -4) AS employee_bin,
       -- Count number of companies with each truncated value
       count(*)
FROM fortune500
 -- Limit to which companies?
WHERE employees < 100000
 -- Use alias to group
GROUP BY employee_bin
 -- Use alias to order
ORDER BY employee_bin;
 
 -- Correlation between revenues and profit
SELECT  corr(revenues,profits)AS rev_profits,
	   -- Correlation between revenues and assets
       corr(revenues,assets) AS rev_assets,
       -- Correlation between revenues and equity
       corr(revenues,equity) AS rev_equity 
FROM fortune500;

-- What groups are you computing statistics by?
SELECT sector,
       -- Select the mean of assets with the avg function
       avg(assets)AS mean,
      -- Select the median
       percentile_disc(0.5) within group (order by assets) AS median
FROM fortune500
 -- Computing statistics for each what?
GROUP BY sector
 -- Order results by a value of interest
ORDER BY median;

-- To clear table if it already exists;
-- fill in name of temp table
DROP TABLE IF EXISTS profit80;

-- Find the Fortune 500 companies that have profits in the top 20%
-- for their sector (compared to other Fortune 500 companies).
-- Create the temporary table

CREATE TEMP TABLE profit80 AS 
  -- Select the two columns you need; alias as needed
SELECT sector, 
-- find the 80th percentile of profit for each sector
         percentile_disc(0.8) within group (order by profits) AS pct80
-- What table are you getting the data from?
FROM fortune500
-- What do you need to group by?
GROUP BY sector;

-- select companies that have profits greater than pct80
-- Select columns, aliasing as needed
SELECT title, profit80.sector, 
       profits, profits/pct80 AS ratio
-- What tables do you need to join?  
FROM fortune500 
LEFT JOIN profit80
-- How are the tables joined?
ON fortune500.sector=profit80.sector
-- What rows do you want to select?
WHERE profits > pct80;   
-- See what you created: select all columns and rows 
-- from the table you created
SELECT * FROM profit80;

-- To clear table if it already exists
DROP TABLE IF EXISTS startdates;
-- Create temp table syntax
CREATE TEMP TABLE stardates AS
-- find the starting date for all tag
-- Compute the minimum date for each what?
SELECT tag,
       min(date) AS mindate
FROM stackoverflow
 -- What do you need to compute the min date for each tag?
GROUP BY tag;
 
 -- Look at the table you created
SELECT * FROM stardates;


-- Exploring categorical data and unstructured text
-- Select the count of each level of priority
-- How many rows does each priority level have?
SELECT priority, COUNT(*)
FROM evanston311
GROUP BY priority;

-- How many distinct values of zip appear in at least 100 rows?
-- Find values of zip that appear in at least 100 rows
-- Also get the count of each value
SELECT distinct zip, count(*)
FROM evanston311
GROUP BY zip
HAVING count(*) > 100; 

-- Find values of source that appear in at least 100 rows
-- Also get the count of each value
SELECT distinct source, count(*)
FROM evanston311
group by source
having count(*) > 100;

-- Find the 5 most common values of street and the count of each
SELECT street, count(*)
FROM evanston311
group by street
order by count(*) desc
limit 5;

-- Trimming
SELECT distinct street,
       -- Trim off unwanted characters from street
       trim(street,'0123456789 #/.') AS cleaned_street
FROM evanston311
ORDER BY street;

-- Exploring unstructured text
-- Count rows
SELECT count(*)
FROM evanston311
 -- Where description includes trash or garbage
WHERE description ILIKE '%trash%'
or description Ilike '%garbage%';

-- Select categories containing Trash or Garbage
SELECT category
FROM evanston311
 -- Use LIKE
WHERE category LIKE '%Trash%'
OR category LIKE '%Garbage%';

-- Count rows where the description includes 'trash' 
-- or 'garbage' but the category does not.
SELECT count(8)
FROM evanston311 
 -- description contains trash or garbage (any case)
WHERE (description ILIKE '%garbage%'
OR description ILIKE '%Trash%') 
 -- category does not contain Trash or Garbage
AND category NOT LIKE '%Trash%'
AND category NOT LIKE '%Garbage%';
 
-- Find the most common categories for rows with a
-- description about trash that don't have a trash-related category
SELECT category, count(*)
FROM evanston311 
WHERE (description ILIKE '%trash%'
OR description ILIKE '%garbage%') 
AND category NOT LIKE '%Trash%'
AND category NOT LIKE '%Garbage%'
 -- What are you counting?
GROUP BY category
 --- order by most frequent values
ORDER BY count  desc
LIMIT 10;

-- Concatenate house_num, a space, and street
-- and trim spaces from the start of the result
SELECT ltrim(concat(house_num, ' ', street)) AS address
FROM evanston311;

-- Extract just the first word of each street value to find
-- the most common streets regardless of the suffix.
SELECT split_part(street, ' ', 1) AS street_name, 
       count(*)
FROM evanston311
GROUP BY street_name
ORDER BY count DESC
LIMIT 20;

-- The description column of evanston311 can be very long. 
-- You can get the length of a string with the length() function
-- Select the first 50 chars when length is greater than 50
SELECT CASE WHEN length(description) > 50
            THEN left(description, 50) || '...'
       -- otherwise just select description
       ELSE description
       END
FROM evanston311
 -- limit to descriptions that start with the word I
WHERE description LIKE 'I %'
ORDER BY description;

-- Group and recode values
-- There are almost 150 distinct values of evanston311.category
-- But some of these categories are similar, with the form "Main
-- Category - Details". We can get a better sense of what
-- requests are common if we aggregate by the main category.
-- To do this, create a temporary table recode mapping distinct
-- category values to new, standardized values. Make the
-- standardized values the part of the category before a dash ('-')
-- Extract this value with the split_part() function:
-- split_part(string text, delimiter text, field int)

-- Fill in the command below with the name of the temp table
DROP TABLE IF EXISTS recode;

-- Create and name the temporary table
CREATE temp table recode AS
-- Write the select query to generate the table 
-- with distinct values of category and standardized values
SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
    -- What table are you selecting the above values from?
FROM evanston311;
    
-- Look at a few values before the next step
SELECT DISTINCT standardized 
FROM recode
WHERE standardized LIKE 'Trash%Cart'
OR standardized LIKE 'Snow%Removal%';


-- Code from previous step
DROP TABLE IF EXISTS recode;

CREATE TEMP TABLE recode AS
  SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
    FROM evanston311;

-- Update to group trash cart values
UPDATE recode 
SET standardized='Trash Cart' 
WHERE standardized LIKE 'Trash%Cart';

-- Update to group snow removal values
UPDATE recode 
set standardized='Snow Removal' 
WHERE  standardized LIKE 'Snow%Removal%';
    
-- Examine effect of updates
SELECT DISTINCT standardized, category 
FROM recode 
WHERE standardized LIKE 'Trash%Cart'
OR standardized LIKE 'Snow%Removal%';

-- join the evanston311 and recode tables to count the number of
-- requests with each of the standardized values
-- Code from previous step
DROP TABLE IF EXISTS recode;
CREATE TEMP TABLE recode AS
SELECT DISTINCT category, 
         rtrim(split_part(category, '-', 1)) AS standardized
FROM evanston311;
UPDATE recode SET standardized='Trash Cart' 
WHERE standardized LIKE 'Trash%Cart';
UPDATE recode SET standardized='Snow Removal' 
WHERE standardized LIKE 'Snow%Removal%';
UPDATE recode SET standardized='UNUSED' 
WHERE standardized IN ('THIS REQUEST IS INACTIVE...Trash Cart', 
               '(DO NOT USE) Water Bill',
               'DO NOT USE Trash', 'NO LONGER IN USE');

-- Select the recoded categories and the count of each
SELECT standardized, count(*)
-- From the original table and table with recoded values
FROM evanston311
       left JOIN recode 
       -- What column do they have in common?
       ON evanston311.category=recode.category
        -- What do you need to group by to count?
GROUP BY standardized
 -- Display the most common val values first
ORDER By count desc;


-- Create a table with indicator variables
-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the indicators temp table
Create temp table indicators AS
SELECT id, 
         -- Create the email indicator (find @)
         CAST (description LIKE '%@%' AS integer) AS email,
         -- Create the phone indicator
         CAST (description LIKE '%___-___-___%' AS integer) AS phone      
FROM evanston311;

-- Inspect the contents of the new temp table
SELECT *
FROM indicators;
  
-- To clear table if it already exists
DROP TABLE IF EXISTS indicators;

-- Create the temp table
CREATE TEMP TABLE indicators AS
SELECT id, 
         CAST (description LIKE '%@%' AS integer) AS email,
         CAST (description LIKE '%___-___-____%' AS integer) AS phone 
FROM evanston311;
  
-- Select the column you'll group by
SELECT priority,
       -- Compute the proportion of rows with each indicator
       sum(email)/count(*)::numeric AS email_prop, 
       sum(phone)/count(*)::numeric AS phone_prop
  -- Tables to select from
FROM evanston311
LEFT JOIN indicators
 -- Joining condition
ON evanston311.id = indicators.id
 -- What are you grouping by?
GROUP BY priority;

-- Working with dates and timestamps
-- Date comparisons
SELECT count(*) 
FROM evanston311
WHERE date_created = '2018-01-02';
-- returns 0, even though there were 49 requests on January 2, 2018.
-- This is because dates are automatically converted to timestamps
-- when compared to a timestamp. The time fields are all set to zero

-- Count requests created on January 31, 2017
SELECT count(*) 
FROM evanston311
WHERE date_created::date ='2017-1-31';

-- Count requests created on February 29, 2016
SELECT count(*)
FROM evanston311 
WHERE date_created >= '2016-02-29' 
AND date_created < '2016-03-01';

-- Count requests created on March 13, 2017
SELECT count(*)
FROM evanston311
WHERE date_created >= '2017-03-13'
AND date_created < '2017-03-13'::date + 1;

-- Date arithmetic
-- You can subtract dates or timestamps from each other.
-- You can add time to dates or timestamps using intervals.
-- An interval is specified with a number of units and
-- the name of a datetime field. For example:'3 days'::interval
-- '6 months'::interval

-- Subtract the min date_created from the max
SELECT MAX(date_created) - MIN(date_created)
FROM evanston311;

-- How old is the most recent request?
SELECT NOW()-MAX(date_created)
FROM evanston311;

-- Add 100 days to the current timestamp
SELECT now() + '100 days'::interval;

-- Select the current timestamp, 
-- and the current timestamp + 5 minutes
SELECT now() + '5 minutes'::interval;


-- Completion time by category
-- Which category of Evanston 311 requests takes the longest to complete?
-- Select the category and the average completion time by category
SELECT category, 
       AVG(date_completed - date_created) AS completion_time
FROM evanston311
GROUP BY category
-- Order the results
ORDER BY completion_time DESC;

-- The date_part() function is useful when you wantto aggregate
-- data by a unit of timeacross multiple larger units of time
-- For example, aggregating data by month across different years
-- or aggregating by hour across different days

-- How many requests are created in each of the 12 months during 2016-2017?
-- Extract the month from date_created and count requests
SELECT date_part('month', date_created) AS month, 
       count(*)
FROM evanston311
 -- Limit the date range
WHERE date_created >= '2016-01-01'
AND date_created < '2018-01-01'
 -- Group by what to get monthly counts?
GROUP BY month;

-- What is the most common hour of the day for requests to be created?
-- Get the hour and count requests
SELECT date_part('hour', date_created) AS hour,
       count(*)
FROM evanston311
GROUP BY hour
 -- Order results to select most common
ORDER BY count DESC
LIMIT 1;

-- During what hours are requests usually completed?
-- Count requests completed by hour
SELECT date_part('hour', date_completed) AS hour,
       count(*)
FROM evanston311
GROUP BY hour
ORDER BY count DESC;

-- Variation by day of week
-- Does the time required to complete a request vary
-- by the day of the week on which the request was created?
-- We can get the name of the day of the week by converting a
-- timestamp to character data
-- Select name of the day of the week the request was created 
SELECT to_char(date_created, 'day') AS day, 
       -- Select avg time between request creation and completion
       avg(date_completed - date_created) AS duration
FROM evanston311 
 -- Group by the name of the day of the week and 
 -- integer value of day of week the request was created
GROUP BY day, EXTRACT(DOW FROM date_created)
 -- Order by integer value of the day of the week 
 -- the request was created
ORDER BY EXTRACT(DOW FROM date_created);

-- Using date_trunc(), find the average number of Evanston 311
-- requests created per day for each month of the data
-- Aggregate daily counts by month
SELECT date_trunc('month',day) AS month,
       avg(count)
  -- Subquery to count the number of requests created per day.
FROM (SELECT date_trunc('day',date_created) AS day,
               count(*) AS count
		FROM evanston311
        GROUP BY day) AS daily_count
GROUP BY month
ORDER BY month;

-- Find missing dates
-- The generate_series() function can be usefulfor identifying
-- missing dates generate_series(from, to, interval)
-- Are there any days in the Evanston 311 data where no requests were created?

SELECT day
-- 1) Subquery to generate all dates
-- from min to max date_created
FROM (SELECT generate_series(min(date_created),
                               max(date_created),
                               '1 day')::date AS day
          -- What table is date_created in?
       FROM evanston311) AS all_dates
-- 4) Select dates (day from above) that are NOT IN the subquery
WHERE day NOT IN 
       -- 2) Subquery to select all date_created values as dates
       (SELECT date_created::date
        FROM evanston311);





