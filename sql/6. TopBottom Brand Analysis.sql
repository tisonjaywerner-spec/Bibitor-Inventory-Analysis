-- ITR, DIO, and Gross Margin Calculation for the top/bottom 6 Brands ordered by Gross Margin
-- Used CTEs to prevent what I call "JOIN inflation" across brand multi-row tables such as purchases and sales
-- Brands missing from beginning and ending inventory tables are included with left joins
-- Used the ISNULL function to treat brands with missing inventory as 0 so COGS would calculate right (Credit to Tyra and Betsy for helping with this)

WITH 
-- This first CTE calculates the value of beginning inventory for each brand
	b AS (
		SELECT
		br.Brand,
		SUM(b.OnHand * br.PurchasePrice)
			AS BeginningInventory
		FROM dbo.bibitor_beginning_inventory b
			JOIN dbo.bibitor_brands br
				ON b.Brand = br.Brand
		GROUP BY br.Brand
	),

-- This second CTE calculates the value of ending inventory for each brand
	e AS (
		SELECT
		br.Brand,
		SUM(e.OnHand * br.PurchasePrice)
			AS EndingInventory
		FROM dbo.bibitor_ending_inventory e
			JOIN dbo.bibitor_brands br
				ON e.Brand = br.Brand
		GROUP BY br.Brand
	),

-- This third CTE calculates the value of purchases for each brand
	p AS (
		SELECT
		br.Brand,
		SUM(p.PurchaseQuantity * br.PurchasePrice)
			AS Purchases
		FROM dbo.bibitor_purchases p
			JOIN dbo.bibitor_brands br
				ON p.Brand = br.Brand
		GROUP BY br.Brand
	),

-- This fourth CTE calculates the value of sales for each brand
	s AS (
		SELECT
		br.Brand,
		SUM(s.SalesQuantity * s.SalesPrice)
			AS Sales
		FROM dbo.bibitor_sales s
			JOIN dbo.bibitor_brands br
				ON s.Brand = br.Brand
		GROUP BY br.Brand
	)

-- This main statement uses the CTE Aliases to calculate COGS, Gross Margin, ITR, and DIO for each brand
	SELECT TOP 6
		s.Brand, 
		CONVERT(DECIMAL(10,2), ISNULL(b.BeginningInventory, 0)) AS BeginningInventory, 
		CONVERT(DECIMAL(10,2), ISNULL(p.Purchases, 0)) AS Purchases, 
		CONVERT(DECIMAL(10,2), ISNULL(e.EndingInventory,0)) AS EndingInventory, 
		CONVERT(DECIMAL(10,2), ISNULL(s.Sales,0)) AS Sales,

-- COGS Calculation
		CONVERT(DECIMAL(10,2), 
			ISNULL(b.BeginningInventory, 0)
			+ ISNULL(p.Purchases, 0) 
			- ISNULL(e.EndingInventory, 0))
				AS COGS,

-- Gross Margin Calculation
		CONVERT(DECIMAL(10,2), 
			((s.Sales 
			- (ISNULL(b.BeginningInventory, 0)
			+ ISNULL(p.Purchases, 0) 
			- ISNULL(e.EndingInventory, 0))) 
			/ NULLIF(s.Sales, 0)))
			AS GrossMargin,

-- Inventory Turnover Calculation
		CONVERT(DECIMAL(10,2), 
			(ISNULL(b.BeginningInventory, 0) 
			+ ISNULL(p.Purchases, 0)
			- ISNULL(e.EndingInventory, 0))
			/ NULLIF((
			(ISNULL(b.BeginningInventory, 0)
			+ ISNULL(e.EndingInventory, 0)) 
			/ 2), 0))
			AS ITR,

-- Days Inventory Outstanding Calculation
		CONVERT(DECIMAL(10,2), 
		(365 / 
		((ISNULL(b.BeginningInventory, 0) 
		+ ISNULL(p.Purchases, 0) 
		- ISNULL(e.EndingInventory, 0))
		/ NULLIF(((ISNULL(b.BeginningInventory, 0) 
		+ ISNULL(e.EndingInventory, 0)) 
		/ 2), 0))))
			AS DIO

-- FROM Statements
	FROM s
		LEFT JOIN b
			ON s.Brand = b.Brand
		LEFT JOIN e
			ON s.Brand = e.Brand
		LEFT JOIN p
			ON s.Brand = p.Brand

-- Change this ORDER BY statement to ASC to return the top 6 brands, and DESC to return the bottom 6 brands by gross margin.
	ORDER BY GrossMargin DESC