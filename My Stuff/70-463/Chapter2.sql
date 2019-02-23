CREATE DATABASE [TK463DW]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TK463DW', FILENAME = N'C:\TK463DW\TK463DW.mdf' , SIZE = 307200KB , FILEGROWTH = 10240KB )
 LOG ON 
( NAME = N'TK463DW_log', FILENAME = N'C:\TK463DW\TK463DW_log.ldf' , SIZE = 51200KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [TK463DW] SET COMPATIBILITY_LEVEL = 140
GO
ALTER DATABASE [TK463DW] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TK463DW] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TK463DW] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TK463DW] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TK463DW] SET ARITHABORT OFF 
GO
ALTER DATABASE [TK463DW] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TK463DW] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TK463DW] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [TK463DW] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TK463DW] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TK463DW] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TK463DW] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TK463DW] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TK463DW] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TK463DW] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TK463DW] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TK463DW] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TK463DW] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TK463DW] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TK463DW] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TK463DW] SET  READ_WRITE 
GO
ALTER DATABASE [TK463DW] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [TK463DW] SET  MULTI_USER 
GO
ALTER DATABASE [TK463DW] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TK463DW] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TK463DW] SET DELAYED_DURABILITY = DISABLED 
GO
USE [TK463DW]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = On;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = Primary;
GO
USE [TK463DW]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [TK463DW] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
ALTER DATABASE TK463DW SET RECOVERY SIMPLE WITH NO_WAIT; GO



USE TK463DW;

GO

IF OBJECT_ID('dbo.SeqCustomerDwKey','SO') IS NOT NULL
DROP SEQUENCE dbo.SeqCustomerDwKey;
GO

CREATE SEQUENCE dbo.SeqCustomerDwKey AS INT
START WITH 1
INCREMENT BY 1;
GO


CREATE TABLE [dbo].[Customers](
	CustomerDwKey int DEFAULT NEXT VALUE FOR SeqCustomerDwKey,
CustomerKey int,
FullName NVARCHAR(150),
EmailAddress NVARCHAR(50),
BirthDate Date,
MaritalStatus NCHAR(1),
Gender NCHAR(1),
Education NVARCHAR(40),
Occupation NVARCHAR(100),
City NVARCHAR(30),
StateProvince NVARCHAR(50),
CountryRegion NVARCHAR(50),
Age AS
CASE
WHEN DATEDIFF(yy, BirthDate, CURRENT_TIMESTAMP) <= 40
THEN 'Younger'
WHEN DATEDIFF(yy, BirthDate, CURRENT_TIMESTAMP) > 50
THEN 'Older'
ELSE 'Middle Age'
END,
CurrentFlag BIT NOT NULL DEFAULT 1,

CONSTRAINT PK_Customers PRIMARY KEY (CustomerDwKey) );

insert into [dbo].[Customers] (CustomerKey, FullName, EmailAddress,BirthDate, MaritalStatus,
Gender, Education, Occupation, City,StateProvince,CountryRegion)
select CustomerKey
,FirstName + Lastname
,EmailAddress
,BirthDate
,MaritalStatus
,Gender
,EnglishEducation
,EnglishOccupation
,dg.City
,dg.StateProvinceName
,dg.EnglishCountryRegionName
from AdventureWorksDW.dbo.DimCustomer d
inner join AdventureWorksDW.dbo.DimGeography dg
on dg.GeographyKey = d.GeographyKey



CREATE TABLE dbo.Products
(
ProductKey INT NOT NULL
, ProductName NVARCHAR(50) NULL,
Color NVARCHAR(15) NULL,
Size NVARCHAR(50) NULL,
SubcategoryName NVARCHAR(50) NULL,
CategoryName NVARCHAR(50) NULL,
CONSTRAINT PK_Products PRIMARY KEY (ProductKey) );

GO

insert into dbo.Products (ProductKey, ProductName, color,size,
SubcategoryName,CategoryName)
select ProductKey
,EnglishProductName
,Color
,size
,spc.EnglishProductSubcategoryName
,pc.EnglishProductCategoryName
from AdventureWorksDW.dbo.DimProduct p
inner join AdventureWorksDW.dbo.DimProductSubcategory spc
on spc.ProductSubcategoryKey = p.ProductSubcategoryKey
inner join AdventureWorksDW.dbo.DimProductCategory pc
on pc.ProductCategoryKey = spc.ProductCategoryKey



