-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates; if any
-- 2. Standardize the Data; if issues (like spelling), we'll standardize so all is same
-- 3. Null Values or blank values
-- 4. Remove Any Columns - irrelevant information;

# --staging is where I'm changing data, if I mess up I can revert back to layoffs - the raw data
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

# --1.  Removing Duplicates
SELECT *,
row_number() over(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
row_number() over(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT *
FROM layoffs_staging_2
;

WITH duplicate_cte AS
(
SELECT *,
row_number() over(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num >1;

CREATE TABLE `layoffs_staging_2` (
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

CREATE TABLE `layoffs_staging_2` (
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

INSERT INTO layoffs_staging_2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging_2;

DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

# 2. -- Standardizing Data
# Finding issues in our data and then fixing it

SELECT company, TRIM(company)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry Like 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging_2
;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT *
FROM layoffs_staging_2;

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging_2;

# -- 3. Working with Nulls & Blank Values

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Bally%';

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

# --4. Remove Columns & Rows

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging_2;

ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;


