use DiamondDW

drop table ContactFuzzy

create table ContactFuzzy
(ContactFuzzyID int identity (1,1),
FirstName nvarchar(100),
SecondName nvarchar(100),
EmailAddress nvarchar(100),
StreetAddress nvarchar(100),
City nvarchar(100),
County nvarchar(100),
Postcode nvarchar(100),
GroupID int)

truncate table ContactFuzzy

insert into ContactFuzzy (FirstName, SecondName)
values ('Joe','Perkins'),
('Joe','Perkins'),
('Joey','Perkins'),
('John','Perkins'),
('Bob','Perkins')

create table ContactFuzzyGrouped
(ContactFuzzyID int,
_key_in varchar(100),
_key_out varchar(100),
_Score varchar(100))


select c.ContactFuzzyID, c.FirstName, c.SecondName, cg.*
from ContactFuzzyGrouped cg
inner join ContactFuzzy c
on cg.ContactFuzzyID = c.ContactFuzzyID

