# Data Sources & Methodology

This document describes the primary data sources, definitions, calculations, assumptions, and limitations used in the **PlayStation Lifecycle Analysis** project. The project prioritizes first-party sources from **Sony, Sony Interactive Entertainment, PlayStation, and the U.S. Bureau of Labor Statistics** whenever available.

---

## 1. PlayStation Console History

### Primary Source

**PlayStation / Sony Interactive Entertainment: PlayStation History**

Used for:

- Historical PlayStation console generations
- North American release dates
- Console lifecycle calculations
- Historical hardware context

### Release Dates Used

| Console | North American Release |
|---|---|
| PlayStation | September 9, 1995 |
| PlayStation 2 | October 26, 2000 |
| PlayStation 3 | November 17, 2006 |
| PlayStation 4 | November 15, 2013 |
| PlayStation 5 | November 12, 2020 |

### Lifecycle Methodology

A console's lifecycle interval is defined in this project as the elapsed time between its North American release date and the North American release date of the next main PlayStation generation.

For example:

```text
PS4 Lifecycle Interval = PS5 Release Date − PS4 Release Date
```

This definition measures the interval between major console launches. It does **not** represent the date on which Sony discontinued production or support for the previous console.

### Derived Lifecycle Results

| Transition | Approximate Interval |
|---|---:|
| PS1 → PS2 | 5.13 years |
| PS2 → PS3 | 6.06 years |
| PS3 → PS4 | 6.99 years |
| PS4 → PS5 | 6.99 years |

The average of the four completed generation intervals is approximately:

**6.29 years**

> **Note:** The 6.29-year average is calculated within this project and is not a figure published by Sony.

---

## 2. Historical PlayStation Hardware Sales

### Primary Source

**Sony Interactive Entertainment — Business Data & Sales**

Used for historical worldwide PlayStation hardware sales.

### Hardware Figures Used

| Console | Worldwide Hardware Units |
|---|---:|
| PlayStation | 102.4M+ |
| PlayStation 2 | 160M+ |
| PlayStation 3 | 87.4M+ |
| PlayStation 4 | 117M+ |
| PlayStation 5 | 95M+ as of June 30, 2026 |

These figures should not all be interpreted as equivalent **lifetime sales**.

PS5 remains an active platform, so its current cumulative total represents an observation through the stated reporting date rather than a completed lifetime total.

Sony describes the hardware figures on its business-data page as **cumulative worldwide hardware unit sales (sell-in).**

> **Terminology:** Throughout the project, PS5 hardware figures are preferably described as **hardware sell-in** or **hardware shipments** rather than consumer sell-through.

---

## 3. PlayStation Launch Prices

The pricing analysis uses selected U.S. launch configurations to create a consistent historical comparison.

### Important SKU Assumption

Several PlayStation generations launched with more than one configuration or SKU.

For that reason, the project documents the particular U.S. launch price selected for each generation rather than implying that every console had only one launch price.

The selected configuration is kept consistent between the:

- Excel dataset
- Python notebook
- Final dashboard
- README documentation

### PlayStation 5

The standard PS5 console with an Ultra HD Blu-ray disc drive launched in the United States at:

**$499.99**

The PS5 Digital Edition launched at:

**$399.99**

This project uses the **$499.99 standard disc-console configuration** for the historical pricing comparison.

### PlayStation 4

The PS4 launched in North America on November 15, 2013 at:

**$399.99**

### PlayStation 3

PS3 requires additional consideration because multiple launch configurations existed.

The pricing dataset therefore identifies the selected launch configuration rather than treating one price as the only PS3 launch price.

The project uses a selected PS3 launch price of:

**$499.99**

> **Important:** This represents a selected PS3 launch configuration for analytical consistency. PS3 launched with multiple configurations and price points.

---

## 4. Consumer Price Index

### Source

**U.S. Bureau of Labor Statistics (BLS)**

### CPI Series

**Consumer Price Index for All Urban Consumers (CPI-U)**

