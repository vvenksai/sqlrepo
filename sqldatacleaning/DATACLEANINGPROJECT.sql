-- Selecting all records from layoffs table
USE world_layoffs;
SELECT *
FROM layoffs;

-- Creating a duplicate table for data cleaning
CREATE TABLE laysoff_staging
LIKE layoffs;

-- Checking the structure of the new table
SELECT *
FROM laysoff_staging;

-- Inserting data into staging table
INSERT laysoff_staging
SELECT *
FROM layoffs;

-- Counting occurrences of each company in the dataset
SELECT company, COUNT(stage)
FROM laysoff_staging
GROUP BY company;

-- Checking data for a specific company
SELECT *
FROM laysoff_staging
WHERE company = 'Oda';

-- Identifying duplicate records using ROW_NUMBER()
SELECT *,
ROW_NUMBER () OVER( 
PARTITION BY company, location,industry,total_laid_off, 
percentage_laid_off,`date`, stage, country, 
funds_raised_millions) AS row_numb
FROM laysoff_staging;

-- Finding duplicate records
WITH duplicte_cte AS
(
SELECT *,
ROW_NUMBER () OVER( 
PARTITION BY company, location,industry,total_laid_off, 
percentage_laid_off,`date`, stage, country, 
funds_raised_millions) AS row_numb
FROM laysoff_staging
)
SELECT *
FROM duplicte_cte
WHERE row_numb > 1;

-- Checking for duplicates in another company
SELECT *
FROM laysoff_staging
WHERE company = 'Casper';

-- Finding and removing duplicate rows
WITH duplicte_cte AS
(
SELECT *,
ROW_NUMBER () OVER( 
PARTITION BY company, location,industry,total_laid_off, 
percentage_laid_off,`date`, stage, country, 
funds_raised_millions) AS row_num
FROM laysoff_staging
)
SELECT *
FROM duplicte_cte
WHERE row_num > 1;

-- Creating a second staging table for further cleaning
CREATE TABLE `laysoff_staging2` (
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
);

-- Checking data in the new table
SELECT *
FROM laysoff_staging2;

-- Populating laysoff_staging2 with de-duplicated data
INSERT INTO laysoff_staging2
SELECT *,
ROW_NUMBER () OVER( 
PARTITION BY company, location,industry,total_laid_off, 
percentage_laid_off,`date`, stage, country, 
funds_raised_millions) AS row_num
FROM laysoff_staging;

-- Identifying duplicate records
SELECT *
FROM laysoff_staging2
WHERE row_num > 1; 

-- Disabling safe updates to allow deletion
SET SQL_SAFE_UPDATES = 0;

-- Removing duplicate records
DELETE
FROM laysoff_staging2
WHERE row_num > 1;

-- Re-enabling safe updates
SET SQL_SAFE_UPDATES = 1;

-- Checking cleaned data
SELECT *
FROM laysoff_staging2;

-- Standardizing company names by trimming spaces
UPDATE laysoff_staging2 
SET company = TRIM(company);

-- Standardizing industry names
UPDATE laysoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardizing country names by removing trailing characters
UPDATE laysoff_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

UPDATE laysoff_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';
 
-- Changing date column to DATETIME format
ALTER TABLE laysoff_staging2 
MODIFY date DATETIME;

-- Converting date format
UPDATE laysoff_staging2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y');

-- Identifying null or missing values in key columns
SELECT *
FROM laysoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Identifying missing industry values
SELECT *
FROM laysoff_staging2
WHERE industry IS NULL
OR industry = '';

-- Filling missing industry values based on other records
UPDATE laysoff_staging2 t1
JOIN laysoff_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- Deleting records with missing key values
DELETE
FROM laysoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Dropping the row_num column as it's no longer needed
ALTER TABLE laysoff_staging2 
DROP COLUMN row_num;

-- Final cleaned dataset
SELECT *
FROM laysoff_staging2;