CREATE TABLE dbo.Dates
(
DateKey
INT
NOT NULL,
FullDate
DATE
NOT NULL,
MonthNumberName
NVARCHAR(15)
NULL,
CalendarQuarter
TINYINT
NULL,
CalendarYear
SMALLINT
NULL,
CONSTRAINT PK_Dates PRIMARY KEY (DateKey) );

insert into Dates(DateKey, FullDate, MonthNumberName, CalendarQuarter, CalendarYear)
select DateKey
,FullDateAlternateKey
,right(replicate('0', 2) + ltrim(MonthNumberOfYear), 2)
,CalendarQuarter
,CalendarYear
from AdventureWorksDW.dbo.DimDate


CREATE TABLE dbo.InternetSales
(
InternetSalesKey INT
NOT NULL IDENTITY(1,1),
CustomerDwKey INT NOT NULL,
ProductKey INT NOT NULL,
DateKey INT NOT NULL,
OrderQuantity SMALLINT NOT NULL DEFAULT 0,
SalesAmount MONEY NOT NULL DEFAULT 0,
UnitPrice MONEY NOT NULL DEFAULT 0,
DiscountAmount FLOAT NOT NULL DEFAULT 0,
CONSTRAINT PK_InternetSales PRIMARY KEY (InternetSalesKey)
)

ALTER TABLE dbo.InternetSales ADD CONSTRAINT
FK_InternetSales_Customers FOREIGN KEY(CustomerDwKey)
REFERENCES dbo.Customers (CustomerDwKey);
ALTER TABLE dbo.InternetSales ADD CONSTRAINT
FK_InternetSales_Products FOREIGN KEY(ProductKey)
REFERENCES dbo.Products (ProductKey);
ALTER TABLE dbo.InternetSales ADD CONSTRAINT
FK_InternetSales_Dates FOREIGN KEY(DateKey)
REFERENCES dbo.Dates (DateKey);

insert into InternetSales (
CustomerDwKey,
ProductKey,
DateKey,
OrderQuantity,
SalesAmount,
UnitPrice,
DiscountAmount)
select CustomerDwKey,
ProductKey,
OrderDateKey,
OrderQuantity,
SalesAmount,
UnitPrice,
DiscountAmount
from AdventureWorksDW.dbo.FactInternetSales fis
inner join Customers c
on fis.CustomerKey = c.CustomerKey





USE AdventureWorksDW;

GO

SET STATISTICS IO ON;

GO

SELECT ProductKey,
SUM(SalesAmount) AS Sales,
COUNT_BIG(*) AS NumberOfRows
FROM dbo.FactInternetSales
GROUP BY ProductKey;

GO

drop view dbo.SalesByProduct

CREATE VIEW dbo.SalesByProduct
WITH SCHEMABINDING AS
SELECT ProductKey,
SUM(SalesAmount) AS Sales,
COUNT_BIG(*) AS NumberOfRows
FROM dbo.FactInternetSales
GROUP BY ProductKey;
GO

CREATE UNIQUE CLUSTERED INDEX CLU_SalesByProduct

ON dbo.SalesByProduct (ProductKey);

GO

SELECT ProductKey,
SUM(SalesAmount) AS Sales,
COUNT_BIG(*) AS NumberOfRows
FROM dbo.FactInternetSales
GROUP BY ProductKey;

GO

DROP VIEW dbo.SalesByProduct;





SET STATISTICS IO ON; GO
--Query with a self join 
WITH InternetSalesGender AS
(
SELECT ISA.CustomerKey, C.Gender,
ISA.SalesOrderNumber + CAST(ISA.SalesOrderLineNumber AS CHAR(1)) AS OrderLineNumber,
ISA.SalesAmount
FROM dbo.FactInternetSales AS ISA INNER JOIN dbo.DimCustomer AS C
ON ISA.CustomerKey = C.CustomerKey WHERE ISA.CustomerKey <= 12000
)

SELECT ISG1.Gender, ISG1.OrderLineNumber, MIN(ISG1.SalesAmount), SUM(ISG2.SalesAmount) AS RunningTotal 
FROM InternetSalesGender AS ISG1
INNER JOIN InternetSalesGender AS ISG2 ON ISG1.Gender = ISG2.Gender
AND ISG1.OrderLineNumber >= ISG2.OrderLineNumber GROUP BY ISG1.Gender, ISG1.OrderLineNumber
ORDER BY ISG1.Gender, ISG1.OrderLineNumber;


