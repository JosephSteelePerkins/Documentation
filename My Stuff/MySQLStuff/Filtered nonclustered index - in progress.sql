SELECT SalesOrderDetailID, UnitPrice
FROM AdventureWorks.Sales.SalesOrderDetail
WHERE UnitPrice > 2000

-- esimated subtree cost = 1.04
-- create the index that the estimated execution plan requires

USE [AdventureWorks]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Sales].[SalesOrderDetail] ([UnitPrice])

-- this improves the query
-- estimated subtree cost = 0.03

drop index [<Name of Missing Index, sysname,>] on [Sales].[SalesOrderDetail]

-- now create a filtered index

CREATE NONCLUSTERED INDEX fIX_SalesOrderDetail_UnitPrice
ON AdventureWorks.Sales.SalesOrderDetail(UnitPrice)
WHERE UnitPrice > 1000

-- improved even more estimated subtree cost = 0.01


USE AdventureWorks
GO
EXECUTE sp_spaceused 'Sales.SalesOrderDetail'

https://www.red-gate.com/simple-talk/sql/performance/introduction-to-sql-server-filtered-indexes/