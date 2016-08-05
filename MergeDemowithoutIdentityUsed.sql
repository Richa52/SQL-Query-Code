CREATE TABLE StudentSource
(  
   ID	int  NOT NULL PRIMARY KEY
  ,Name   VARCHAR (25) NULL);

CREATE TABLE StudentTarget
(  
   ID	int  NOT NULL PRIMARY KEY
  ,Name   VARCHAR (25) NULL);

 INSERT INTO StudentSource (ID, Name)
   VALUES (1,'Pooja')
         ,(2,'Kiran')
         ,(3,'Krunal Patel');  
 
 INSERT INTO StudentTarget (ID, Name)
   VALUES (1,'Mona')
         ,(3,'Krunal shah')
		 ,(4,'Vini'); 
SELECT * FROM StudentSource Order by ID;
SELECT * FROM StudentTarget Order by ID;

IF OBJECT_ID( 'tempdb..StudentChanges') IS NOT NULL DROP TABLE StudentChanges;
 
CREATE TABLE StudentChanges(
  ChangeType         NVARCHAR(10)
 ,ID        TINYINT NOT NULL
 ,NewSName    VARCHAR(25) NULL
 ,PrevSName   VARCHAR(25) NULL
 ,UserName           NVARCHAR(100) NOT NULL
 ,DateTimeChanged    DateTime NOT NULL);
 
MERGE  StudentTarget AS T
 USING StudentSource AS S
    ON T.ID = S.ID
WHEN MATCHED AND EXISTS
                    (SELECT S.ID, S.Name
                     EXCEPT
                     SELECT T.ID, T.Name)
THEN
   UPDATE SET
      T.Name = S.Name
WHEN NOT MATCHED BY TARGET
THEN
   INSERT (ID,Name)
   VALUES (S.ID,S.Name )
WHEN NOT MATCHED BY SOURCE THEN DELETE
-------------------------------------
OUTPUT
   $ACTION ChangeType,
   coalesce (inserted.ID, deleted.ID) ID,
   inserted.Name NewSName,
   deleted.Name PrevSName,
   SUSER_SNAME() UserName,
   Getdate () DateTimeChanged
    INTO StudentChanges
-------------------------------------
;
 
SELECT * FROM StudentChanges;
SELECT * FROM StudentSource Order by ID;
SELECT * FROM StudentTarget Order by ID;
