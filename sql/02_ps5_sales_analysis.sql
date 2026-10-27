/*
=========================================================
PROJECT: PlayStation 5 Quarterly Hardware Sales Analysis
TOOL: MySQL Workbench
DATA SOURCE: Sony Interactive Entertainment
PERIOD: FY2020 Q3 – FY2026 Q1

RESEARCH QUESTION:
How have PS5 hardware sales changed throughout the
console's lifecycle?

OBJECTIVES:
1. Validate quarterly sales data.
2. Analyze annual hardware sales.
3. Identify peak sales periods.
4. Examine seasonal sales patterns.
5. Calculate quarterly and annual growth.
6. Evaluate PS5 lifecycle trends.
=========================================================
*/

-- Select the project database
USE playstation_analysis;


-- =========================================
-- 1. DATA VALIDATION
-- =========================================

-- Retrieve all quarterly sales observations
SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
    units_sold,
    source
FROM ps5_quarterly_sales
ORDER BY period_end;

-- Count observations and calculate total PS5 units
SELECT
    COUNT(*) AS total_quarters,
	SUM(units_sold) AS total_units_sold,
	ROUND(
        SUM(units_sold) / 1000000,
        2
    ) AS total_units_millions
FROM ps5_quarterly_sales;

-- Identify missing values in essential columns
SELECT
    SUM(fiscal_year IS NULL) AS missing_years,
	SUM(fiscal_quarter IS NULL) AS missing_quarters,
	SUM(period_end IS NULL) AS missing_dates,
	SUM(units_sold IS NULL) AS missing_sales
FROM ps5_quarterly_sales;

-- Identify duplicate fiscal-year and quarter combinations
SELECT
    fiscal_year,
    fiscal_quarter,
    COUNT(*) AS record_count
FROM ps5_quarterly_sales
GROUP BY
    fiscal_year,
    fiscal_quarter
HAVING COUNT(*) > 1;


-- =========================================
-- 2. ANNUAL SALES ANALYSIS
-- =========================================

-- Question 1: Which fiscal year recorded the highest PS5 hardware sales?

-- Calculate total PS5 hardware sales by fiscal year
SELECT
    fiscal_year,
	COUNT(*) AS quarters_reported,
	SUM(units_sold) AS annual_units_sold,
	ROUND(
        SUM(units_sold) / 1000000,
        2
    ) AS annual_sales_millions
FROM ps5_quarterly_sales
GROUP BY fiscal_year
ORDER BY fiscal_year;

-- Question 2: Which individual quarter recorded the strongest PS5 hardware sales?
-- Rank all quarters by hardware sales
SELECT
    fiscal_year,
    fiscal_quarter,
	ROUND(
        units_sold / 1000000,
        2
    ) AS sales_millions
FROM ps5_quarterly_sales
ORDER BY units_sold DESC
LIMIT 5;


-- =========================================
-- 3. SEASONAL SALES ANALYSIS
-- =========================================

-- Question 3: Which fiscal quarter typically generates the highest hardware sales?
-- Calculate average hardware sales by fiscal quarter
SELECT
    fiscal_quarter,
	COUNT(*) AS observations,
	ROUND(
        AVG(units_sold) / 1000000,
        2
    ) AS avg_sales_millions,
	ROUND(
        MAX(units_sold) / 1000000,
        2
    ) AS max_sales_millions,
	ROUND(
        MIN(units_sold) / 1000000,
        2
    ) AS min_sales_millions
FROM ps5_quarterly_sales
GROUP BY fiscal_quarter
ORDER BY fiscal_quarter;


-- =========================================
-- 4. CUMULATIVE SALES ANALYSIS
-- =========================================

-- Question 4: How quickly did PS5 hardware shipments accumulate after launch?
-- Calculate cumulative hardware sales using a window function
SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
-- Calculate a running total of PS5 hardware sales
	ROUND(
        units_sold / 1000000,
        2
    ) AS quarterly_sales_millions,
	ROUND(
        SUM(units_sold) OVER (
            ORDER BY period_end
        ) / 1000000,
        2
    ) AS cumulative_sales_millions
FROM ps5_quarterly_sales
ORDER BY period_end;


-- =========================================
-- 5. QUARTER-OVER-QUARTER GROWTH
-- =========================================

