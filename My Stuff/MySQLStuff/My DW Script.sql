-- this is going to model a fact table to represent subscriptions and 4 dimension tables;
-- contact, product, date, subscription status

use DiamondDW

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'FactSubscription')

DROP TABLE dbo.FactSubscription

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimProduct')

DROP TABLE dbo.DimProduct

-------------------- Dim Date --------------------------------------------

DECLARE @StartDate DATE = '20000101', @NumberOfYears INT = 30;

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals

SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

-- this is just a holding table for intermediate calculations:

IF OBJECT_ID('tempdb..#dim') IS NOT NULL
    DROP TABLE #dim

CREATE TABLE #dim
(
  [date]       DATE PRIMARY KEY, 
  [day]        AS DATEPART(DAY,      [date]),
  [month]      AS DATEPART(MONTH,    [date]),
  FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
  [MonthName]  AS DATENAME(MONTH,    [date]),
  [week]       AS DATEPART(WEEK,     [date]),
  [ISOweek]    AS DATEPART(ISO_WEEK, [date]),
  [DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
  [quarter]    AS DATEPART(QUARTER,  [date]),
  [year]       AS DATEPART(YEAR,     [date]),
  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
  Style112     AS CONVERT(CHAR(8),   [date], 112),
  Style101     AS CONVERT(CHAR(10),  [date], 101)
);

-- use the catalog views to generate as many rows as we need

INSERT #dim([date]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    -- on my system this would support > 5 million days
    ORDER BY s1.[object_id]
  ) AS x
) AS y;



USE [DiamondDW]
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimDate')

DROP TABLE [dbo].[DimDate]
GO


CREATE TABLE dbo.DimDate
(
  DateKey           INT         NOT NULL identity (1,1) PRIMARY KEY,
  [Date]              DATE        NOT NULL,
  [Day]               TINYINT     NOT NULL,
  DaySuffix           CHAR(2)     NOT NULL,
  [Weekday]           TINYINT     NOT NULL,
  WeekDayName         VARCHAR(10) NOT NULL,
  IsWeekend           BIT         NOT NULL,
  DOWInMonth          TINYINT     NOT NULL,
  [DayOfYear]         SMALLINT    NOT NULL,
  WeekOfMonth         TINYINT     NOT NULL,
  WeekOfYear          TINYINT     NOT NULL,
  ISOWeekOfYear       TINYINT     NOT NULL,
  [Month]             TINYINT     NOT NULL,
  [MonthName]         VARCHAR(10) NOT NULL,
  [Quarter]           TINYINT     NOT NULL,
  QuarterName         VARCHAR(6)  NOT NULL,
  [Year]              INT         NOT NULL,
  MMYYYY              CHAR(6)     NOT NULL,
  MonthYear           CHAR(7)     NOT NULL
  )

INSERT dbo.DimDate WITH (TABLOCKX)
SELECT
  [Date]        = [date],
  [Day]         = CONVERT(TINYINT, [day]),
  DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
                  CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
	              WHEN '3' THEN 'rd' ELSE 'th' END END),
  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
  [IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
                  (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
                  (PARTITION BY [year], [month] ORDER BY [week])),
  WeekOfYear    = CONVERT(TINYINT, [week]),
  ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
  [Month]       = CONVERT(TINYINT, [month]),
  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
  [Quarter]     = CONVERT(TINYINT, [quarter]),
  QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                  WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
  [Year]        = [year],
  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
  MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4))
FROM #dim


-------------------- DimSubscriptionStatus --------------------------------------------

USE [DiamondDW]
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimSubStatus')

DROP TABLE [dbo].DimSubStatus
GO
CREATE TABLE [dbo].DimSubStatus
(SubStatusKey int identity(1,1) primary key,
SubStatusName varchar(100))

insert into [dbo].DimSubStatus
values ('Active'),('Inactive')


-------------------- DimSource --------------------------------------------

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimSource')

