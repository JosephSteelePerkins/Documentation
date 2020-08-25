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

DROP  INDEX fIX_SalesOrderDetail_UnitPrice
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


-- try filtered index on dw.contact

-- without an index

select c.source, c.MarketCode, c.SourceContactID, m.ProductCode, m.Status
from dw.contact c
inner join dw.membership m
on c.source = m.source
and c.marketcode = m.marketcode
and c.sourcecontactid = m.sourcecontactid
and c.iscurrent = m.iscurrent
where c.iscurrent = 1 -- 3 min 13 secs

select source, MarketCode, SourceContactID
from dw.Contact
where IsCurrent = 1 --  55 seconds

exec sp_spaceused 'dw.contact'

--index_size
--16 KB

-- with non filtered index. with iscurrent first so it can be used on its own

create index x_dw_contact on dw.contact (iscurrent, source, marketcode,sourcecontactid ) --- 18 min 39 secs

exec sp_spaceused 'dw.contact'

--index_size
--966,912 KB


select c.source, c.MarketCode, c.SourceContactID, m.ProductCode, m.Status
from dw.contact c
inner join dw.membership m
on c.source = m.source
and c.marketcode = m.marketcode
and c.sourcecontactid = m.sourcecontactid
and c.iscurrent = m.iscurrent
where c.iscurrent = 1 -- 2 mins 11 secs

select source, MarketCode, SourceContactID
from dw.Contact
where IsCurrent = 1 -- 37 seconds

select count(1)
from dw.Contact
where IsCurrent = 1 -- 22 seconds

drop index x_dw_contact on dw.contact


-- with filtered index include where column

create index x_contact_filtered on dw.contact (iscurrent, source, marketcode,sourcecontactid ) where iscurrent = 1 --37 seconds

exec sp_spaceused 'dw.contact'

--index_size
--89,520 KB

select source, MarketCode, SourceContactID
from dw.Contact
where IsCurrent = 1 -- 44 seconds

drop index x_contact_filtered on dw.contact

-- with filtered index not including where column

create index x_contact_filtered on dw.contact (source, marketcode,sourcecontactid ) where iscurrent = 1 -- 1 min 49 secs

select source, MarketCode, SourceContactID
from dw.Contact
where IsCurrent = 1 -- 28 seconds