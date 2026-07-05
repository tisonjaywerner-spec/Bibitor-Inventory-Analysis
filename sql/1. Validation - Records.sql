-- Data Validation : Count of Records For Each Table

-- My approach to validating that I imported the correct number of rows is to use multiple CTEs (Common Table Expressions)...
-- To validate the number of rows in each table.

-- Count of rows in Beginning Inventory table
WITH
	b AS (
		SELECT
			COUNT(*) AS BeginningInventory
		FROM dbo.bibitor_beginning_inventory
	),
-- Count of rows in Brands table
	br AS (
		SELECT
			COUNT(*) AS Brands
		FROM dbo.bibitor_brands
	),
-- Count of rows in Ending Inventory table
	e AS (
		SELECT
			COUNT(*) AS EndingInventory
		FROM dbo.bibitor_ending_inventory
	),
-- Count of rows in Payroll table
	pr AS (
		SELECT
			COUNT(*) AS PayrollIDs
		FROM dbo.bibitor_payroll
	),
-- Count of rows in Purchase Orders table
	po AS (
		SELECT
			COUNT(*) AS PurchaseOrders
		FROM dbo.bibitor_purchase_orders
	),
-- Count of rows in Purchases table
	p AS (
		SELECT
			COUNT(*) AS Purchases
		FROM dbo.bibitor_purchases
	),
-- Count of rows in Sales table
	s AS (
		SELECT
			COUNT(*) AS Sales
		FROM dbo.bibitor_sales
	),
-- Count of rows in Stores table
	st AS (
		SELECT
			COUNT(*) AS Stores
		FROM dbo.bibitor_stores
	)
-- Main body of query using CTE aliases from above to show count of rows in every table
	SELECT
		b.BeginningInventory, br.Brands, e.EndingInventory, pr.PayrollIDs, po.PurchaseOrders, p.Purchases, s.Sales, st.Stores
	FROM s
		CROSS JOIN b
		CROSS JOIN br
		CROSS JOIN e
		CROSS JOIN pr
		CROSS JOIN po
		CROSS JOIN p
		CROSS JOIN st