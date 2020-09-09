use AdventureWorks2017

SELECT *
INTO Person.AddressIndexTest
FROM Person.Address a

select * from person.AddressIndexTest

CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
DBCC FREESYSTEMCACHE('ALL');
GO

SET STATISTICS IO on
select addressid
from  person.AddressIndexTest
where addressid > 25500
SET STATISTICS IO off
create nonclustered index x_AddressIndexTest on person.AddressIndexTest (AddressID)


-- force it to ignore the index
select addressid
from  person.AddressIndexTest WITH (INDEX(0))
where addressid > 25500
