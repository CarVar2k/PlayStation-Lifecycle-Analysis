/*
=========================================================
PROJECT: PlayStation 5 Hardware Sales Lifecycle Analysis
TOOL: MySQL
DATA SOURCE: Sony Interactive Entertainment

PURPOSE:
Create a reusable analytical dataset containing quarterly
PS5 hardware sales, cumulative sales, QoQ growth, and
YoY growth for downstream analysis and visualization.
=========================================================
*/

USE playstation_analysis;


-- =========================================
-- 1. CREATE ANALYTICAL VIEW
-- =========================================

CREATE OR REPLACE VIEW vw_ps5_sales_analysis AS
WITH quarterly_metrics AS (
    SELECT
        sales_id,
        fiscal_year,
        fiscal_quarter,
        period_end,
        units_sold,
        -- Calculate cumulative hardware sales
        SUM(units_sold) OVER (
            ORDER BY period_end
        ) AS cumulative_units_sold,
        -- Retrieve sales from the immediately preceding quarter
        LAG(units_sold) OVER (
            ORDER BY period_end
        ) AS previous_quarter_units
    FROM ps5_quarterly_sales
)

SELECT
    current.sales_id,
    current.fiscal_year,
    current.fiscal_quarter,
    current.period_end,
    current.units_sold,
    current.cumulative_units_sold,
    -- Calculate quarter-over-quarter growth
    ROUND(
        (
            current.units_sold -
            current.previous_quarter_units
        )
        / NULLIF(current.previous_quarter_units, 0)
        * 100,
        2
    ) AS qoq_growth_pct,
    -- Calculate year-over-year growth
    ROUND(
        (
            current.units_sold -
            previous.units_sold
        )
        / NULLIF(previous.units_sold, 0)
        * 100,
        2
    ) AS yoy_growth_pct
FROM quarterly_metrics AS current
LEFT JOIN ps5_quarterly_sales AS previous
    ON current.fiscal_year =
       previous.fiscal_year + 1
    AND current.fiscal_quarter =
        previous.fiscal_quarter;
        
-- Verify the analytical view
SELECT *
FROM vw_ps5_sales_analysis
ORDER BY period_end;


-- =========================================
-- 2. PRESENTATION-FRIENDLY OUTPUT
-- =========================================

SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
    ROUND(
        units_sold / 1000000,
        2
    ) AS quarterly_sales_millions,
    ROUND(
        cumulative_units_sold / 1000000,
        2
    ) AS cumulative_sales_millions,
    qoq_growth_pct,
    yoy_growth_pct
FROM vw_ps5_sales_analysis
ORDER BY period_end;


-- =========================================
-- 3. ANNUAL LIFECYCLE ANALYSIS
-- =========================================

WITH annual_sales AS (
    SELECT
        fiscal_year,
        COUNT(*) AS quarters_reported,
        SUM(units_sold) AS annual_units_sold
    FROM ps5_quarterly_sales
    GROUP BY fiscal_year
),
complete_years AS (
    -- Retain only fiscal years containing all four quarters
    SELECT
        fiscal_year,
        annual_units_sold
    FROM annual_sales
    WHERE quarters_reported = 4
),
annual_growth AS (
    SELECT
        fiscal_year,
        annual_units_sold,
        -- Retrieve sales from the preceding complete fiscal year
        LAG(annual_units_sold) OVER (
            ORDER BY fiscal_year
        ) AS previous_year_sales
    FROM complete_years
)
SELECT
    fiscal_year,
    ROUND(
        annual_units_sold / 1000000,
        2
    ) AS annual_sales_millions,
    ROUND(
        (
            annual_units_sold -
            previous_year_sales
        )
        / NULLIF(previous_year_sales, 0)
        * 100,
        2
    ) AS annual_growth_pct
FROM annual_growth
ORDER BY fiscal_year;

-- Question: When did annual PS5 hardware shipments peak?
-- Identify the strongest complete fiscal year
SELECT
    fiscal_year,
    ROUND(
        SUM(units_sold) / 1000000,
        2
    ) AS annual_sales_millions
FROM ps5_quarterly_sales
GROUP BY fiscal_year
HAVING COUNT(*) = 4
ORDER BY SUM(units_sold) DESC
LIMIT 1;

-- Identify the strongest individual hardware-sales quarter
SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
    ROUND(
        units_sold / 1000000,
        2
    ) AS sales_millions
FROM ps5_quarterly_sales
ORDER BY units_sold DESC
LIMIT 1;


