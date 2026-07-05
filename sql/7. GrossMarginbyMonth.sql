-- Gross Margin for top/bottom 6 brands by month
-- Used CTEs to prevent what I call "JOIN inflation" across brand multi-row tables such as purchases and sales
-- Because bibitor_purchases contains no date column,
-- I approximated monthly COGS as SalesQuantity × PurchasePrice (cost of units sold that month).

WITH
-- This first CTE was created just to help avoid JOIN inflation in the main statement
	br AS (
		SELECT
			Brand,
			PurchasePrice
		FROM dbo.bibitor_brands
	),

-- This second CTE returns monthly sales and COGS for each brand
	s AS (
		SELECT
			Brand,
			DATEPART(MONTH, SalesDate)	
				AS SalesMonth,
			DATENAME(MONTH, SalesDate)	
				AS MonthName,
			SUM(SalesDollars)			
				AS MonthlySales,
			SUM(SalesQuantity)			
				AS MonthlyQuantity
		FROM dbo.bibitor_sales
		WHERE Brand IN (
	-- Top 6 brands by gross margin
			1771, 4858, 33963, 15745, 35607, 5708,
	-- Bottom 6 brands by gross margin
			20975, 1297, 33982, 21505, 33331, 4277
		)
		GROUP BY
			Brand,
			DATEPART(MONTH, SalesDate),
			DATENAME(MONTH, SalesDate)
	)

-- This main statement returns the monthly sales and COGS values as well as calculating the gross margin for each brand by month
	SELECT
		s.Brand,
		s.MonthName,
		CONVERT(DECIMAL(10,2), s.MonthlySales)							
			AS MonthlySales,
		CONVERT(DECIMAL(10,2), s.MonthlyQuantity * br.PurchasePrice)	
			AS MonthlyCOGS,
		CONVERT(DECIMAL(10,2),
		(s.MonthlySales - (s.MonthlyQuantity * br.PurchasePrice))
		/ NULLIF(s.MonthlySales, 0)
	)																
		AS GrossMargin
	FROM s
		JOIN br 
			ON s.Brand = br.Brand
	ORDER BY
		s.Brand,
		s.SalesMonth