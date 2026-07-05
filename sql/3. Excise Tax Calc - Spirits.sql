-- Excise Tax Calculation for Spirits (Classification 1)

WITH
-- This CTE calculates the true volume of each brand including the pack size
v AS (
	SELECT 
		br.Brand,
		(br.Volume * br.PackSize) 
			AS VolumeTrue
	FROM dbo.bibitor_brands br
	GROUP BY br.Brand, (br.Volume * br.PackSize)
)

-- This main statement uses the CTE Alias to calculate what the Excise Tax should be 
	SELECT 
		br.Brand,  
		br.Volume, 
		br.PackSize, 
		s.ExciseTax, 
		CONVERT(DECIMAL(10,4), ((v.VolumeTrue * s.SalesQuantity) * .00105))
			AS CalcExciseTax

-- FROM Statements
	FROM dbo.bibitor_sales s
		JOIN v
			ON s.Brand = v.Brand
		JOIN dbo.bibitor_brands br
			ON s.Brand = br.Brand

-- This WHERE statement returns only the Spirit brands in which the actual and calculated Excise Taxes do not match
	WHERE
			br.Classification = '1' 
		AND 
			s.ExciseTax <> (v.VolumeTrue * .00105)