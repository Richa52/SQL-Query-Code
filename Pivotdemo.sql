--https://blogs.msdn.microsoft.com/kenobonn/2009/03/22/pivot-on-two-or-more-fields-in-sql-server/
--http://www.kodyaz.com/articles/t-sql-pivot-tables-in-sql-server-tutorial-with-examples.aspx
--SQL to create tables and insert data here…

CREATE TABLE Account
(  
	ID	INT IDENTITY(1,1)  NOT NULL PRIMARY KEY
	,PERIOD 	bigint
	,ACCOUNT    VARCHAR (50) NULL
	,VALUE  bigint NULL);


INSERT INTO Account(PERIOD, ACCOUNT, VALUE) VALUES
(2000,' Asset',205 ),
(2000,'Equity',365 ),
(2000,'Profit',524 ),
(2001,' Asset',142 ),
(2001,'Equity',214 ),
(2001,'Profit',421 ),
(2002,' Asset',421 ),
(2002,'Equity',163 ),
(2002,'Profit',325 )

SELECT * FROM Account ORDER BY ID



SELECT *
FROM
(
SELECT *
FROM Account
) AS source
PIVOT
(
    MAX([Value])
    FOR [Period] IN ([2000], [2001], [2002])
) as pvt

SELECT ACCOUNT,
      MAX(CASE WHEN Period = '2000' THEN Value ELSE NULL END) [2000],
      MAX(CASE WHEN Period = '2001' THEN Value ELSE NULL END) [2001],
      MAX(CASE WHEN Period = '2002' THEN Value ELSE NULL END) [2002]
FROM Account
GROUP BY Account

DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.period) 
            FROM Account c
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

set @query = 'SELECT account, ' + @cols + ' from 
            (
                select account
                    , value
                    , period
                from Account
           ) x
            pivot 
            (
                 max(value)
                for period in (' + @cols + ')
            ) p '


execute(@query)
