  select top 10 * from [AdventureWorks2019].[Person].[Person] 

  select top 10 * FROM [AdventureWorks2019].[Person].[EmailAddress]

  select top 10 * from AdventureWorks2019.Person.BusinessEntity

  select BusinessEntityID, count(1) from AdventureWorks2019.Person.BusinessEntity group by BusinessEntityID having count(1) > 1


  select count(1) from AdventureWorks2019.Person.BusinessEntity -- 20777
    select count(1) from AdventureWorks2019.Person.[Person] -- 19972

----------------- CREATE INITIAL SET OF DATA

---------- contact

drop table #adventureworks

select EmailAddress, p.FirstName, p.LastName, p.ModifiedDate, a.PostalCode
into #adventureworks
from AdventureWorks2019.Person.BusinessEntity be
inner join [AdventureWorks2019].[Person].[Person] p
on be.BusinessEntityID = p.BusinessEntityID
inner join [AdventureWorks2019].[Person].[EmailAddress] e
on e.BusinessEntityID = be.BusinessEntityID
inner join [AdventureWorks2019].Person.BusinessEntityAddress ba
on ba.BusinessEntityID = be.BusinessEntityID
inner join [AdventureWorks2019].Person.Address a
on a.AddressID = ba.AddressID

drop SEQUENCE SourceContactID_Seq

CREATE SEQUENCE  SourceContactID_Seq
 AS INTEGER
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 NO CYCLE; 

 drop table #temp

 create table #temp (F1 int) 
insert into #temp values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16)
,(17),(18),(19),(20),(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),(41),(42),(43),(44),(45),(46),(47),(48),(49),(50)

select * from ctl.Source

select * from etl.Contact

truncate table etl.Contact

-- Eloqua

insert into etl.Contact (SourceContactID, Source, MarketCode, Email,FirstName,LastName,SourceCreateDate)
select  cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10)) SourceContactID
,source
,MarketCode
,EmailAddress
,FirstName
,LastName
,CreateDate
from
(
select 'EXT' Source, 'BAN' MarketCode, cast(f1 as varchar(10)) + 'be' + EmailAddress EmailAddress, cast(f1 as varchar(10)) + FirstName  + 'e' FirstName,  LastName, dateadd(dd,f1,ModifiedDate) CreateDAte, PostalCode
from #adventureworks
cross join #temp
where f1 not in (1,10)
union
select 'EXT' Source, 'BAN' MarketCode, 'b' + EmailAddress, FirstName, LastName, dateadd(dd,f1,ModifiedDate) CreateDAte, PostalCode
from #adventureworks
cross join #temp
where f1 in (1,10)) x

select SourceContactID
from etl.Contact
group by SourceContactID
having count(1) >1 


select count(1)
from
(select Email
from etl.Contact
group by Email
having count(1) >1 ) x

-- AMPS



insert into etl.Contact (SourceContactID, Source, MarketCode, Email,FirstName,LastName,SourceCreateDate)
select  cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10)) SourceContactID
,source
,MarketCode
,EmailAddress
,FirstName
,LastName
,CreateDate
from
(
select 'HOT' Source, 'BAN' MarketCode, cast(f1 as varchar(10)) + 'b' + EmailAddress EmailAddress, cast(f1 as varchar(10)) + FirstName + 'h' FirstName,  LastName, dateadd(yy,-1,dateadd(dd,f1,ModifiedDate)) CreateDate, PostalCode
from #adventureworks
cross join #temp
where f1 not in (1,10)
union
select 'HOT' Source, 'BAN' MarketCode, 'b' + EmailAddress, 'h' + FirstName, LastName, dateadd(yy,-1,dateadd(dd,f1,ModifiedDate)) CreateDAte, PostalCode
from #adventureworks
cross join #temp
where f1 in (1,10)) x

-- check sources

select Source, marketcode, count(1)
from etl.Contact
group by Source, marketcode

-- there should be emails that exist accross sources. are there?

select Email, count(distinct source)
from etl.Contact
group by Email
having count(distinct source) > 1

select * from etl.Contact where Email = 'cassie8@adventure-works.com'

-- eyeball the records

select * from etl.Contact

select * from dw.Contact where SourceContactID = '3757001'

-- load into DW

select count(1) from dw.Contact -- 0
select count(1) from etl.Contact -- 1,878,500

select *
from dw.Contact
where marketcode = 'BAN'





-- check insert is correct

select d.LastName, c.LastName
from dw.Contact d
inner join etl.Contact c
on d.Source = c.Source
and d.SourceContactID = c.SourceContactID
and d.MarketCode = c.MarketCode

select source, iscurrent, count(1)
from dw.Contact 
where Source in ('hot','ext')
group by source, IsCurrent