| Attribute | Value |
|---|---|
| Series ID | `CUUR0000SA0` |
| Area | U.S. city average |
| Item | All items |
| Seasonal Adjustment | Not seasonally adjusted |
| Base Period | 1982–84 = 100 |

The CPI dataset is used to compare PlayStation launch prices across different years in constant dollars.

### Benchmark Year

All real-price calculations are expressed in:

**2025 U.S. dollars**

The annual-average CPI-U value used for 2025 is:

**321.943**

### Inflation Adjustment Formula

For each console:

```text
Real Price in 2025 USD
=
Nominal Launch Price × (2025 CPI / Launch-Year CPI)
```

For example:

```text
PS5 Real Price
=
PS5 Nominal Price × (2025 CPI / 2020 CPI)
```

### Why CPI Adjustment Is Used

A nominal dollar amount from 1995 is not directly comparable with the same nominal amount in 2020.

Inflation adjustment converts historical prices into a common purchasing-power benchmark, providing a more meaningful comparison across console generations.

### CPI Limitation

CPI measures changes in the overall consumer price level.

It does **not** measure:

- Console computing performance
- Hardware quality improvements
- Storage capacity
- Graphics capabilities
- Household income
- Consumer willingness to pay
- Gaming-specific technological change

The real-price analysis should therefore be interpreted as a **general purchasing-power comparison**, not a complete measure of console value.

---

## 5. PS5 Quarterly Hardware Data

### Primary Source

**Sony Interactive Entertainment — Business Data & Sales**

Sony reports worldwide PlayStation 5 hardware unit sales on a **sell-in** basis.

Quarterly observations are reported in millions of units.

### Sony Fiscal Calendar

Sony's fiscal year runs from **April through March**.

| Fiscal Quarter | Calendar Period |
|---|---|
| Q1 | April–June |
| Q2 | July–September |
| Q3 | October–December |
| Q4 | January–March |

This distinction is especially important when interpreting **Q3**, because it contains the major year-end holiday shopping period.

---

## 6. PS5 Quarterly Dataset

The SQL dataset begins with PS5's launch-period fiscal quarter and follows reported quarterly hardware observations.

Selected observations include:

| Fiscal Period | Hardware Sell-In |
|---|---:|
| FY2020 Q3 | 4.5M |
| FY2022 Q3 | 7.1M |
| FY2023 Q3 | 8.2M |
| FY2024 Q3 | 9.5M |
| FY2025 Q3 | 7.9M |
| FY2026 Q1 | 1.6M |

The **9.5 million-unit FY2024 Q3 observation** is the highest individual quarter in the project dataset.

### Rounding Consideration

Sony reports quarterly observations to one decimal place in millions.

Adding these rounded quarterly observations can therefore produce small differences from Sony's separately reported full-year totals.

> A total calculated from rounded quarterly observations is described as a **derived sum of quarterly observations** rather than substituted for Sony's official annual figure when an official annual total is available.

---

## 7. SQL-Derived Metrics

The following measures are calculated within **MySQL** and are not directly reported by Sony.

### Cumulative Units

Cumulative units are calculated as a running sum ordered by reporting period.

Conceptually:

```sql
SUM(units_sold) OVER (ORDER BY period_end)
```

### Quarter-over-Quarter Growth

```text
QoQ Growth (%)
=
((Current Quarter − Previous Quarter) / Previous Quarter) × 100
```

Because PlayStation hardware exhibits substantial seasonality, QoQ changes should be interpreted cautiously.

### Year-over-Year Growth

```text
YoY Growth (%)
=
((Current Quarter − Same Quarter Previous Fiscal Year)
/
Same Quarter Previous Fiscal Year) × 100
```

The analysis matches equivalent fiscal quarters rather than relying solely on sequential row offsets.

This provides additional context when evaluating seasonal hardware performance.

### Performance Categories

The project also uses analyst-created performance categories based on YoY growth.

These categories are descriptive analytical labels and are **not classifications published or used by Sony**.

---

## 8. PS5 Lifecycle Interpretation

The analysis identifies a pattern of strong earlier hardware expansion followed by moderation in later completed fiscal years.

This pattern is described as being:

