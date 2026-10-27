-- Select the PlayStation analysis database
USE playstation_analysis;
-- Retrieve all quarterly PS5 harware sales records
SELECT *
FROM ps5_quarterly_sales
-- Display observstions chronologically
ORDER BY period_end;

-- Count the total number of quarterly observations
SELECT
	COUNT(*) AS total_quarters
FROM ps5_quarterly_sales;

-- Calculate total reported PS5 hardware units
SELECT
    SUM(units_sold) AS total_units_sold
FROM ps5_quarterly_sales;

-- Question 1: Which fiscal year recorded the highest PS5 harware sales?
-- Calculate total PS5 hardware sales by fiscal year
SELECT
	fiscal_year,
    -- Aggregate quarterly sales within each fiscal year
    SUM(units_sold) AS annual_units_sold
FROM ps5_quarterly_sales
-- Group observations by fiscal year
GROUP BY fiscal_year
-- Rank fiscal years from highest to lowest sales
ORDER BY annual_units_sold DESC;