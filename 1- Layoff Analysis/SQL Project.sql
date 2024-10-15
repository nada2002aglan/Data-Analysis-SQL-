USE world_layoffs;
-- Data Cleaning using mySQL
SELECT *
FROM layoffs;

-- Steps needed to be applied:
-- 1-Remove duplicates
-- 2-Standardiza the data
-- 3-Remove null or blank values
-- 4- Remove irrelevant coloumns.


-- STEP 1: Remove Duplicates.
-- we will create a duplicate table of our oeiginal data to work on to avoid data loss or any mistake.

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;
-- here we can see that we copied the meta data correctly now we need to populate the database with original data records

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- the following quiery find the duplicates by creating a new column 
-- that count the number of similar rows and if any number above 1 exists in the column that means the row has n duplicates.
-- 5 rows were found as duplicates
with duplicate_cte AS
(
SELECT *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;


-- now we want to delete the duplicates but we have a problem
-- CTE (Common Table Expression) won't run DML operation if there's no unique identifier like ID
-- if ID exixsts we could've removed the rows with ID == the IDs in the cte results.
-- we can solve this by creating a new version of our table with row_num as a column then we can delete any row with row_num>1.

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging3
WHERE row_num>1;

INSERT INTO layoffs_staging3
SELECT *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) AS row_num
FROM layoffs_staging;

SET SQL_SAFE_UPDATES = 0;   -- this line just to change mysql saftey settings to enable delete operation

DELETE
FROM layoffs_staging3
WHERE row_num>1;



-- STEP 2: standardization
-- Standardization cases are like(white spaces at the begining of the words, if two words with the same meaning are written with differnet spelling,...)

SELECT DISTINCT company
FROM layoffs_staging3;  -- here we can find white spaces so we gotta update this column.

UPDATE layoffs_staging3
SET company = TRIM(company);   -- it worked!

SELECT DISTINCT industry
FROM layoffs_staging3
order by 1;   -- here we can find that there's (Crypto, Crypto Currency, CryptoCurrency) that has the same meaing but has a differnet names.

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';   -- it worked!

SELECT DISTINCT country
FROM layoffs_staging3
order by 1;   -- here we have ('United States', 'United States.') that has the same meaning

UPDATE layoffs_staging3
SET country = 'United States'
WHERE country LIKE 'United States%';  -- it worked!

SELECT DISTINCT `date`
FROM layoffs_staging3; -- here the date column is a text data type so we'll change it to date.

UPDATE layoffs_staging3
SET `date` = str_to_date(`date`, '%m/%d/%Y');  -- it did made the date in mysql date format but still the column has a text data type

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;   -- it worked!




-- STEP 3: Solve NULL and blank values
SELECT *
FROM layoffs_staging3
WHERE industry IS NULL
OR industry = "";     -- here we can find 3 blank values and 1 NULL value, we'll try to populate'em

SELECT *
FROM layoffs_staging3
WHERE company = "Airbnb" OR company = "Carvana" OR company = "Juul" OR company LIKE 'Bally%';   -- here we find that the industry of some companies exists so we'll populate the missing values with these ones.

SELECT t1.industry, t2.industry
from layoffs_staging3 t1
JOIN layoffs_staging3 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3
SET industry = NULL
WHERE industry = "";


UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;   -- it worked!
-- we can't populate the missing values in (total_laid_off, percentage_laid_off) cuz we don't have the total laid_off
SELECT * 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;  -- now we need to drop them

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;  -- it worked!




-- STEP 4: Remove irrelevant coloumns
-- we need to drop the row_num column cuz it wasn't in the original data
ALTER TABLE layoffs_staging3
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging3;




-- EDA Step
-- we'll do this by answering some questions about the data

-- What's the max laid off and max percentage of laid off?
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging3;


-- what's the sum of laid-off of each company in a sescinding order?
SELECT company, SUM(total_laid_off) AS 'Total Layoff'
FROM layoffs_staging3
WHERE total_laid_off IS NOT NULL
GROUP BY 1;


-- what industries hit the most layoff?
SELECT industry, SUM(total_laid_off) AS 'Total Layoff'
FROM layoffs_staging3
WHERE total_laid_off IS NOT NULL
GROUP BY 1
ORDER BY SUM(total_laid_off) DESC;


-- which country has the most layoff?
SELECT country, SUM(total_laid_off) AS 'Total Layoff'
FROM layoffs_staging3
WHERE total_laid_off IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- what's the date range we're having in our dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging3;    -- this sounds like the covid-19 era


-- what's the total layoff of each year?
SELECT YEAR(`date`), SUM(total_laid_off) AS 'Total Layoff'
FROM layoffs_staging3
WHERE YEAR(`date`) IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;


-- what's the total layoff by month?
SELECT substring(`date`,1, 7), SUM(total_laid_off) AS 'Total Layoff'
FROM layoffs_staging3
WHERE YEAR(`date`) IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;


-- find the rolling total layoff by month (the cumulative sum of total layoff).
WITH total_layoff AS(
SELECT substring(`date`,1, 7) AS `MONTH`, SUM(total_laid_off) AS 'Total Layoff'
FROM layoffs_staging3
WHERE substring(`date`,1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC
)
SELECT `MONTH`,`Total Layoff`, SUM(`Total Layoff`) OVER(ORDER BY `MONTH`)
FROM total_layoff;


-- find total layoff for each company by year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY 1,2
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 1 ASC;


-- do a ranking of which year does each company laid off most of its employees
WITH company_year (company, years, total_laid_off)AS(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY 1,2
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 1 ASC
)
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off ) AS Ranking
FROM company_year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;


-- filter the ranking to get the top 5 companies of total layoff of each year
WITH company_year (company, years, total_laid_off)AS(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY 1,2
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 1 ASC
), company_year_ranking AS(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off ) AS Ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_ranking
WHERE Ranking <= 5;

-- find the percentage of laid off employees for each company according to the funds they raised
SELECT company, AVG(percentage_laid_off) AS layoff_percentage, MAX(funds_raised_millions) AS funds
FROM layoffs_staging3
Where percentage_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL
GROUP BY 1
ORDER BY 3 DESC;


-- find the percentage of layoff for each stage 
SELECT DISTINCT stage, ROUND(AVG(percentage_laid_off), 2) AS lay_off_percentage
FROM layoffs_staging3
Where percentage_laid_off IS NOT NULL AND stage IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

