select count(1) from dw.Contact where iscurrent = 1

---------- membership

select DATEPART(yyyy,SourceCreateDate), count(1)
from etl.Contact
group by DATEPART(yyyy,SourceCreateDate)

select * from etl.contact

truncate table etl.membership

insert into etl.Membership(source, MarketCode, sourcecontactid, productcode, status, SourceCreateDate)

select source, MarketCode, SourceContactID, 'BACOM' ProductCode, 'Active' Status, SourceCreateDate
from etl.Contact
where DATEPART(yyyy,SourceCreateDate) <> '2012'
union
select source, MarketCode, SourceContactID, 'BACOM' ProductCode, 'Inactive' Status, SourceCreateDate
from etl.Contact
where DATEPART(yyyy,SourceCreateDate) = '2012'
union
select source, MarketCode, SourceContactID, 'BAPAT' ProductCode, 'Active' Status, SourceCreateDate
from etl.Contact
where DATEPART(yyyy,SourceCreateDate) <> '2013'
union
select source, MarketCode, SourceContactID, 'BAPAT' ProductCode, 'Inactive' Status, SourceCreateDate
from etl.Contact
where DATEPART(yyyy,SourceCreateDate) = '2013'

-- check all membership is in contact

select *
from etl.Membership m
left join etl.Contact c
on m.Source = c.Source
and m.SourceContactID = c.SourceContactID
and m.MarketCode = c.MarketCode
where c.MarketCode is null

exec [etl].[sp_Load_DW_Membership] 1

-- make sure all membership has IsCurrent flagged

select iscurrent, count(1)
from dw.Membership 
group by IsCurrent

-- marke sure all membership is in contact

select count(1)
from dw.Membership m
left join dw.Contact c
on c.source = m.source
and c.marketcode = m.marketcode
and c.sourcecontactid = m.sourcecontactid
where c.source is null



------------- CREATE INCREMENTAL DATA

-- first, back up etl tables

drop table etl.membership_bk

select *
into etl.membership_bk
from etl.membership

drop table etl.contact_bk

select *
into etl.contact_bk
from etl.contact


-------------- contact

select count(1) from etl.contact -- 1,878,500

-- update the last name for half the records

select min(row_id), max(row_id), max(row_id)/2
from etl.contact

select count(1) from etl.Contact where row_id < 939250 -- 939,249

update etl.contact
set LastName = LastName + 'ff',
SourceLastUpdateDate = getdate()
where row_id  < 939250

select count(1) from dw.contact -- 1878500

exec [etl].[sp_Load_DW_Contact]

select count(1)
from dw.contact -- 2817749

select createdate, count(1) , max(lastname), min(lastname)
from dw.Contact
group by createdate
order by 1

select count(1) from dw.Contact where IsCurrent = 1

-- loop through 100 iterations of the above choosing a different set of records each time

declare @looper int

set @looper = 1

while @looper <= 10

begin

update etl.contact
set LastName = LastName + '_' + cast(@looper as varchar),
SourceLastUpdateDate = getdate()
where row_id % 10 = @looper % 10

exec [etl].[sp_Load_DW_Contact] @looper

set @looper = @looper + 1
end

select * from etl.Contact

select SourceLastUpdateDate, count(1)
from etl.Contact
group by SourceLastUpdateDate
order by 1

select SourceLastUpdateDate, min(lastname), max(lastname), count(1)
from etl.Contact
group by SourceLastUpdateDate
order by 1

select createdate, min(lastname), max(lastname), count(1)
from dw.Contact
--where lastname like '%[_]%'
group by CreateDate
order by 1

delete from dw.Contact where CreateDate > '2020-08-24 16:44:46.700'


select  row_id % 10, count(1)
from etl.Contact
group by row_id % 10


-- reset from backup



update etl.contact set SourceLastUpdateDate = null

update etl.contact
set lastname = left(lastname,CHARINDEX( '_', lastname)-1)
from etl.contact 
where lastname like '%[_]%'

select * from etl.contact

update etl.contact
set lastname = cb.LastName
from etl.contact c
inner join etl.contact_bk cb
on c.row_id = cb.row_id
where c.lastname <> cb.lastname




-------------- membership

truncate table etl.membership

insert into etl.membership (source, marketcode, sourcecontactid, productcode, status, sourcecreatedate, startdate, enddate)
select source, marketcode, sourcecontactid, productcode, status, sourcecreatedate, startdate, enddate
from dw.membership

select source, sourcecontactid, marketcode, productcode
from etl.membership
group by source, sourcecontactid, marketcode, productcode
having count(1) > 1


select status, source, marketcode, count(1)
from etl.membership
group by status, source, marketcode
order by 1,2,3