-- =========================================
-- 4. HOLIDAY SALES TREND
-- =========================================

-- Analyze October-December hardware sales across fiscal years
SELECT
    fiscal_year,
    ROUND(
        units_sold / 1000000,
        2
    ) AS q3_sales_millions,
    yoy_growth_pct AS q3_yoy_growth_pct
FROM vw_ps5_sales_analysis
WHERE fiscal_quarter = 3
ORDER BY fiscal_year;


-- =========================================
-- 5. YEAR-OVER-YEAR PERFORMANCE RANKING
-- =========================================

SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
    ROUND(
        units_sold / 1000000,
        2
    ) AS sales_millions,
    yoy_growth_pct
FROM vw_ps5_sales_analysis
WHERE yoy_growth_pct IS NOT NULL
ORDER BY yoy_growth_pct DESC;

-- Rank quarters from largest YoY decline to strongest growth
SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
    ROUND(
        units_sold / 1000000,
        2
    ) AS sales_millions,
    yoy_growth_pct
FROM vw_ps5_sales_analysis
WHERE yoy_growth_pct IS NOT NULL
ORDER BY yoy_growth_pct ASC;


-- =========================================
-- 6. PERFORMANCE CLASSIFICATION
-- =========================================

SELECT
    fiscal_year,
    fiscal_quarter,
    ROUND(
        units_sold / 1000000,
        2
    ) AS sales_millions,
    yoy_growth_pct,
    CASE
        WHEN yoy_growth_pct >= 10
            THEN 'Strong Growth'
        WHEN yoy_growth_pct > 0
            THEN 'Moderate Growth'
        WHEN yoy_growth_pct = 0
            THEN 'Flat'
        WHEN yoy_growth_pct > -10
            THEN 'Moderate Decline'
        WHEN yoy_growth_pct <= -10
            THEN 'Strong Decline'
        ELSE 'No Prior-Year Comparison'
    END AS performance_category
FROM vw_ps5_sales_analysis
ORDER BY period_end;


-- =========================================
-- 7. EXECUTIVE KPI SUMMARY
-- =========================================

SELECT
    -- Number of quarterly observations
    COUNT(*) AS quarters_analyzed,
    -- Total reported hardware shipments
    ROUND(
        SUM(units_sold) / 1000000,
        2
    ) AS cumulative_sales_millions,
    -- Average quarterly hardware shipments
    ROUND(
        AVG(units_sold) / 1000000,
        2
    ) AS avg_quarterly_sales_millions,
    -- Highest quarterly hardware shipments
    ROUND(
        MAX(units_sold) / 1000000,
        2
    ) AS peak_quarter_sales_millions,
    -- Lowest quarterly hardware shipments
    ROUND(
        MIN(units_sold) / 1000000,
        2
    ) AS lowest_quarter_sales_millions
FROM ps5_quarterly_sales;


-- =========================================
-- 8. FINAL DATA QUALITY CHECK
-- =========================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT CONCAT(
        fiscal_year,
        '-',
        fiscal_quarter
    )) AS unique_quarters,
    SUM(
        CASE
            WHEN units_sold IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_sales,
    SUM(
        CASE
            WHEN units_sold <= 0 THEN 1
            ELSE 0
        END
    ) AS invalid_sales,
    MIN(period_end) AS first_period,
    MAX(period_end) AS latest_period
FROM ps5_quarterly_sales;


-- =========================================
-- 9. POWER BI DATASET
-- =========================================

-- Produce the final dataset for downstream visualization
SELECT
    fiscal_year,
    fiscal_quarter,
    period_end,
    units_sold,
    ROUND(
        units_sold / 1000000,
        2
    ) AS quarterly_sales_millions,
    cumulative_units_sold,
    ROUND(
        cumulative_units_sold / 1000000,
        2
    ) AS cumulative_sales_millions,
    qoq_growth_pct,
    yoy_growth_pct,
    CASE
        WHEN yoy_growth_pct >= 10
            THEN 'Strong Growth'
        WHEN yoy_growth_pct > 0
            THEN 'Moderate Growth'
        WHEN yoy_growth_pct = 0
            THEN 'Flat'
        WHEN yoy_growth_pct > -10
            THEN 'Moderate Decline'
        WHEN yoy_growth_pct <= -10
            THEN 'Strong Decline'
        ELSE 'No Prior-Year Comparison'
    END AS performance_category
FROM vw_ps5_sales_analysis
ORDER BY period_end;