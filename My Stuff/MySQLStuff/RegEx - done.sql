use Diamond -- assume this is our testing database
go
if object_id('dbo.tblRegEx', 'U') is not null
 drop table dbo.tblRegEx

create table dbo.tblRegEx (id int identity, a varchar(300), b  varchar(300) );
go
insert into dbo.tblRegEx (a, b)
values ('hello hello hello world',  'my phone number is 321-111-1111')
, ( 'this this is is really fun','this number (604) 991-9111 is my cell phone')
, ( 'no duplicate here', 'no phone number here either, just my license# 111 111 2222')
, ( 'multiple blank lines
  
 
--this is 6th line', '222 333-4444 is my cell phone');



sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;  

-- here's an example


exec sp_execute_external_script @language=N'R'
, @script = N'
pattern = "\\b\\(?\\d{3}\\)?[-\\s]\\d{3}-\\d{4}\\b"
outData <- subset(inData, grepl(pattern, b, perl = T))'
, @input_data_1 = N'select id, a, b from dbo.tblRegEx'
, @input_data_1_name = N'inData'
, @output_data_1_name=N'outData'
with result sets ( as object dbo.tblRegEx);

-- I want to try it on this set(value|val)?

insert into dbo.tblRegEx(a) values('set'), ('SetValue'),('SetVal'),('SetValues')

exec sp_execute_external_script @language=N'R'
, @script = N'
pattern = "\?"
outData <- subset(inData, grepl(pattern, a, perl = T))'
, @input_data_1 = N'select id, a, b from dbo.tblRegEx'
, @input_data_1_name = N'inData'
, @output_data_1_name=N'outData'
with result sets ( as object dbo.tblRegEx);