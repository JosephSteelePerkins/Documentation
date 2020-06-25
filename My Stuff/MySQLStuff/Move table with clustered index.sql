use master

-- first create a new file group

ALTER DATABASE [AdventureWorksDW] ADD FILEGROUP [Secondary]

-- and then a data 

ALTER DATABASE [AdventureWorksDW] ADD FILE ( NAME = N'AdventureWorksDW2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [Secondary]

-- question, if I try to create a table in a file group without a log file, what will happen?
-- create new 


CREATE TABLE [dbo].[DimCustomerJoe](
	[CustomerKey] [int] NOT NULL,
	[GeographyKey] [int] NULL,
	[CustomerAlternateKey] [nvarchar](15) NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[NameStyle] [bit] NULL,
	[BirthDate] [date] NULL,
	[MaritalStatus] [nchar](1) NULL,
	[Suffix] [nvarchar](10) NULL,
	[Gender] [nvarchar](1) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[YearlyIncome] [money] NULL,
	[TotalChildren] [tinyint] NULL,
	[NumberChildrenAtHome] [tinyint] NULL,
	[EnglishEducation] [nvarchar](40) NULL,
	[SpanishEducation] [nvarchar](40) NULL,
	[FrenchEducation] [nvarchar](40) NULL,
	[EnglishOccupation] [nvarchar](100) NULL,
	[SpanishOccupation] [nvarchar](100) NULL,
	[FrenchOccupation] [nvarchar](100) NULL,
	[HouseOwnerFlag] [nchar](1) NULL,
	[NumberCarsOwned] [tinyint] NULL,
	[AddressLine1] [nvarchar](120) NULL,
	[AddressLine2] [nvarchar](120) NULL,
	[Phone] [nvarchar](20) NULL,
	[DateFirstPurchase] [date] NULL,
	[CommuteDistance] [nvarchar](15) NULL,
 CONSTRAINT [PK_DimCustomer_CustomerKeyJoe] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)
) ON Secondary

-- nothing happens. oh well

SELECT o.[name], o.[type], i.[name], i.[index_id], f.[name] FROM sys.indexes i
INNER JOIN sys.filegroups f
ON i.data_space_id = f.data_space_id
INNER JOIN sys.all_objects o
ON i.[object_id] = o.[object_id] 
WHERE i.data_space_id = f.data_space_id
AND o.type = 'U' -- User Created Tables
and o.name = 'DimCustomerJoe'

-- populate the table

insert into [dbo].[DimCustomerJoe]
select *
from dbo.DimCustomer

ALTER table DimCustomerJoe
drop constraint PK_DimCustomer_CustomerKeyJoe

ALTER table DimCustomerJoe add
 constraint PK_DimCustomer_CustomerKeyJoe PRIMARY KEY CLUSTERED (CustomerKey ASC) 
 on secondary
GO
