 
-- create a knowlege base on Uk towns and counties
 
 use DQS_STAGING_DATA

create table UKTownCounty (town varchar(100), county varchar(100))

truncate table UKTownCounty

insert into UKTownCounty (town, county)
values ('Plymouth','Devon'),
('Exeter','Devon'),
('Newton Abbot','Devon'),
('Truro','Cornwall'),
('Bodmin','Cornwall'),
('Taunton','Somerset'),
('Bournemouth','Dorset'),
('Yeovil','Somerset'),
('Swindon','Wiltshire'),
('Reading','Berkshire'),
('1111','Berkshire')

create table UKTownCountyToClean (ContactID int identity(1,1), town varchar(100), county varchar(100))

drop table UKTownCountyToCleanCleanecd

create table UKTownCountyToCleanCleaned (ContactID int , town varchar(100), county varchar(100))

truncate table UKTownCountyToClean

insert into UKTownCountyToClean (town, county)
values ('Plymouth','Devon'),
('Exeter','Devon'),
('Newton Abbot','Devon'),
('Newton','Berks'),
('df','Wilts'),
(null,'Cornwall'),
('Wadebridge','Cornwall')

select * from UKTownCountyToCleanCleaned 