# Bibitor Inventory Analysis

Excise tax and inventory transaction analysis for Bibitor, LLC, a retail liquor company with over 75 locations. Built with Microsoft SQL Server as a course project for Data Management & Analytics at Gustavus Adolphus College.

**Tools:** Microsoft SQL Server (SSMS), T-SQL, Microsoft Power Query, Microsoft Word

## Project Overview

Bibitor, LLC has been serving customers for over 50 years and carries more than 12,000 brands of spirits and wine across its stores. For this project I worked with a subset of Bibitor's data (5 stores, December 2025) to act as an associate consultant examining sales, purchases, and inventory transactions.

The engagement had two main goals:

1. Validate that the provided data was imported correctly and matched the totals reported by the CIO.
2. Analyze the data to recalculate excise taxes, evaluate profitability, and identify brands that may need management attention.

The full writeup, including all supporting tables, sits in [Final Report](docs/0.%20Final%20Report.docx). This README covers the process and highlights from that report.

## Data

Bibitor provided 8 tables in CSV format:

| Table | Records |
|---|---|
| bibitor_sales | 257,023 |
| bibitor_purchases | 40,468 |
| bibitor_purchase_orders | 2,476 |
| bibitor_stores | 5 |
| bibitor_brands | 2,803 |
| bibitor_ending_inventory | 7,828 |
| bibitor_beginning_inventory | 7,383 |
| bibitor_payroll | 735 |

## Process

### 1. Data Wrangling & Cleaning

The tables were downloaded from a shared Google Drive folder and loaded into SQL Server using the Import Wizard. Quotation marks were stripped out using the text qualifier setting, and column data types were corrected to match the actual data.

Partway through the project I found that the Brands table's size column sometimes combined the bottle volume with the pack size in the same field. I used Power Query in Excel to split that column into a raw volume column and a new `PackSize` column, filling any blank pack sizes with 1, then loaded the corrected version back into SQL Server.

### 2. Data Validation

Before doing any analysis, I confirmed the data was imported correctly by comparing my record counts and summary values against the numbers given by the CIO.

- [`Validation - Records.sql`](sql/Validation%20-%20Records.sql) checks the row count of every table using CTEs.
- [`Validation - Values.sql`](sql/Validation%20-%20Values.sql) checks that total sales, purchases, excise taxes, beginning inventory, and ending inventory all matched what the CIO reported.

Both checks came back clean, confirming every table had been imported correctly.

### 3. Analysis

**Excise Tax Recalculation**

I recalculated excise taxes for both spirits and wine using the current tax rate and each brand's true volume (bottle size times pack size), then compared the result against what Bibitor actually charged.

- [`Excise Tax Calc - Spirits.sql`](sql/Excise%20Tax%20Calc%20-%20Spirits.sql) and [`Excise Tax Calc - Wine.sql`](sql/Excise%20Tax%20Calc%20-%20Wine.sql) return every brand where the actual and calculated excise tax do not match.
- [`ExciseTaxTotal Spirits.sql`](sql/ExciseTaxTotal%20Spirits.sql) and [`ExciseTaxTotal Wine.sql`](sql/ExciseTaxTotal%20Wine.sql) roll those discrepancies up into a total dollar difference for each classification.

This turned up a pattern of rounding errors across the board, and a bigger issue where the pack size was being left out of the excise tax calculation entirely for multi-bottle packs. Management should look at fixing both of these.

**Company & Brand Profitability**

- [`Company Analysis.sql`](sql/Company%20Analysis.sql) calculates COGS, gross margin, inventory turnover (ITR), and days inventory outstanding (DIO) for the company as a whole.
- [`TopBottom Brand Analysis.sql`](sql/TopBottom%20Brand%20Analysis.sql) breaks the same metrics out by brand and returns the top and bottom 6 by gross margin.
- [`GrossMarginbyMonth.sql`](sql/GrossMarginbyMonth.sql) tracks gross margin by month for those same top and bottom brands to check for seasonality.

Bibitor's overall gross margin came in at 31%, ahead of the 25% industry average (per Dunn & Bradstreet's Key Business Ratios), with inventory sitting on the shelf for about 85 days on average. The bottom 6 brands by gross margin all sold exclusively in the summer months, which points to a spoilage and purchasing-timing risk that the top brands, which sell year round, don't share.

Every query above uses CTEs instead of stacking joins directly against the sales and purchases tables, since those tables have multiple rows per brand and joining straight into them causes row counts to inflate.

## Key Findings

- All data imported correctly and matched the CIO's reported totals.
- Excise tax discrepancies exist across both spirits and wine, driven by rounding and by pack size being excluded from the calculation.
- Company-wide gross margin (31%) is above the industry average (25%).
- The bottom 6 brands by gross margin are highly seasonal (summer-only sales), while the top 6 sell year round, suggesting a purchasing timing fix for the low performers.

## Limitations

- Values provided by the CIO were rounded, so `CONVERT(DECIMAL(...))` was used throughout to preserve precision in the calculated values.
- Some brands were missing from the beginning or ending inventory tables. `ISNULL` and `NULLIF` combined with `LEFT JOIN`s were used so those brands weren't dropped from the analysis.
- The dataset only covers 5 of Bibitor's 75+ locations and a fraction of its 12,000+ brands, so results may not generalize to the full company.
- `bibitor_purchases` has no date column, so the monthly gross margin analysis assumes purchases approximate cost of goods sold for that month.

## Repository Structure

```
├── sql/    SQL Server queries used throughout the analysis
├── docs/   Final report with full write-up and supporting visuals
└── README.md
```

## Author

Tison Werner, Gustavus Adolphus College, Data Management & Analytics
