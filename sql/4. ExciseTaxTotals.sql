-- Total Excise Tax Difference for Spirits (Classification 1)

WITH
-- This first CTE returns the actual value of excise taxes for each brand
a AS (
	SELECT 
		s.Brand,
		SUM(s.ExciseTax)
			AS Actual
	FROM dbo.bibitor_sales s
		JOIN dbo.bibitor_brands br
			ON s.Brand = br.Brand
	WHERE br.Classification = 1
	GROUP BY s.Brand
),

-- This second CTE calculates the calculated value of excise taxes for each brand
c AS (
	SELECT
		s.Brand,
		SUM(CONVERT(DECIMAL(10,2), (((br.Volume * br.PackSize) * s.SalesQuantity) * .00105)))
			AS Calculated
	FROM dbo.bibitor_sales s
		JOIN dbo.bibitor_brands br
			ON s.Brand = br.Brand
	WHERE br.Classification = 1
	GROUP BY s.Brand
)

-- This main statement returns the actual total Excise Tax and uses the CTE Alias to calculate what the total Excise Tax should be
	SELECT 
		
-- Total Actual Excise Tax Calculation
		SUM(a.Actual) AS Actual, 

-- Total Calculated Excise Tax Calculation
		SUM(c.Calculated) AS Calculated,

-- Claculated difference between actual and calculated Excise Tax totals
		(SUM(a.Actual) - SUM(c.Calculated)) AS Difference

-- FROM Statements
	FROM a
		JOIN c
			ON a.Brand = c.Brand