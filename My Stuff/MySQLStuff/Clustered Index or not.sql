
-- create pretty big table as a heap

USE [AdventureWorks2017]
GO

drop table #temp

create table #temp (F1 int) 
insert into #temp values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)


drop SEQUENCE SalesOrderDetail_Seq

CREATE SEQUENCE SalesOrderDetail_Seq
 AS INTEGER
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 NO CYCLE; 

 drop table [Sales].[SalesOrderDetail_NoClustered]

CREATE TABLE [Sales].[SalesOrderDetail_NoClustered](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] ,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL)

drop table [Sales].[SalesOrderDetail_Clustered]

CREATE TABLE [Sales].[SalesOrderDetail_Clustered](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int],
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL)

-- create clustered index on SalesOrderDetail_Clustered

create clustered index x_SalesOrderDetail_Clustered on [Sales].[SalesOrderDetail_Clustered] ( SalesOrderDetailID)

truncate table [Sales].[SalesOrderDetail_NoClustered]

insert into [Sales].[SalesOrderDetail_NoClustered] ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate]
		   ,SalesOrderDetailID)
SELECT [SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate]
		   ,NEXT VALUE FOR SalesOrderDetail_Seq
from [Sales].[SalesOrderDetail]
cross join #temp -- 30 seconds, 3396876 rows

truncate table [Sales].[SalesOrderDetail_Clustered]

insert into [Sales].[SalesOrderDetail_Clustered] ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate]
		   ,SalesOrderDetailID)
SELECT [SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate]
		   ,NEXT VALUE FOR SalesOrderDetail_Seq
from [Sales].[SalesOrderDetail]
cross join #temp -- 27 seconds, 3396876 rows


-- how long does it take to select all records?

select * from [Sales].[SalesOrderDetail_Clustered] -- 36 seconds
select * from [Sales].[SalesOrderDetail_NoClustered] -- 36 seconds


-- how long does it take to select records of a particular unit price?

set statistics time off

select Unitprice from [Sales].[SalesOrderDetail_Clustered] where Unitprice > 5 -- 37 seconds
select Unitprice from [Sales].[SalesOrderDetail_NoClustered] where Unitprice > 5 -- 35 seconds

-- how big is the table?

exec sp_spaceused 'Sales.SalesOrderDetail_Clustered'

--name	rows	reserved	data	index_size	unused
--SalesOrderDetail_Clustered	3396876             	281544 KB	280128 KB	1264 KB	152 KB

exec sp_spaceused 'Sales.SalesOrderDetail_NoClustered'

--name	rows	reserved	data	index_size	unused
--SalesOrderDetail_NoClustered	3396876             	276232 KB	276192 KB	8 KB	32 KB

-- try to prove that loading into a table with a clustered index takes longer
-- create a table that has the SalesOrderDetailID in non sequential order

drop table #t

select *
into #t
from [Sales].[SalesOrderDetail_Clustered]
where SalesOrderDetailID >= 2000000 
union
select *
from [Sales].[SalesOrderDetail_Clustered]
where SalesOrderDetailID < 2000000 and SalesOrderDetailID > 1000000
union
select *
from [Sales].[SalesOrderDetail_Clustered]
where SalesOrderDetailID < 1000000 

-- create a much bigger table to test inserts into clustered and non-clustered

select t.*, SalesOrderDetail_Seq.new
from #t t
cross join #temp

truncate table [Sales].[SalesOrderDetail_Clustered]
truncate table [Sales].[SalesOrderDetail_NoClustered]

insert into [Sales].[SalesOrderDetail_Clustered]
select * from #t2 

-- 1st attempt 8 mins 2 secs
-- 2nd attempt 5 mins 51 secs
-- 3rd attempt 6 mins 35 secs
-- 4th attempt 9 mins 17 secs

select * from [Sales].[SalesOrderDetail_Clustered]

insert into [Sales].[SalesOrderDetail_NoClustered]
select * from #t2 

-- 1st attempt 6 mins 29 secs
-- 2nd attempt 3 mins 46 secs
-- 3rd attempt 6 mins 39 secs
-- 4th attempt 7 mins 

-- try to prove that is actually a primary key that slows down the insert


CREATE TABLE [Sales].[SalesOrderDetail_PrimaryKeyAndClustered](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] primary key,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL)

truncate table [Sales].[SalesOrderDetail_PrimaryKeyAndClustered]

select * from [Sales].[SalesOrderDetail_PrimaryKeyAndClustered]

insert into [Sales].[SalesOrderDetail_PrimaryKeyAndClustered]
select * from #t2 -- 




----------- compare creating indexes on the two tables


exec sp_spaceused 'Sales.SalesOrderDetail_Clustered'

--name	rows	reserved	data	index_size	unused
--SalesOrderDetail_Clustered	2426340             	201160 KB	200096 KB	904 KB	160 KB

exec sp_spaceused 'Sales.SalesOrderDetail_NoClustered'

--name	rows	reserved	data	index_size	unused
--SalesOrderDetail_NoClustered	2426340             	197320 KB	197280 KB	8 KB	32 KB

create index x_SalesOrderDetail_Clustered_Nonclustered on Sales.SalesOrderDetail_Clustered (Unitprice)

create index x_SalesOrderDetail_noClustered_Nonclustered on Sales.SalesOrderDetail_NoClustered (Unitprice)