**Consistent with lifecycle maturation**

It should **not** be interpreted as proof that the PS5 has reached a specific formal lifecycle stage or as evidence of an imminent successor.

The project's lifecycle interpretation is based on the historical and quarterly datasets documented here.

---

## 9. PS6 Scenario Analysis

No PS6 release date is assumed, predicted, or claimed by this project.

The analysis constructs **three historical timing scenarios**.

### Historical Average Scenario

Based on the average of all four completed PlayStation generation intervals:

**Approximately 6.29 years**

### Recent Cycle Scenario

Based on the two most recent completed generation intervals:

- PS3 → PS4
- PS4 → PS5

Both are approximately seven years, producing a recent-cycle benchmark of approximately:

**6.99 years**

### Extended Cycle Scenario

The project also evaluates an:

**8.00-year lifecycle**

This is an analyst-created assumption designed to evaluate the implications of a longer PS5 lifecycle.

It is **not** calculated from Sony guidance.

### Scenario-Date Method

Scenario dates are calculated by adding the assumed lifecycle duration to the PS5 launch date.

```text
Scenario Date
=
PS5 Launch Date + Scenario Lifecycle Length
```

### Appropriate Interpretation

The resulting dates can be described as:

- Scenario dates
- Historical benchmarks
- Lifecycle benchmarks
- Possible timing windows for analytical comparison

They should **not** be described as:

- Sony forecasts
- Confirmed PS6 dates
- Predicted PS6 launch dates
- Sony guidance

> **Important:** The PS6 analysis is a historical scenario exercise, not a forecast of Sony's future product plans.

---

## 10. Analytical Grain

The project combines datasets at different levels of analysis.

| Dataset | Analytical Grain |
|---|---|
| Console History | One row per console generation |
| Pricing Analysis | One row per console generation |
| PS5 Hardware | One row per fiscal quarter |
| PS6 Scenarios | One row per scenario |

These datasets are intentionally analyzed separately where appropriate rather than being forced into a single relational structure.

---

## 11. Tools & Transformation Responsibilities

### Microsoft Excel

Used for:

- Historical console dataset
- Lifecycle calculations
- KPI calculations
- PivotTables
- PivotCharts
- Slicers
- Scenario analysis
- Final interactive dashboard

### Python

Used for:

- CPI data preparation
- Annual CPI selection
- Dataset merging
- Inflation-adjusted pricing
- Percentage-change analysis
- Visualization

Primary libraries:

- `pandas`
- `matplotlib`

### MySQL

Used for:

- PS5 quarterly-data storage
- Data-quality checks
- Aggregation
- Annual analysis
- Seasonality
- Cumulative calculations
- Quarter-over-quarter growth
- Year-over-year growth
- Window functions
- Reporting views

---

## 12. Key Caveats

1. Only four completed main-generation PlayStation transitions are available for lifecycle analysis, making the historical sample very small.

2. Historical generation patterns cannot establish Sony's future product strategy.

3. PS5 remains an active platform, so its current cumulative hardware total should not be treated as completed lifetime sales.

4. Sony's hardware figures are reported as **sell-in**, which should not automatically be interpreted as end-consumer sell-through.

5. Quarterly figures are rounded and may not sum exactly to separately reported annual figures.

6. Inflation adjustment measures general purchasing-power differences but does not account for technological improvements or differences in product configuration.

7. Multiple PlayStation generations launched with more than one SKU, making configuration selection important when comparing launch prices.

8. The eight-year PS6 scenario is an analytical assumption rather than an observed historical average or Sony forecast.

9. PS6 scenario dates are benchmarks only and should not be interpreted as predictions.

---

## 13. Reproducibility

The project repository contains the primary analytical components required to follow the workflow:

- Historical console analysis in Excel
- CPI and real-price analysis in Python
- PS5 quarterly analysis in MySQL
- Final interactive Excel dashboard
- Analysis-ready PS5 quarterly dataset
- SQL scripts
- Jupyter Notebook
- Source and methodology documentation

The objective is to make each major result traceable from its source data through its analytical transformation to its final visualization.

---
