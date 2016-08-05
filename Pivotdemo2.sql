
--https://gist.github.com/KeenerConsulting/0887f9324a683f69f4be
--SQL Server Dynamic Pivot Demo
-- First, create the empty table. The data will be pre-aggregated into monthly
-- sales totals, simulating a simple denormalized data warehouse view

IF OBJECT_ID('dbo.MonthlySales') IS NOT NULL
	DROP TABLE dbo.MonthlySales;


CREATE TABLE dbo.MonthlySales
(
    Yr SMALLINT,	-- Avoiding the use of keywords as column names...
    Qtr TINYINT,
    Mnth TINYINT,
	Category VARCHAR(50),
    TotalSales DECIMAL(19, 4)
);

-- SECOND PHASE: Create a stored procedure that performs a simple type of PIVOT
--------------------------------------------------------------------------------
/*
IF OBJECT_ID('dbo.GetPivotedReport') IS NOT NULL
	DROP PROCEDURE dbo.GetPivotedReport;
GO
CREATE PROCEDURE dbo.GetPivotedReport
	@SourceTableName	    NVARCHAR(128),
	@SourcePivotColumnName	NVARCHAR(128),
	@SourceLabelColumnName	NVARCHAR(128),
	@SourceDataColumnName	NVARCHAR(128),
	@OutputLabelColumnName	NVARCHAR(128)
AS

	DECLARE @PivotColumns   NVARCHAR(MAX),
			@PivotColumnsQuery	NVARCHAR(MAX),
			@PivotQuery     NVARCHAR(MAX);

	SET @PivotColumnsQuery = 
		'
		SET @PivotColumns = 
			STUFF(
					(' +
					-- Note: Two separate escape operations are taking place below using QUOTENAME.
					-- First, we are escaping the passed-in name of the column as we assemble the query.
					-- Then we escape the data values found in the column so they can be converted to column names.
				'	SELECT DISTINCT '','' + QUOTENAME(' + QUOTENAME(@SourcePivotColumnName) + ')
					FROM ' + @SourceTableName + '
					FOR XML PATH('''')                 ' + -- Use FOR XML to pull data values into a concatenated list
				'	, TYPE                             ' + -- Output the result as an XML object so that we can...
				'	).value(''.'', ''NVARCHAR(MAX)'')  ' + -- ... select it using XPath with the .value method, placing the result into an NVARCHAR(MAX)
				', 1, 1, '''');                        ';   -- Remove the leading comma using STUFF to make our syntax valid

	EXEC sp_executesql @PivotColumnsQuery, N'@PivotColumns NVARCHAR(MAX) OUTPUT', @PivotColumns OUTPUT;
	
	SET @PivotQuery = 
		'
		SELECT ' + QUOTENAME(@SourceLabelColumnName) + ' AS ' + QUOTENAME(@OutputLabelColumnName) + ', ' + @PivotColumns + ' 
		FROM
			(
			SELECT ' + QUOTENAME(@SourcePivotColumnName) + '
				, ' + QUOTENAME(@SourceLabelColumnName) + '
				, ' + QUOTENAME(@SourceDataColumnName) + '
			FROM ' + @SourceTableName + '
			) AS SourceTable
		PIVOT 
			(
			SUM(' + QUOTENAME(@SourceDataColumnName) + ')
			FOR ' + QUOTENAME(@SourcePivotColumnName) + ' IN (' + @PivotColumns + ')
			) AS pvt
		ORDER BY ' + QUOTENAME(@SourceLabelColumnName);

	EXEC sp_executesql @PivotQuery;
GO
*/


-- THIRD PHASE: Finally we get to the fun part: using our SP to slice and dice
--------------------------------------------------------------------------------
-- First, let's look at our sales for each quarter over time.
/*
EXEC dbo.GetPivotedReport
		@SourceTableName  = 'dbo.MonthlySales',
		@SourcePivotColumnName = 'Yr',
		@SourceLabelColumnName = 'Qtr',
		@SourceDataColumnName = 'TotalSales',
		@OutputLabelColumnName = 'Quarter';

-- Now we'll get a similar view but this time broken down by month
EXEC dbo.GetPivotedReport
		@SourceTableName  = 'dbo.MonthlySales',
		@SourcePivotColumnName = 'Yr',
		@SourceLabelColumnName = 'Mnth',
		@SourceDataColumnName = 'TotalSales',
		@OutputLabelColumnName = 'Month';

-- Back to the quarterly view, but switching the axes
EXEC dbo.GetPivotedReport
		@SourceTableName  = 'dbo.MonthlySales',
		@SourcePivotColumnName = 'Qtr',
		@SourceLabelColumnName = 'Yr',
		@SourceDataColumnName = 'TotalSales',
		@OutputLabelColumnName = 'Year';

-- Bringing another dimension in, we can track each category over time
EXEC dbo.GetPivotedReport
		@SourceTableName  = 'dbo.MonthlySales',
		@SourcePivotColumnName = 'Yr',
		@SourceLabelColumnName = 'Category',
		@SourceDataColumnName = 'TotalSales',
		@OutputLabelColumnName = 'Category';


-- Finally, we have a report showing relative historical sales for each category in each quarter
EXEC dbo.GetPivotedReport
		@SourceTableName  = 'dbo.MonthlySales',
		@SourcePivotColumnName = 'Category',
		@SourceLabelColumnName = 'Qtr',
		@SourceDataColumnName = 'TotalSales',
		@OutputLabelColumnName = 'Quarter';

		

-- Clean up
IF OBJECT_ID('dbo.MonthlySales') IS NOT NULL
	DROP TABLE dbo.MonthlySales;
IF OBJECT_ID('dbo.GetPivotedReport') IS NOT NULL
	DROP PROCEDURE dbo.GetPivotedReport;
GO
*/