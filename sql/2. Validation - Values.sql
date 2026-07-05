-- Data Validation : Confirming values given by CIO

-- My approach to validating that my imported data returns the same values as the CIO sees is to use multiple CTEs (Common Table Expressions)

WITH
-- Value of total sales
s AS (
	SELECT 
		SUM(SalesDollars) 
			AS Sales
	FROM dbo.bibitor_sales
),
-- Value of total purchases
p AS (
	SELECT 
		SUM(PurchaseDollars) 
			AS Purchases
	FROM dbo.bibitor_purchases
),
-- Value of total excise taxes
t AS (
	SELECT 
		SUM(ExciseTax) 
			AS ExciseTaxes
	FROM dbo.bibitor_sales
),
-- Value of beginning inventory
b AS (
	SELECT 
		SUM(b.onHand * br.PurchasePrice) 
			AS BeginningInventory
	FROM dbo.bibitor_beginning_inventory b
		LEFT JOIN dbo.bibitor_brands br
        	ON b.Brand = br.Brand
),
-- Value of ending inventory
e AS (
	SELECT 
		SUM(e.OnHand * br.PurchasePrice) 
			AS EndingInventory
	FROM dbo.bibitor_ending_inventory e
		LEFT JOIN dbo.bibitor_brands br
			ON e.Brand = br.Brand
)

-- This main statement returns each of the values to be compared with those given by the CIO
	SELECT 
		b.BeginningInventory,
		p.Purchases,
		e.EndingInventory,
		s.Sales,
		t.ExciseTaxes
	FROM s
		CROSS JOIN b
		CROSS JOIN p
		CROSS JOIN e
		CROSS JOIN t