--Query with a window function 
WITH InternetSalesGender AS
(
SELECT ISA.CustomerKey, C.Gender,
ISA.SalesOrderNumber + CAST(ISA.SalesOrderLineNumber AS CHAR(1)) AS OrderLineNumber,
ISA.SalesAmount
FROM dbo.FactInternetSales AS ISA INNER JOIN dbo.DimCustomer AS C
ON ISA.CustomerKey = C.CustomerKey WHERE ISA.CustomerKey <= 12000
)

SELECT ISG.Gender, ISG.OrderLineNumber, ISG.SalesAmount, SUM(ISG.SalesAmount)
OVER(PARTITION BY ISG.Gender ORDER BY ISG.OrderLineNumber
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW) AS RunningTotal FROM InternetSalesGender AS ISG
ORDER BY ISG.Gender, ISG.OrderLineNumber; GO



EXEC sp_spaceused N'dbo.InternetSales', @updateusage = N'TRUE';

/*
InternetSales	60398               	3208 KB	3064 KB	16 KB	128 KB
*/

ALTER TABLE dbo.InternetSales
REBUILD WITH (DATA_COMPRESSION = PAGE);

EXEC sp_spaceused N'dbo.InternetSales', @updateusage = N'TRUE';

/*
InternetSales	60398               	1160 KB	1040 KB	16 KB	104 KB
*/

CREATE COLUMNSTORE INDEX CSI_InternetSales
ON dbo.InternetSales
(InternetSalesKey, CustomerDwKey, ProductKey, DateKey,
OrderQuantity, SalesAmount,
UnitPrice, DiscountAmount);


SELECT C.CountryRegion, P.CategoryName, D.CalendarYear,
SUM(I.SalesAmount) AS Sales
FROM dbo.InternetSales AS I
INNER JOIN dbo.Customers AS C
ON I.CustomerDwKey = C.CustomerDwKey
INNER JOIN dbo.Products AS P
ON I.ProductKey = p.ProductKey
INNER JOIN dbo.Dates AS d
ON I.DateKey = D.DateKey
GROUP BY C.CountryRegion, P.CategoryName, D.CalendarYear
ORDER BY C.CountryRegion, P.CategoryName, D.CalendarYear;

EXEC sp_spaceused N'dbo.InternetSales', @updateusage = N'TRUE';
/*
InternetSales	60398               	1680 KB	1040 KB	424 KB	216 KB
*/




------------ lesson 3 ----------------------------------

drop table InternetSales 

-- create partition function
drop PARTITION FUNCTION PfInternetSalesYear

CREATE PARTITION FUNCTION PfInternetSalesYear (TINYINT)
AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20);

-- create partition schema

drop PARTITION SCHEME PsInternetSalesYear

CREATE PARTITION SCHEME PsInternetSalesYear
AS PARTITION PfInternetSalesYear
ALL TO ([PRIMARY]);

GO

-- recreate table

CREATE TABLE dbo.InternetSales
(
InternetSalesKey INT NOT NULL IDENTITY(1,1),
PCInternetSalesYear TinyInt,
CustomerDwKey INT NOT NULL,
ProductKey INT NOT NULL,
DateKey INT NOT NULL,
OrderQuantity SMALLINT NOT NULL DEFAULT 0,
SalesAmount MONEY NOT NULL DEFAULT 0,
UnitPrice MONEY NOT NULL DEFAULT 0,
DiscountAmount FLOAT NOT NULL DEFAULT 0,
CONSTRAINT PK_InternetSales PRIMARY KEY (InternetSalesKey,PcInternetSalesYear)
)

ON PsInternetSalesYear(PcInternetSalesYear)

ALTER TABLE dbo.InternetSales ADD CONSTRAINT
FK_InternetSales_Customers FOREIGN KEY(CustomerDwKey)
REFERENCES dbo.Customers (CustomerDwKey);
ALTER TABLE dbo.InternetSales ADD CONSTRAINT
FK_InternetSales_Products FOREIGN KEY(ProductKey)
REFERENCES dbo.Products (ProductKey);
ALTER TABLE dbo.InternetSales ADD CONSTRAINT
FK_InternetSales_Dates FOREIGN KEY(DateKey)
REFERENCES dbo.Dates (DateKey);

-- compress table

ALTER TABLE dbo.InternetSales
REBUILD WITH (DATA_COMPRESSION = PAGE);

