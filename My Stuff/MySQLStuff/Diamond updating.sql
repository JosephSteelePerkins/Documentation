use DiamondDW
go
create schema etl

drop table etl.Contact 

create table etl.Contact (Source varchar(3),
MarketCode varchar(3),
SourceContactID varchar(10),
Email varchar(100),
FirstName varchar(50),
LastName varchar(50),
SourceCreateDate datetime,
SourceLastUpdateDate datetime,
row_id int identity (1,1))

go

create schema dw

drop table dw.Contact

create table dw.Contact (Source varchar(3),
MarketCode varchar(3),
SourceContactID varchar(10),
Email varchar(100),
FirstName varchar(50),
LastName varchar(50),
SourceCreateDate datetime,
SourceLastUpdateDate datetime,
CreateDate datetime default getdate(),
IsCurrent bit,
row_id int identity (1,1))

-- populate etl_staging with a load of data

drop table #temp

create table #temp (F1 int) 
insert into #temp values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)


drop SEQUENCE SourceContactID

CREATE SEQUENCE  SourceContactID_Seq
 AS INTEGER
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 NO CYCLE; 


 insert into etl.Contact (MarketCode, Source, SourceContactID, Email, FirstName, LastName, SourceCreateDate, SourceLastUpdateDate)

 SELECT 'AGR','ELQ',
 cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10))
 , cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10)) + '@joe.com',
 'Joe' FirstName,
 'Perks' Surname,
 '01-jan-2020' SourceCreateDate,
 '20-jun-2020' LastUpdateDate
from [AdventureWorks2017].[Sales].[SalesOrderDetail]
cross join #temp -- 30 seconds, 3396876 rows

-- get current records if match with etl

drop table #dwcontact

select c.*
into #dwcontact
from dw.Contact c
inner join etl.Contact ec
on c.Source = ec.Source
and c.SourceContactID = ec.SourceContactID
and c.MarketCode = ec.MarketCode
where IsCurrent = 1

-- compare what is coming into ETL with DW. If it has changed, put into temp table

drop table #etlcontact

select c.Source, c.SourceContactID, c.MarketCode, c.Email, c.FirstName, c.LastName, c.SourceCreateDate,
c.SourceLastUpdateDate
into #etlcontact
from etl.Contact c
left join #dwcontact ec
on c.Source = ec.Source
and c.SourceContactID = ec.SourceContactID
and c.MarketCode = ec.MarketCode
where isnull(c.email,'') <> isnull(ec.email,'') or
isnull(c.FirstName,'') <> isnull(ec.FirstName,'') or
isnull(c.LastName,'') <> isnull(ec.LastName,'') or
isnull(c.SourceCreateDate,'') <> isnull(ec.SourceCreateDate,'') or
isnull(c.SourceLastUpdateDate,'') <> isnull(ec.SourceLastUpdateDate,'') 


-- prepare for insert. first, remove all the IsCurrent flags

update dw.Contact
set IsCurrent = null
from #etlcontact ec
inner join dw.Contact c
on c.Source = ec.Source
and c.SourceContactID = ec.SourceContactID
and c.MarketCode = ec.MarketCode

-- insert new rows

insert into dw.Contact(Source, MarketCode, SourceContactID,Email,
FirstName, LastName, SourceCreateDate, SourceLastUpdateDate, IsCurrent)
select Source, MarketCode, SourceContactID,Email,
FirstName, LastName, SourceCreateDate, SourceLastUpdateDate, 1
from #etlcontact

select * from dw.Contact order by source, MarketCode, SourceContactID, createdate


-- change the emails to force a change

update etl.Contact
set email = 'c' + Email,
SourceLastUpdateDate = '21-jun-2020'
from etl.Contact

-- then repeat the above