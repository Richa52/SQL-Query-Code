CREATE TABLE Customer_Orig
(  
   CustomerNo    TINYINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CustomerNo PRIMARY KEY
  ,CustomerName   VARCHAR (25) NULL
  ,Planet         VARCHAR (25) NULL);

  CREATE TABLE Customer_New
(  CustomerNo    TINYINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CustomerNo_New PRIMARY KEY
  ,CustomerName   VARCHAR (25) NULL
  ,Planet         VARCHAR (25) NULL);

 INSERT INTO Customer_New (CustomerName, Planet)
   VALUES ('Ankita', 'Tatooine')
         ,('pooja', 'Coruscant')
         ,('Krunal', 'Coruscant');  
 
INSERT INTO Customer_Orig ( CustomerName, Planet)
   VALUES ('Mona', 'Coruscant')
         ,('Vini', 'Coruscant')
         ,('Dev', 'Death Star')
		  ,('Raj', 'Death Star');

SELECT * FROM Customer_Orig Order by CustomerNo;
SELECT * FROM Customer_New Order by CustomerNo;
SELECT * FROM CustomerChanges;

MERGE  Customer_New AS t
 USING Customer_Orig AS s
    ON t.CustomerNo = s.CustomerNo
WHEN MATCHED AND EXISTS
                    (SELECT s.CustomerName, s.Planet
                     EXCEPT
                     SELECT t.CustomerName, t.Planet)
THEN
   UPDATE SET
      t.CustomerName = s.CustomerName
     ,t.Planet = s.Planet
WHEN NOT MATCHED BY TARGET
THEN
   INSERT (CustomerName, Planet)
   VALUES (s.CustomerName, s.Planet)
WHEN NOT MATCHED BY SOURCE THEN DELETE
-------------------------------------
OUTPUT $action, inserted.*, deleted.*
-------------------------------------
;

IF OBJECT_ID( 'tempdb..#CustomerChanges') IS NOT NULL DROP TABLE CustomerChanges;
 
CREATE TABLE CustomerChanges(
  ChangeType         NVARCHAR(10)
 ,CustomerNum        TINYINT NOT NULL
 ,NewCustomerName    VARCHAR(25) NULL
 ,PrevCustomerName   VARCHAR(25) NULL
 ,NewPlanet          VARCHAR(25) NULL
 ,PrevPlanet         VARCHAR(25) NULL
 ,UserName           NVARCHAR(100) NOT NULL
 ,DateTimeChanged    DateTime NOT NULL);
 

MERGE  Customer_New AS t
 USING Customer_Orig AS s
    ON t.CustomerNo = s.CustomerNo
WHEN MATCHED AND EXISTS
                    (SELECT s.CustomerName, s.Planet
                     EXCEPT
                     SELECT t.CustomerName, t.Planet)
THEN
   UPDATE SET
      t.CustomerName = s.CustomerName
     ,t.Planet = s.Planet
WHEN NOT MATCHED BY TARGET
THEN
   INSERT (CustomerName, Planet)
   VALUES (s.CustomerName, s.Planet)
WHEN NOT MATCHED BY SOURCE THEN DELETE
-------------------------------------
OUTPUT
   $ACTION ChangeType,
   coalesce (inserted.CustomerNo, deleted.CustomerNo) CustomerNo,
   inserted.CustomerName NewCustomerName,
   deleted.CustomerName PrevCustomerName,
   inserted.Planet NewPlanet,
   deleted.Planet PrevPlanet,
   SUSER_SNAME() UserName,
   Getdate () DateTimeChanged
   INTO CustomerChanges
-------------------------------------
;
 
SELECT * FROM CustomerChanges;