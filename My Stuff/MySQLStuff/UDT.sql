
use DiamondDW

CREATE TYPE CreatedDate  
FROM DATETIME NULL

CREATE DEFAULT DefaultDate  
as GETDATE()  

  
EXEC sp_bindefault 'DefaultDate', 'CreatedDate'

create table ContactTest
(Name varchar(100),
CreateDate CreatedDate)

insert into ContactTest (Name) values ('joe')

select * from ContactTest