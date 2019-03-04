
delete Dimcontact

select * from DimProduct
select * from DimContact
delete from DimProduct where productname = 'fences'

insert into audit(TableName,Action, Status, Description)
values ('DimProduct','Load Complete','Error','Duplicate ProductBusinessKey')

truncate table audit

insert into audit(TableName,Action, Status, Description)
values ('DimProduct','Load Complete','Error',?)

select * from audit order by auditdate desc
delete from audit where noofrow = 1

insert into audit(TableName,Action, Status, Description)
values ('DimProduct','Load Complete','Error','?')

delete from DimProduct where ProductName = 'big tractors'

insert into DimProduct (ProductName,Source)
values ('dsafd','viper')

select * from DimContact

update  DimContact set CurrentRecord = 1

insert into audit(TableName,Action, Status,Description,NoOfRow )
values ('DimProduct','Complete','Success','New Records',1)