DROP TABLE dbo.DimSource

CREATE TABLE dbo.DimSource
(Source varchar(100) primary key)

insert into dbo.DimSource values ('Viper')

select  *from dbo.DimSource

-------------------- DimProduct --------------------------------------------

USE DiamondDW
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimProduct')

DROP TABLE dbo.DimProduct
GO
CREATE TABLE dbo.DimProduct
(ProductKey int identity(1,1) primary key,
ProductName varchar(100),
ProductBusinessKey varchar(1000),
Source varchar(100),
CreateDate datetime default getdate(),
InferredMember bit default 0,
SourceCreateDate datetime)

-- product business key will only be unique from a particular source
Create unique index x_DimProduct on DimProduct (ProductBusinessKey,Source)

alter table dbo.DimProduct
add constraint fk_DimProduct FOREIGN KEY (Source) REFERENCES DimSource(Source)

-------------------- DimProductUpdate --------------------------------------------


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimProductUpdate')

DROP TABLE dbo.DimProductUpdate
GO
CREATE TABLE dbo.DimProductUpdate
(ProductName varchar(100),
ProductBusinessKey varchar(1000),
Source varchar(100),
SourceCreateDate datetime)


-------------------- DimContact --------------------------------------------

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimContact')

DROP TABLE dbo.DimContact

CREATE TABLE dbo.DimContact
(ContactKey int identity(1,1) primary key,
ContactName varchar(100),
ContactBusinessKey varchar(1000),
Source varchar(100),
EmailAddress varchar(100),
CreateDate datetime default getdate(),
InferredMember bit default 0,
CurrentRecord bit default 1,
ToDate datetime,
TaskID varchar(50),
ExecutionStartTime datetime)

-- contact business key will only be unique from a particular source
--Create unique index x_DimContact on DimContact (ContactBusinessKey,Source)

-- create verison of the table for updates

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimContactUpdate')


DROP TABLE dbo.DimContactUpdate

CREATE TABLE dbo.DimContactUpdate
(ContactName varchar(100),
ContactBusinessKey varchar(1000),
Source varchar(100),
EmailAddress varchar(100))






-------------------- FactSubscription --------------------------------------------

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'FactSubscription')

DROP TABLE dbo.FactSubscription

CREATE TABLE dbo.FactSubscription
(ContactKey int not null,
ProductKey int not null,
SubStatusKey int not null,
AuditDateKey int not null,
StartDateKey int,
EndDateKey int)

-- primary key is a combination of the following keys

alter table dbo.FactSubscription
add constraint pk_FactSubscription primary key (ContactKey,ProductKey,AuditDateKey)

-- create foreign keys

alter table dbo.FactSubscription
add constraint fk_FactSubContact FOREIGN KEY (ContactKey) REFERENCES DimContact(ContactKey)

alter table dbo.FactSubscription
add constraint fk_FactSubProduct FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey)

alter table dbo.FactSubscription
add constraint fk_FactSubStatus FOREIGN KEY (SubStatusKey) REFERENCES DimSubStatus(SubStatusKey)

alter table dbo.FactSubscription
add constraint fk_FactSubAuditDate FOREIGN KEY (AuditDateKey) REFERENCES DimDate(DateKey)

alter table dbo.FactSubscription
add constraint fk_FactSubStartDate FOREIGN KEY (StartDateKey) REFERENCES DimDate(DateKey)

alter table dbo.FactSubscription
add constraint fk_FactSubEndDate FOREIGN KEY (EndDateKey ) REFERENCES DimDate(DateKey)


---- Audit

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Audit')

DROP TABLE dbo.Audit

CREATE TABLE dbo.Audit
(AuditID int identity(1,1) primary key,
AuditDate datetime default getdate(),
TableName varchar(100),
NoOfRow int,
Action varchar(100),
Status varchar(100),
Description varchar(1000))