-- reload
INSERT INTO dbo.InternetSales (PcInternetSalesYear, 
CustomerDwKey, ProductKey, DateKey, OrderQuantity, 
SalesAmount, UnitPrice, DiscountAmount)
SELECT
CAST(SUBSTRING(CAST(FIS.OrderDateKey AS CHAR(8)), 3, 2) AS TINYINT) AS PcInternetSalesYear
, C.CustomerDwKey
,FIS.ProductKey
,FIS.OrderDateKey
,FIS.OrderQuantity
,FIS.SalesAmount
,FIS.UnitPrice
,FIS.DiscountAmount
FROM AdventureWorksDW.dbo.FactInternetSales AS FIS 
INNER JOIN dbo.Customers AS C
ON FIS.CustomerKey = C.CustomerKey 
where CAST(SUBSTRING(CAST(FIS.OrderDateKey AS CHAR(8)), 3, 2) AS TINYINT) < 14

select PcInternetSalesYear, count(*)
from dbo.InternetSales
group by PcInternetSalesYear

CREATE COLUMNSTORE INDEX CSI_InternetSales
ON dbo.InternetSales
(InternetSalesKey, PcInternetSalesYear,
CustomerDwKey, ProductKey, DateKey,
OrderQuantity, SalesAmount,
UnitPrice, DiscountAmount)
ON PsInternetSalesYear(PcInternetSalesYear);


-- create a new version of the table that only accepts one partition

drop table dbo.InternetSalesNew

CREATE TABLE dbo.InternetSalesNew
(
InternetSalesKey INT NOT NULL IDENTITY(1,1),
PCInternetSalesYear TinyInt CHECK (PcInternetSalesYear = 14),
CustomerDwKey INT NOT NULL,
ProductKey INT NOT NULL,
DateKey INT NOT NULL,
OrderQuantity SMALLINT NOT NULL DEFAULT 0,
SalesAmount MONEY NOT NULL DEFAULT 0,
UnitPrice MONEY NOT NULL DEFAULT 0,
DiscountAmount FLOAT NOT NULL DEFAULT 0,
CONSTRAINT PK_InternetSalesNew PRIMARY KEY (InternetSalesKey,PcInternetSalesYear)
)
ALTER TABLE dbo.InternetSalesNew ADD CONSTRAINT
FK_InternetSalesNew_Customers FOREIGN KEY(CustomerDwKey)
REFERENCES dbo.Customers (CustomerDwKey);
ALTER TABLE dbo.InternetSalesNew ADD CONSTRAINT
FK_InternetSalesNew_Products FOREIGN KEY(ProductKey)
REFERENCES dbo.Products (ProductKey);
ALTER TABLE dbo.InternetSalesNew ADD CONSTRAINT
FK_InternetSalesNew_Dates FOREIGN KEY(DateKey)
REFERENCES dbo.Dates (DateKey);

ALTER TABLE dbo.InternetSalesNew
REBUILD WITH (DATA_COMPRESSION = PAGE);

INSERT INTO dbo.InternetSalesNew (PcInternetSalesYear, 
CustomerDwKey, ProductKey, DateKey, OrderQuantity, 
SalesAmount, UnitPrice, DiscountAmount)
SELECT
CAST(SUBSTRING(CAST(FIS.OrderDateKey AS CHAR(8)), 3, 2) AS TINYINT) AS PcInternetSalesYear
, C.CustomerDwKey
,FIS.ProductKey
,FIS.OrderDateKey
,FIS.OrderQuantity
,FIS.SalesAmount
,FIS.UnitPrice
,FIS.DiscountAmount
FROM AdventureWorksDW.dbo.FactInternetSales AS FIS 
INNER JOIN dbo.Customers AS C
ON FIS.CustomerKey = C.CustomerKey 
WHERE CAST(SUBSTRING(CAST(FIS.OrderDateKey AS CHAR(8)), 3, 2)
AS TINYINT) = 14;

CREATE COLUMNSTORE INDEX CSI_InternetSalesNew
ON dbo.InternetSalesNew
(InternetSalesKey, PcInternetSalesYear,
CustomerDwKey, ProductKey, DateKey,
OrderQuantity, SalesAmount,
UnitPrice, DiscountAmount);
GO

-- show how many rows are in each partition

SELECT $PARTITION.PfInternetSalesYear(PcInternetSalesYear)
AS PartitionNumber, COUNT(*) AS NumberOfRows FROM dbo.InternetSales 
GROUP BY
$PARTITION.PfInternetSalesYear(PcInternetSalesYear)


SELECT COUNT(*) AS NumberOfRows
FROM dbo.InternetSalesNew; 

-- perform the switch. This moves everything in the new table into Partition 14

ALTER TABLE dbo.InternetSalesNew
SWITCH TO dbo.InternetSales PARTITION 14;
GO

drop INDEX CSI_InternetSalesNew on InternetSalesNew

truncate table dbo.InternetSalesNew

