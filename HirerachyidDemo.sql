--https://dotnetstories.wordpress.com/2011/11/15/using-hierarchyid-system-data-type-in-sql-server-2008/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Hierarchies]') AND type in (N'U'))
DROP TABLE [dbo].[Hierarchies]
 
-- Step 1 we create a table. In that table one of the fields is a field of type HierarchyID.In that table we will store the data 
CREATE TABLE Hierarchies
(
[HierarchyID] hierarchyid PRIMARY KEY CLUSTERED,
EmployeeID int UNIQUE NOT NULL,
EmployeeName varchar(50) NOT NULL,
Title varchar(50) NULL
) ;
GO
 
SELECT HierarchyID.ToString(), HierarchyID, EmployeeID, EmployeeName, Title
FROM Hierarchies

-- Step 2  Now let’s insert the data in the Hierarchies table.We will insert the CEO (Nick) first. In the same query window type the following.
INSERT INTO Hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (hierarchyid::GetRoot(), 1,'Nick','CEO')
 
SELECT [HierarchyID].ToString(), [HierarchyID], EmployeeID, EmployeeName, Title
FROM Hierarchies

-- Step 3 Now we need to insert a child node. We will insert the descendants of root node. In our case they are Jane,Mary,John 
--who are the General Managers and report to Nick.

DECLARE @GenMgr hierarchyid
SELECT @GenMgr = [HierarchyID]FROM Hierarchies WHERE EmployeeID = 1
INSERT INTO Hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@GenMgr.GetDescendant(NULL, NULL), 2, 'Jane', 'General Manager') ;
 
SELECT [HierarchyID].ToString(), [HierarchyID], EmployeeID, EmployeeName, Title
FROM Hierarchies

-- Step 4 Now I will add the other 2 General Managers Mary and John.In the same query window type

--Insert Child (Mary)
DECLARE @Mgr hierarchyid
DECLARE @LastEmp hierarchyid
 
SELECT @Mgr = [HierarchyID] FROM hierarchies WHERE employeename = 'Nick'
SELECT @LastEmp = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr
 
INSERT INTO hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr.GetDescendant(@LastEmp, NULL), 3, 'Mary', 'General Manager') ;
 
Go
 
--Insert Child (John)
DECLARE @Mgr hierarchyid
DECLARE @LastEmp hierarchyid
 
SELECT @Mgr = [HierarchyID] FROM hierarchies WHERE employeename = 'Nick'
SELECT @LastEmp = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr
 
INSERT INTO hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr.GetDescendant(@LastEmp, NULL), 4, 'John', 'General Manager') ;
 
SELECT [HierarchyID].ToString(), [HierarchyID], EmployeeID, EmployeeName, Title
FROM Hierarchies

-- We use the GetDescendant() method to achieve that.It returns the child node of a given parent node.We also use the GetAncestor() method which
-- returns the ancestor of a given child node.

-- Step 5 Now I will use insert George and Diane as Marketing Managers that report to Jane.In the same query window type

--Insert Child (George)
DECLARE @Mgr1 hierarchyid
DECLARE @LastEmp1 hierarchyid
 
SELECT @Mgr1 = [HierarchyID] FROM hierarchies WHERE employeename = 'Jane'
SELECT @LastEmp1 = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr1
 
INSERT INTO hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr1.GetDescendant(@LastEmp1, NULL), 5, 'George', 'Marketing Manager') ;
 
GO
--Insert Child (Diane)
DECLARE @Mgr hierarchyid
DECLARE @LastEmp hierarchyid
 
SELECT @Mgr = [HierarchyID] FROM hierarchies WHERE employeename = 'Jane'
SELECT @LastEmp = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr
 
INSERT INTO hierarchies  ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr.GetDescendant(@LastEmp, NULL), 6, 'Diane', 'Marketing Manager') ;
 
SELECT [HierarchyID].ToString(), [HierarchyID], EmployeeID, EmployeeName, Title
FROM Hierarchies -- ORDER BY dbo.Hierarchies.EmployeeID -- you will see George and Diane inserted as descendants of the parent node Jane.


-- Step 6 Now I will insert into the Hierarchies table Kate who is the Sales Manager who reports to John.

--Insert Child (Kate)
DECLARE @Mgr2 hierarchyid
DECLARE @LastEmp2 hierarchyid
 
SELECT @Mgr2 = [HierarchyID] FROM hierarchies WHERE employeename = 'John'
SELECT @LastEmp2 = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr2

 
INSERT INTO hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr2.GetDescendant(@LastEmp2, NULL), 7, 'lina', 'Sales Manager') ;
 
SELECT [HierarchyID].ToString(), [HierarchyID], EmployeeID, EmployeeName, Title
FROM Hierarchies   -- Kate will be inserted as a child node to the parent node John.

-- Step 7  Now I will insert into the Hierarchies table Frank who is Internet and Social Media Marketing Manager and reports to George.
--I will also add Gregory who is the Marketing and Research coordinator and reports to Diane.

--Insert Child (Frank)
DECLARE @Mgr3 hierarchyid
DECLARE @LastEmp3 hierarchyid
 
SELECT @Mgr3 = [HierarchyID] FROM hierarchies WHERE employeename = 'George'
SELECT @LastEmp3 = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr3

INSERT INTO hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr3.GetDescendant(@LastEmp3, NULL), 8, 'Frank', 'Internet and Social Media Marketing Manager');
 
GO
 
--Insert Child (Gregory)
DECLARE @Mgr hierarchyid
DECLARE @LastEmp hierarchyid
 
SELECT @Mgr = [HierarchyID] FROM hierarchies WHERE employeename = 'Diane'

SELECT @LastEmp = Max([HierarchyID].ToString()) FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr
 
INSERT INTO hierarchies ([HierarchyID], EmployeeID, EmployeeName, Title)
VALUES (@Mgr.GetDescendant(@LastEmp, NULL), 9, 'Gregory ', 'Marketing and Research') ;

SELECT [HierarchyID].ToString(), [HierarchyID], EmployeeID, EmployeeName, Title
FROM Hierarchies 

-- Step 8 Finally I will show you how to get the direct descendants of Jane and to find the Ancenstor of Jane. In a new query window type

--To Find all direct descendants of Jane
DECLARE @Mgr4 hierarchyid
SELECT @Mgr4 = [HierarchyID] FROM hierarchies WHERE EmployeeName = 'Jane'
SELECT [HierarchyID].ToString(), * FROM hierarchies WHERE [HierarchyID].GetAncestor(1) = @Mgr4


DECLARE @Mgr5 hierarchyid
SELECT @Mgr5 = [HierarchyID] FROM hierarchies WHERE EmployeeName = 'Jane'
SELECT [HierarchyID].ToString(), * FROM hierarchies WHERE [HierarchyID].GetAncestor(2) = @Mgr5

--To Find the Ancenstor of Jane
DECLARE @emp hierarchyid
SELECT @emp = [HierarchyID] FROM hierarchies WHERE EmployeeName = 'Jane'
SELECT * FROM hierarchies WHERE @emp.GetAncestor(1) = [HierarchyID]
 