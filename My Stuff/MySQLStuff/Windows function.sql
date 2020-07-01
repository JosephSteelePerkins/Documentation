
use DiamondDW

-- identify duplicates
--https://www.red-gate.com/simple-talk/sql/t-sql-programming/introduction-to-t-sql-window-functions/

CREATE TABLE #Duplicates(Col1 INT, Col2 CHAR(1));
INSERT INTO #Duplicates(Col1, Col2) 
VALUES(1,'A'),(2,'B'),(2,'B'),(2,'B'),
	(3,'C'),(4,'D'),(4,'D'),(5,'E'),
	(5,'E'),(5,'E');
SELECT * FROM #Duplicates;

SELECT Col1, Col2, 
   ROW_NUMBER() OVER(PARTITION BY Col1, Col2 ORDER BY Col1) AS RowNum
FROM #Duplicates;

-- now delete them. But this doesn't work

DELETE #Duplicates 
WHERE ROW_NUMBER() OVER(PARTITION BY Col1, Col2 ORDER BY Col1) <> 1

-- do this by using a CTE

WITH Dupes AS (
   SELECT Col1, Col2, 
     ROW_NUMBER() OVER(PARTITION BY Col1, Col2 ORDER BY Col1) AS RowNum
   FROM #Duplicates)
DELETE Dupes 
WHERE RowNum <> 1;
SELECT * FROM #Duplicates;

-- differences between row_number, rank and dense rank

USE Adventureworks2017; --Or whichever version you have
GO
SELECT SalesOrderID, OrderDate, CustomerID, 
	ROW_NUMBER() OVER(ORDER BY OrderDate) As RowNum,
	RANK() OVER(ORDER BY OrderDate) As Rnk,
	DENSE_RANK() OVER(ORDER BY OrderDate) As DenseRnk
FROM Sales.SalesOrderHeader
WHERE CustomerID = 11330;

-- ntile

SELECT SP.FirstName, SP.LastName,
	SUM(SOH.TotalDue) AS TotalSales, 
	NTILE(4) OVER(ORDER BY SUM(SOH.TotalDue)),
	NTILE(4) OVER(ORDER BY SUM(SOH.TotalDue)) * 1000 AS Bonus
FROM [Sales].[vSalesPerson] SP 
JOIN Sales.SalesOrderHeader SOH 
     ON SP.BusinessEntityID = SOH.SalesPersonID 
WHERE SOH.OrderDate >= '2012-01-01' AND SOH.OrderDate < '2013-01-01'
GROUP BY FirstName, LastName;

-- running total






drop table Transactions

create table Transactions (TransactionID int identity(1,1), CustomerID int, MoneyOut int, TranDate datetime)

insert into Transactions 
values (1,10,'20190101'),(1,20,'20190102'),(1,10,'20190102'),(2,10,'20190101'),(2,20,'20190102')


select  CustomerID, MoneyOut, TranDate, sum(moneyout) over(partition by CustomerID order by trandate) as RunningTotal 
FROM Transactions

select *, ROW_NUMBER() over (partition by CustomerID order by trandate)
from Transactions



CREATE TABLE [dbo].[Orders]
(
	order_id INT,
	order_date DATE,
	customer_name VARCHAR(250),
	city VARCHAR(100),	
	order_amount MONEY
)
 
INSERT INTO [dbo].[Orders]
SELECT '1001','04/01/2017','David Smith','GuildFord',10000
UNION ALL	  
SELECT '1002','04/02/2017','David Jones','Arlington',20000
UNION ALL	  
SELECT '1003','04/03/2017','John Smith','Shalford',5000
UNION ALL	  
SELECT '1004','04/04/2017','Michael Smith','GuildFord',15000
UNION ALL	  
SELECT '1005','04/05/2017','David Williams','Shalford',7000
UNION ALL	  
SELECT '1006','04/06/2017','Paum Smith','GuildFord',25000
UNION ALL	 
SELECT '1007','04/10/2017','Andrew Smith','Arlington',15000
UNION ALL	  
SELECT '1008','04/11/2017','David Brown','Arlington',2000
UNION ALL	  
SELECT '1009','04/20/2017','Robert Smith','Shalford',1000
UNION ALL	  
SELECT '1010','04/25/2017','Peter Smith','GuildFord',500

select *, COUNT(1) OVER(PARTITION BY city ORDER BY ORDER_DATE) F
FROM [dbo].[Orders]




SELECT order_id,order_date,customer_name,city, order_amount,
RANK() OVER(ORDER BY order_amount DESC) [Rank]
FROM [dbo].[Orders]

SELECT order_id,order_date,customer_name,city, order_amount,
DENSE_RANK() OVER(ORDER BY order_amount DESC) [Rank]
FROM [dbo].[Orders]


SELECT order_id,order_date,customer_name,city, order_amount,
NTILE(3) OVER(ORDER BY order_amount) [row_number]
FROM [dbo].[Orders]

SELECT order_id,customer_name,city, order_amount,order_date,
 --in below line, 1 indicates check for previous row of the current row
 LAG(order_date,1) OVER(ORDER BY order_date) prev_order_date
FROM [dbo].[Orders]

--- using window function to get the difference between two times in an audit table

create table AuditTest (AuditID int identity(1,1), AuditDate datetime, ActionDescription varchar(10))
insert into AuditTest(AuditDate, ActionDescription)
values (getdate(),'Load1')

insert into AuditTest(AuditDate, ActionDescription)
values (getdate(),'Load2')

insert into AuditTest(AuditDate, ActionDescription)
values (getdate(),'Load3')

select *, datediff(SECOND, lag(auditdate,1) over(order by AuditDate),AuditDate) TimeTaken
from AuditTest
