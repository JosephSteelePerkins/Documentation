
drop table #temp

create table #temp (F1 int) 
insert into #temp values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)

use DiamondDW

drop SEQUENCE SourceContactID_Seq

CREATE SEQUENCE  SourceContactID_Seq
 AS INTEGER
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 NO CYCLE; 

 -- create contact rows

  insert into etl.Contact (MarketCode, Source, SourceContactID, Email, FirstName, LastName,Postcode, SourceCreateDate, SourceLastUpdateDate)

 SELECT 'AGR','ELO',
 cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10))
 , cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10)) + '@joe.com',
 'Joe' FirstName,
 'Perks' Surname,
 'se23' PostCode,
 '01-jan-2020' SourceCreateDate,
 '20-jun-2020' LastUpdateDate
from [DESKTOP-CGRB0T0].[AdventureWorks2017].[Sales].[SalesOrderDetail]
cross join #temp 


  insert into etl.Contact (MarketCode, Source, SourceContactID, Email, FirstName, LastName,Postcode, SourceCreateDate, SourceLastUpdateDate)

 SELECT 'AGR','AMP',
 cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10))
 , cast(NEXT VALUE FOR SourceContactID_Seq as varchar(10)) + '@joe.com',
 'Joe' FirstName,
 'afdsfdsa' Surname,
 'se23' PostCode,
 '01-jan-2020' SourceCreateDate,
 '20-jun-2020' LastUpdateDate
from [DESKTOP-CGRB0T0].[AdventureWorks2017].[Sales].[SalesOrderDetail]
cross join #temp 

-- check there are no duplicates

select SourceContactID, source,MarketCode, count(1)
from etl.Contact
group by SourceContactID, source,MarketCode
having count(1) > 1

update etl.Contact
set source = 'elo'
where source = 'elq'

select * from ctl.Source

select source, count(1)
from etl.contact
group by Source

select source, count(1)
from etl.Membership
group by Source


select * from etl.Membership 

truncate table etl.Membership 

insert into etl.Membership (source, MarketCode, SourceContactID, ProductCode, Status, SourceCreateDate, SourceLastUpdateDate)
select source
	, MarketCode
	, SourceContactID
	, 'fwcor'
	, 'optedout'
	, '01-jan-2020' SourceCreateDate,
	'20-jun-2020' LastUpdateDate
from etl.Contact
where source = 'elo'
union
select source
	, MarketCode
	, SourceContactID
	, 'fwcof'
	, 'active'
	, '01-jan-2020' SourceCreateDate,
	'20-jun-2020' LastUpdateDate
from etl.Contact
where source = 'elo'


-- change the path of the source

select * from ctl.Source

update ctl.Source
set FilePath = 'C:\DiamondSourceFiles\AMPS'
where code ='amp'

update ctl.Source
set FilePath = 'C:\DiamondSourceFiles\Eloqua'
where code ='elo'


select *
from ctl.SourceLog
order by createdate desc

select 

-- see how long entire package took to run

declare @ExecutionID uniqueidentifier

select @ExecutionID = executionid 
from
(select executionid
, ROW_NUMBER() over(order by endtime desc) rowno
from [DiamondDW].[dbo].[sysssislog]) x
where rowno = 1

select @ExecutionID

-- get total time package took

select event, starttime, datediff(SECOND, lag(starttime,1) over(order by starttime),starttime)
from [DiamondDW].[dbo].[sysssislog]
where executionid = @ExecutionID
and event in ('PackageStart', 'PackageEnd')

select event, source, starttime, datediff(SECOND, lag(starttime,1) over(order by starttime),starttime)
from [DiamondDW].[dbo].[sysssislog]
where executionid = '4A948819-795D-4EE3-B02F-3C6F53885E93'
and event in ('OnPostExecute','PackageStart','OnPreExecute')

