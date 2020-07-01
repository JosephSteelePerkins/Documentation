SELECT SalesOrderDetailID, UnitPrice
FROM AdventureWorks2017.Sales.SalesOrderDetail
WHERE UnitPrice > 2000
order by UnitPrice

-- esimated subtree cost = 1.04
-- create the index that the estimated execution plan requires

USE AdventureWorks2017
GO
CREATE NONCLUSTERED INDEX ncIX_SalesOrderDetail_UnitPrice
ON [Sales].[SalesOrderDetail] ([UnitPrice])

-- this improves the query
-- estimated subtree cost = 0.03

drop index [<Name of Missing Index, sysname,>] on [Sales].[SalesOrderDetail]

-- now create a filtered index

drop  INDEX fIX_SalesOrderDetail_UnitPrice
ON AdventureWorks2017.Sales.SalesOrderDetail

CREATE NONCLUSTERED INDEX fIX_SalesOrderDetail_UnitPrice
ON AdventureWorks2017.Sales.SalesOrderDetail(UnitPrice)
WHERE UnitPrice > 1000

-- improved even more estimated subtree cost = 0.01


USE AdventureWorks2017
GO
EXECUTE sp_spaceused 'Sales.SalesOrderDetail'

SELECT
OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName,
OBJECT_NAME(i.OBJECT_ID) AS TableName,
i.name AS IndexName,
i.index_id AS IndexID,
8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY i.OBJECT_ID,i.index_id,i.name
ORDER BY OBJECT_NAME(i.OBJECT_ID),i.index_id


https://www.red-gate.com/simple-talk/sql/performance/introduction-to-sql-server-filtered-indexes/


-- Sparse columns -- columns that contain mostly nulls
-- filtered indexes are good for sparse columns because you are not wasting space on values that will never be searched for
