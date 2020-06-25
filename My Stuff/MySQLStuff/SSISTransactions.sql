create table SSISScriptTestTransaction 
(ContactID int identity(1,1),
FirstName varchar(10),
LastName varchar(10))

create table SSISScriptTestTransactionDestination1
(ContactID int,
FirstName varchar(10),
LastName varchar(10))

drop table SSISScriptTestTransactionDestination2

create table SSISScriptTestTransactionDestination2
(ContactID int,
FirstName varchar(10),
LastName int)

insert into SSISScriptTestTransaction 
values ('John','Smith'),
('Mark','Twain'),
('Mary','Peters')

truncate table SSISScriptTestSource
select * from SSISScriptTestTransaction 
select * from SSISScriptTestTransactionDestination1 
select * from SSISScriptTestTransactionDestination2

truncate table SSISScriptTestTransactionDestination1
truncate table SSISScriptTestTransactionDestination2

begin tran

insert into SSISScriptTestTransactionDestination1  
select * from SSISScriptTestTransaction 

insert into SSISScriptTestTransactionDestination2 
select * from SSISScriptTestTransactionDestination1 

commit tran