-- Question 5: How much did PS5 hardware sales increase or decrease each quarter?
-- Use a CTE to retrieve sales from the preceding quarter
WITH quarterly_growth AS (
	SELECT
        fiscal_year,
        fiscal_quarter,
        period_end,
        units_sold,
		LAG(units_sold) OVER (
            ORDER BY period_end
        ) AS previous_quarter_sales
	FROM ps5_quarterly_sales
)
-- Calculate the percentage change from the preceding quarter
SELECT
    fiscal_year,
    fiscal_quarter,
	ROUND(
        units_sold / 1000000,
        2
    ) AS current_sales_millions,
	ROUND(
        previous_quarter_sales / 1000000,
        2
    ) AS previous_sales_millions,
	ROUND(
        (
			units_sold - previous_quarter_sales
        ) / NULLIF(previous_quarter_sales, 0) * 100,
        2
    ) AS qoq_growth_pct
FROM quarterly_growth
ORDER BY fiscal_year, fiscal_quarter;


-- =========================================
-- 6. YEAR-OVER-YEAR GROWTH
-- =========================================

-- Question 6: How have PS5 hardware sales changed compared with the same quarter in the previous fiscal year?
-- Compare each quarter with the same quarter one year earlier
SELECT
    current.fiscal_year,
    current.fiscal_quarter,
	ROUND(
        current.units_sold / 1000000,
        2
    ) AS current_sales_millions,
	ROUND(
        previous.units_sold / 1000000,
        2
    ) AS previous_year_sales_millions,
-- Calculate year-over-year percentage growth
	ROUND(
        (
            current.units_sold - previous.units_sold
        ) / NULLIF(previous.units_sold, 0) * 100,
        2
    ) AS yoy_growth_pct
FROM ps5_quarterly_sales AS current
LEFT JOIN ps5_quarterly_sales AS previous
	ON current.fiscal_year = previous.fiscal_year + 1
	AND current.fiscal_quarter = previous.fiscal_quarter
ORDER BY
    current.fiscal_year,
    current.fiscal_quarter;


-- =========================================
-- 7. ANNUAL SALES GROWTH
-- =========================================

-- Aggregate hardware sales for each completed fiscal year
WITH annual_sales AS (
	SELECT
        fiscal_year,
		SUM(units_sold) AS annual_units_sold
	FROM ps5_quarterly_sales
	GROUP BY fiscal_year
	-- Exclude incomplete fiscal years
    HAVING COUNT(*) = 4
),
-- Retrieve the previous fiscal year's annual sales
annual_growth AS (
	SELECT
        fiscal_year,
        annual_units_sold,
		LAG(annual_units_sold) OVER (
            ORDER BY fiscal_year
        ) AS previous_year_sales
	FROM annual_sales
)
-- Calculate annual hardware sales growth
SELECT
    fiscal_year,
	ROUND(
        annual_units_sold / 1000000,
        2
    ) AS annual_sales_millions,
	ROUND(
        (
            annual_units_sold - previous_year_sales
        ) / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS annual_yoy_growth_pct
FROM annual_growth
ORDER BY fiscal_year;


-- =========================================
-- 8. FINAL ANALYTICAL VIEW
-- =========================================

-- Create a reusable quarterly sales analysis view
CREATE OR REPLACE VIEW vw_ps5_sales_analysis AS
WITH sales_metrics AS (
	SELECT
        fiscal_year,
        fiscal_quarter,
        period_end,
        units_sold,
		-- Calculate cumulative hardware sales
        SUM(units_sold) OVER (
            ORDER BY period_end
        ) AS cumulative_units_sold,
		-- Retrieve the previous quarter's sales
        LAG(units_sold) OVER (
            ORDER BY period_end
        ) AS previous_quarter_sales
	FROM ps5_quarterly_sales
)
SELECT
    s.fiscal_year,
    s.fiscal_quarter,
    s.period_end,
	s.units_sold,
	s.cumulative_units_sold,
	-- Calculate quarter-over-quarter growth
    ROUND(
        (
            s.units_sold - s.previous_quarter_sales
        ) / NULLIF(s.previous_quarter_sales, 0) * 100,
        2
    ) AS qoq_growth_pct,
	-- Calculate year-over-year growth
    ROUND(
        (
            s.units_sold - p.units_sold
        ) / NULLIF(p.units_sold, 0) * 100,
        2
    ) AS yoy_growth_pct
FROM sales_metrics AS s
LEFT JOIN ps5_quarterly_sales AS p
	ON s.fiscal_year = p.fiscal_year + 1
	AND s.fiscal_quarter = p.fiscal_quarter;

-- Display the completed analytical dataset
SELECT *
FROM vw_ps5_sales_analysis
ORDER BY period_end;


