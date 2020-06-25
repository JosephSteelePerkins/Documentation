use DiamondDW

create table SSISScriptTestSource 
(ContactID int identity(1,1),
FirstName varchar(10),
LastName varchar(10))

drop table SSISScriptTestDesination

create table SSISScriptTestDesination
(ContactID int ,
FirstName varchar(10),
LastName varchar(10))

insert into SSISScriptTestSource 
values ('John','Smith'),
('Mark','Twain'),
('Mary','Peters')

select * from SSISScriptTestDesination

select * from Audit

insert into Audit(Action,Description)
values ('Fail','File is empty')

truncate table Audit

truncate table dbo.DimContactBig
select count(1) from dbo.DimContact -- 21,117,288
select count(1) from dbo.DimContact2