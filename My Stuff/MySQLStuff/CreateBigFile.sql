
use DiamondDW

-- create big version of DimContact 

select * from dbo.DimContactBig

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DimContactBig')
drop table dbo.DimContactBig

CREATE TABLE dbo.DimContactBig
(ContactKey int identity(1,1) primary key,
FirstName nvarchar(100),
SecondName nvarchar(100),
ContactBusinessKey varchar(1000),
Source varchar(100),
EmailAddress nvarchar(100),
TelephoneNumber varchar(100),
AddressLine1 nvarchar(100),
AddressLine2 nvarchar(100),
Town nvarchar(100),
Postcode nvarchar(100),
County nvarchar(100),
Country varchar(100),
SourceStatus varchar(100),
CreateDate datetime default getdate(),
InferredMember bit default 0,
CurrentRecord bit default 1,
ToDate datetime,
TaskID varchar(50),
ExecutionStartTime datetime)

drop SEQUENCE ContactBusinessKey

CREATE SEQUENCE  ContactBusinessKey
    START WITH 2  
    INCREMENT BY 1 ;

-- populate DimContact with a seed records

truncate table DiamondDW.dbo.DimContactBig
select * from DiamondDW.dbo.DimContactBig
insert into DiamondDW.dbo.DimContactBig (FirstName, SecondName,ContactBusinessKey, Source, EmailAddress, TelephoneNumber, AddressLine1, AddressLine2,
Town, Postcode, County, Country,SourceStatus)
values
('FirstName', 'SecondName',NEXT VALUE FOR ContactBusinessKey, 'Source', 'EmailAddress', 'TelephoneNumber', 'AddressLine1'
, 'AddressLine2','Town', 'Postcode', 'County', 'Country','SourceStatus'),
('FirstName1', 'SecondName1',NEXT VALUE FOR ContactBusinessKey, 'Sourc', 'EmailAddress1', 'TelephoneNumber1', 'AddressLine1'
, 'AddressLine1','Town1', 'Postcode1', 'County1', 'Country1','SourceStatus1'),
('FirstName2', 'SecondName2',NEXT VALUE FOR ContactBusinessKey, 'Source', 'EmailAddress2', 'TelephoneNumber2', 'AddressLine2'
, 'AddressLine2','Town2', 'Postcode2', 'County2', 'Country2','SourceStatus2')


-- lets make a managed size first to test the export and import process



insert into DiamondDW.dbo.DimContactBig (FirstName, SecondName,ContactBusinessKey, Source, EmailAddress, TelephoneNumber, AddressLine1, AddressLine2,
Town, Postcode, County, Country,SourceStatus)
select d.FirstName, d.SecondName,NEXT VALUE FOR ContactBusinessKey, d.Source, d.EmailAddress, d.TelephoneNumber
	,d.AddressLine1, d.AddressLine2,
d.Town, d.Postcode,d. County, d.Country, d.SourceStatus
from DiamondDW.dbo.DimContactBig d
cross join DiamondDW.dbo.DimContactBig dc
cross join DiamondDW.dbo.DimContactBig dc1
cross join DiamondDW.dbo.DimContactBig dc2
cross join DiamondDW.dbo.DimContactBig dc3
cross join DiamondDW.dbo.DimContactBig dc4
cross join DiamondDW.dbo.DimContactBig dc5
cross join DiamondDW.dbo.DimContactBig dc6
cross join DiamondDW.dbo.DimContactBig dc7
cross join DiamondDW.dbo.DimContactBig dc8
cross join DiamondDW.dbo.DimContactBig dc9
cross join DiamondDW.dbo.DimContactBig dc10
cross join DiamondDW.dbo.DimContactBig dc11
cross join DiamondDW.dbo.DimContactBig dc12
cross join DiamondDW.dbo.DimContactBig dc13


truncate table DiamondDW.dbo.DimContactBig -- 14,348,907
select  count(1) from DiamondDW.dbo.DimContact -- 14,348,907

delete Diamonddw.dbo.DimContact

select description
	,AuditStartDate
	,AuditEndDate
	,NoOfRow
	,DATEDIFF(second,AuditStartDate,AuditEndDate)
from DiamondDW.dbo.Audit

select count(1) from DiamondDW.dbo.DimContact where ContactKey % 10 = 1



select * from DiamondDW.dbo.DimContact order by createdate desc