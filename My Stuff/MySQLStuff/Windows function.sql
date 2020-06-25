-- how to do a running total

use DiamondDW

create table Transactions (TransactionID int identity(1,1), CustomerID int, MoneyOut int, TranDate datetime)

insert into Transactions 
values (1,10,'20190101'),(1,20,'20190102'),(1,10,'20190102'),(2,10,'20190101'),(2,20,'20190102')


select  CustomerID, MoneyOut, TranDate, max(moneyout) over(partition by CustomerID order by trandate) as RunningTotal 
FROM Transactions



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
