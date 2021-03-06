USE [Consolidated_Staging]
GO
/****** Object:  StoredProcedure [DB].[up_EmailOwner]    Script Date: 20/12/2018 09:51:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [DB].[up_EmailOwner]
@TableName varchar(200),@EmailAddress varchar(100),@FirstName varchar(100),@LastName varchar(100),@EmailOwner varchar(100)
AS
--Declare @Tablename '#ETL_Contact1'
DECLARE @SQL1 Nvarchar(4000)
BEGIN

Set @SQL1 = 'IF NOT EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''StripEmailName'')
			 ALTER TABLE ' + @TableName + ' ADD StripEmailName NVarchar(255)'
exec sp_executesql @SQL1 

Set @SQL1 = 'IF NOT EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''StripFirstName'')
			 ALTER TABLE ' + @TableName + ' ADD StripFirstName NVarchar(255)'
exec sp_executesql @SQL1 

Set @SQL1 = 'IF NOT EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''StripLastName'')
			ALTER TABLE ' + @TableName + ' ADD StripLastName NVarchar(255)'
exec sp_executesql @SQL1 

Set @SQL1 = 'IF NOT EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''RuleStep'')
			ALTER TABLE ' + @TableName + ' ADD RuleStep int'
exec sp_executesql @SQL1 


Set @SQL1 = 'UPDATE ' + @TableName + ' SET 
					 StripEmailName = etl_staging.[etl].[fnCharacterOnly](LEFT(ISNULL(' + @EmailAddress + ',''''),PATINDEX(''%@%'',ISNULL(' + @EmailAddress + ','''')))) 
					,StripFirstName = etl_staging.[etl].[fnCharacterOnly](ISNULL(OriginalFirstName,''''))
					,StripLastName  = etl_staging.[etl].[fnCharacterOnly](ISNULL(OriginalSurName,''''))
			 WHERE ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 

Set @SQL1 = 
'update ' + @TableName + ' set StripEmailName = ltrim(rtrim(StripEmailName)),
StripFirstName = ltrim(rtrim(StripFirstName)),
StripLastName = ltrim(rtrim(StripLastName))
where ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 

-- -1
--Either Email or Contact name is invalid
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -1, RuleStep = 96
where len(emailaddress) > 0 and PATINDEX(''%@%.%'',isnull(' + @EmailAddress + ','''')) = 0 and ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 


-- -1
--Either Email or Contact name is invalid
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -2, RuleStep = 1
where len(StripFirstName) = 0 and len(StripLastName) = 0 and (PATINDEX(''%@%.%'',isnull(' + @EmailAddress + ','''')) = 0 or len(StripEmailName) = 0) and ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 

Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -2, RuleStep = 1
where len(StripFirstName) = 0 and len(StripLastName) = 0 and (PATINDEX(''%@%.%'',isnull(' + @EmailAddress + ','''')) > 0) and ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 

Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -2, RuleStep = 1
where len(StripFirstName) = 0 and len(StripLastName) > 0 and (PATINDEX(''%@%.%'',isnull(' + @EmailAddress + ','''')) = 0 or len(StripEmailName) = 0) and ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 

Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -2, RuleStep = 1
where len(StripLastName) = 0 and len(StripFirstName) > 0 and (PATINDEX(''%@%.%'',isnull(' + @EmailAddress + ','''')) = 0 or len(StripEmailName) = 0) and ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1 


--Firstname+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 2
where ' + @EmailOwner + ' is null 
and StripFirstName+StripLastName = StripEmailName
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripFirstName) > 2 and len(StripLastName) > 2'
exec sp_executesql @SQL1

--' + @FirstName + '+[.-_]+Surname+[0-9]@Domine.com 
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 3
where StripFirstName+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripFirstName) > 2 and len(StripLastName) > 2'
exec sp_executesql @SQL1


--As per Rohini request place moved 
---- -1 
--Surname+' + @FirstName + '@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 4
where StripLastName+StripFirstName = StripEmailName
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripFirstName) > 2 and len(StripLastName) > 2'
exec sp_executesql @SQL1 



--' + @FirstName + '+[.-_]+Surname+[0-9]@Domine.com
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 1, RuleStep = 5
where left(StripLastName,1)+left(StripLastName,15) = StripEmailName
and left(StripLastName,1) <> left(StripFirstName,1)
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripLastName) > 0 and len(StripFirstName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Surname@Domine.com
--Change the score from 3 to 4 as per rohini test
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 3, RuleStep = 6
where StripFirstName+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripFirstName) = 1 and len(StripLastName) > 1'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Surname@Domine.com
--Change the score from 3 to 4 as per rohini test
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 3, RuleStep = 7
where StripFirstName+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripFirstName) = 2 and len(StripLastName) > 1'
exec sp_executesql @SQL1


--' + @FirstName + '^{1}+Surname@Domine.com
--Change the score from 3 to 4 as per rohini test
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 3, RuleStep = 8
where StripFirstName+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0
and len(StripFirstName) > 1 and len(StripLastName) = 1'
exec sp_executesql @SQL1


--' + @FirstName + '^{1}+Surname+AnyCharacters@Domine.com
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 3, RuleStep = 9
where ' + @EmailAddress + ' like left(StripFirstName,1)+''_''+StripLastName+''%@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 2'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Middlename|' + @FirstName + '@Domine.com		
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 1, RuleStep = 10
where etl_staging.[etl].[fnCharacterOnly](left(' + @FirstName + ',1))+substring(' + @FirstName + ',CHARINDEX('' '',' + @FirstName + ')+1,LEN(' + @FirstName + ')) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{2-15}+Surname@Domine.com
--Newly added as per Rohini test Case changed 5 to 3
Set @SQL1 = 
'
update ' + @TableName + '   set ' + @EmailOwner + ' = 3, RuleStep = 11
where left(StripFirstName,2)+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) = 2 and len(StripLastName) > 2'
exec sp_executesql @SQL1


--' + @FirstName + '^{2-15}+Surname@Domine.com
--Newly added as per Rohini test Case changed 5 to 3
Set @SQL1 = 
'
update ' + @TableName + '   set ' + @EmailOwner + ' = 3, RuleStep = 80
where StripFirstName+Left(StripLastName,2) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripLastName) = 2 and len(StripFirstName) > 2'
exec sp_executesql @SQL1


--' + @FirstName + '^{2-15}+Surname@Domine.com
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + '   set ' + @EmailOwner + ' = 4, RuleStep = 88
where left(StripFirstName,@a)+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 2 and len(StripLastName) > 2
set @a =@a+1
end '
exec sp_executesql @SQL1


--' + @FirstName + '^{2-15}+OneCharactor+Surname+OneCharactor@Domine.com 
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 12
where left(StripFirstName,@a)+''_''+StripLastName+''_@%'' = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 2 and len(StripLastName) > 0
set @a =@a+1
end'
exec sp_executesql @SQL1 


--' + @FirstName + '^{2-15}+OneCharactor+SurName@Domine.com 
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 13
where left(StripFirstName,@a)+''_''+StripLastName+''@%'' = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0
set @a =@a+1
end'
exec sp_executesql @SQL1 

--' + @FirstName + '^{2-15}@Domine.com
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 14
where left(StripFirstName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 1 and len(StripLastName) > 1
set @a =@a+1
end'
exec sp_executesql @SQL1  

--' + @FirstName + '+Surname^{1}@Domine.com
--Change the score from 3 to 4 as per rohini test again changed from 4 to 3
Set @SQL1 = 
'update ' + @TableName + '  set ' + @EmailOwner + ' = 3, RuleStep = 15
where StripFirstName+left(StripLastName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1


--' + @FirstName + '+Surname^{2-15}@Domine.com	
--Change the score from 3 to 4 as per rohini test
Set @SQL1 = 
'Declare @a int
set @a=2
while @a <=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 16
where StripFirstName+left(StripLastName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 2 and len(StripLastName) > 0
set @a=@a+1
end'
exec sp_executesql @SQL1  

--Surname+' + @FirstName + '^{1}@Domine.com
--Change the score from 3 to 4 as per rohini test again changed from 4 to 3
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 17
where StripLastName+left(StripFirstName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
--and len(isnull(' + @FirstName + '+' + @LastName + ','''')) > 0 and len(StripLastName) > 0
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Surname^{1}+[0-9]@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 18
where left(StripFirstName,1)+left(StripLastName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--Score 1
--' + @FirstName + '@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 19
where StripFirstName = StripEmailName
and ' + @EmailOwner + ' is null and len(StripEmailName) > 0'
exec sp_executesql @SQL1 

--Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 20
where StripLastName = StripEmailName
and ' + @EmailOwner + ' is null and len(StripEmailName) > 0'
exec sp_executesql @SQL1 


--Surname+' + @FirstName + '^{2-15}@Domine.com
--Changed the score -1 to 4 as per Rohini's testing
Set @SQL1 = 
'Declare @a int
set @a=2
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 21
where StripLastName+left(StripFirstName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 1 and len(StripLastName) > 1
set @a=@a+1
end'
exec sp_executesql @SQL1  

--Surname+' + @FirstName + '^{2-15}@Domine.com
--Newly added case as per Rohini's testing
Set @SQL1 = 
'Declare @a int
set @a=2
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 22
where left(StripLastName,@a)+left(StripFirstName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0
set @a=@a+1
end'
exec sp_executesql @SQL1  


--Surname^{2-15}+' + @FirstName + '@Domine.com
Set @SQL1 = 
'Declare @a int
set @a=2
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 23
where left(StripLastName,@a)+StripFirstName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0
set @a=@a+1
end'
exec sp_executesql @SQL1 

--Surname^{2-15}+' + @FirstName + '^{2-15}@Domine.com
Set @SQL1 = 
'Declare @a int
set @a=2
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 24
where left(StripLastName,@a)+left(StripFirstName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0
set @a=@a+1
end'
exec sp_executesql @SQL1  



--' + @FirstName + '+OneCharacter+[.-_]+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 25
where ' + @EmailAddress + ' like StripFirstName+''_[.-_]''+StripLastName+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '+OneCharacter+Surname+OneCharacter@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 26
where ' + @EmailOwner + ' is null 
and ' + @EmailAddress + ' like StripFirstName+''_''+StripLastName+''_@%''
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '.[A-Za-z].Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 27
where ' + @EmailOwner + ' is null 
and len(replace(replace(StripEmailName,StripFirstName,''''),StripLastName,''''))=1
and ' + @EmailAddress + ' like ''%[A-Za-z]%.%[A-Za-z]%.%@%''
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '[A-Za-z]-Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 28
where ' + @EmailOwner + ' is null 
and len(replace(replace(StripEmailName,StripFirstName,''''),StripLastName,''''))=1
and ' + @EmailAddress + ' like ''%[A-Za-z]%-%[A-Za-z]%-%@%''
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '[A-Za-z]_Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 29
where ' + @EmailOwner + ' is null
and len(replace(replace(StripEmailName,StripFirstName,''''),StripLastName,''''))=1
and ' + @EmailAddress + ' like ''%[A-Za-z]%[_]%[A-Za-z]%[_]%@%''
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '+Surname+OneCharacter@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 30
where ' + @EmailOwner + ' is null 
and len(replace(replace(StripEmailName,StripFirstName,''''),StripLastName,''''))=1
and ' + @EmailAddress + ' like StripFirstName+''''+StripLastName+''_@%''
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '+OneCharacter+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 31
where ' + @EmailOwner + ' is null
and len(replace(replace(StripEmailName,StripFirstName,''''),StripLastName,''''))=1
and ' + @EmailAddress + ' like StripFirstName+''_''+StripLastName+''@%''
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '+OneCharacter+Surname+OneCharacter@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 32
where ' + @EmailOwner + ' is null 
and len(replace(replace(StripEmailName,StripFirstName,''''),StripLastName,''''))=1
and ' + @EmailAddress + ' like StripFirstName+''_''+StripLastName+''_@%''
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--' + @FirstName + '+OneCharacter+Surname+AnyCharacter@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 33
where ' + @EmailAddress + ' like StripFirstName+''_''+StripLastName+''%@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 2 and len(StripLastName) > 2'
exec sp_executesql @SQL1 

--Firstname^{1}+Surname{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 34
where left(StripFirstName,1)+left(StripLastName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--Surname^{1}+Firstname^{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 35
where left(StripLastName,1)+left(StripFirstName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1  

--Surname^{1}+Firstname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 36
where left(StripLastName,1)+StripFirstName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--Surname^{1}+' + @FirstName + '+AnyCharacters@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 37
where ' + @EmailAddress + ' like left(StripLastName,1)+''_''+StripFirstName+''%@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

---LOOP

--' + @FirstName + '^{2-15}+Surname^{2-15}@Domine.com
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 38
where 
left(StripFirstName,@a)+left(StripLastName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 1 and len(StripLastName) > 1
set @a =@a+1
end'
exec sp_executesql @SQL1 


--' + @FirstName + '+OneCharacter+Surname{2-15}@Domine.com
--Changed from 4 to 3
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 39
where 
left(StripFirstName,1)+left(StripLastName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0
set @a =@a+1
end'
exec sp_executesql @SQL1 


--Surname^{1}+' + @FirstName + '{2-15}@Domine.com
--changed from 3 to 4
Set @SQL1 = 
'Declare @a int
set @a =2 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 40
where left(StripLastName,1)+left(StripFirstName,@a) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0
set @a =@a+1
end'
exec sp_executesql @SQL1  


--' + @FirstName + '^{1}+Surname+UK@Domine.com
--Changed 4 to 3
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 41
where left(StripFirstName,1)+StripLastName+''uk'' = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--' + @FirstName + '+Surname+UK@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 42
where StripFirstName+StripLastName+''uk'' = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--' + @FirstName + '+UK@Domine.com	
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 43
where StripFirstName+''uk'' = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 
	
--Surname+UK@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -1, RuleStep = 44
where StripLastName+''uk'' = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1  

--' + @FirstName + '+Surname+Surname^{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 45
where StripFirstName+StripLastName+left(StripLastName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 
		
--Surname-1@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -1, RuleStep = 46
where substring(StripLastName,1,LEN(StripLastName)-1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripLastName) > 0' 
exec sp_executesql @SQL1 
		
--' + @FirstName + '+Surname-1@Domine.com	
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 47
where substring((StripFirstName+StripLastName),1,LEN(StripFirstName+StripLastName)-1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--Surname+(' + @FirstName + '-1)@Domine.com  
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -1, RuleStep = 48
where substring((StripLastName+StripFirstName),1,LEN(StripLastName+StripFirstName)-1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '^{1}+Middlename|' + @FirstName + '+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 49
where left(StripFirstName,1)+substring(' + @FirstName + ',CHARINDEX('' '',' + @FirstName + ')+1,LEN(' + @FirstName + '))+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--' + @FirstName + '^{1}+Middlename^{1}|' + @FirstName + '^{1}+Surname@Domine.com  
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 50
where left(StripFirstName,1)+substring(' + @FirstName + ',CHARINDEX('' '',' + @FirstName + ')+1,1)+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

 
--' + @FirstName + '^{1}+Middlename^{1}|' + @FirstName + '^{1}+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 51
where left(StripFirstName,1)+substring(' + @FirstName + ',CHARINDEX(''-'',' + @FirstName + ')+1,1)+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Middlename^{1}|' + @FirstName + '^{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 52
where left(StripFirstName,1)+substring(' + @FirstName + ',CHARINDEX('' '',' + @FirstName + ')+1,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '{1}+Middlename|' + @FirstName + '{1}+Surname^{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2 , RuleStep = 53
where left(StripFirstName,1)+SUBSTRING(' + @FirstName + ',PATINDEX(''% %'',' + @FirstName + ')+1,1)+(left(StripLastName,1)) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName+StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Surname^{1}+Surname${1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 54
where left(StripFirstName,1)+(left(StripLastName,1))+(right(StripLastName,1)) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--Surname^{1}+' + @FirstName + '^{1}+Surname${1}@Domine.com
--changed 4 to 2
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 55
where left(StripLastName,1)+left(StripFirstName,1)+right(StripLastName,1) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+Surname^{1}+Middlename^{1}|' + @FirstName + '^{1}@Domine.com
--Changed 4 to 2
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 56
where left(StripFirstName,1)+(left(StripLastName,1)+left(StripFirstName,1)) = StripEmailName
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--Changed the score as per Rohini test from 5 to 3, 3 to 5
--Soundex(' + @FirstName + '+Surname)@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 57
where SOUNDEX(StripFirstName) = SOUNDEX(left(StripEmailName,LEN(StripFirstName)))
and SOUNDEX(StripLastName) = SOUNDEX(ltrim(rtrim(substring(StripEmailName,LEN(StripFirstName)+1,50))))
and ' + @EmailOwner + ' is  null  
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1


--^' + @FirstName + '{1}____+Surname+[%_%]@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 58
where ' + @EmailAddress + ' like StripFirstName+''%_%''+StripLastName+''%_%''
and ' + @EmailOwner + ' is null 
and LEN(StripFirstName) = 1
and len(StripLastName) > 2'
exec sp_executesql @SQL1

--' + @FirstName + '+[%_%]+^Surname____@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 59
where ' + @EmailAddress + ' like StripFirstName+''%_%''+StripLastName+''%_%''
and ' + @EmailOwner + ' is null 
and LEN(StripLastName) = 1 and len(StripFirstName) > 2'
exec sp_executesql @SQL1


--' + @FirstName + '+[%_%]+Surname+[%_%]@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 60
where ' + @EmailAddress + ' like StripFirstName+''%_%''+StripLastName+''%_%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 2 and len(StripLastName) > 0'
exec sp_executesql @SQL1


--Changed the score as per Rohini test from 5 to 3, 3 to 4
--{A-Za-z}+AnyCharacter+' + @FirstName + '|Surname+{A-Za-z}@Domine.com
Set @SQL1 = 
'Declare @a int
set @a = 3
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 61
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+left(StripFirstName,@a)+''%'',left(left(StripEmailName,len(StripFirstName)),@a)) > 0
and PATINDEX(''%''+left(StripLastName,@a)+''%'',left(left(StripEmailName,len(StripLastName)),@a)) > 0
and len(StripFirstName) > 1 and len(StripLastName) > 1
set @a =@a+1
end'
exec sp_executesql @SQL1 


------Changed the score as per Rohini test from 5 to 3, 3 to 4
------{A-Za-z}+AnyCharacter+' + @FirstName + '|Surname+{A-Za-z}@Domine.com
----Set @SQL1 = 
----'Declare @a int
----set @a = 4
----while @a<=15
----begin
----update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 93
----where ' + @EmailOwner + ' is  null  
----and PATINDEX(''%''+left(StripFirstName,@a)+''%'',left(StripEmailName,len(StripFirstName))) > 0
----and PATINDEX(''%''+left(StripLastName,@a)+''%'',right(StripEmailName,len(StripLastName))) > 0
----and len(StripFirstName) > 1 and len(StripLastName) > 1
----set @a =@a+1
----end'
----exec sp_executesql @SQL1 

--{left(@FirstName,5)+Surname is null}@Domine.com
Set @SQL1 = 
'Declare @a int
set @a =5 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 62
where ' + @EmailOwner + ' is  null  
and left(StripFirstName,@a)=left(StripEmailName,@a)
and len(StripLastName) = 0 and len(StripFirstName) > 0
set @a =@a+1
end'
exec sp_executesql @SQL1 


--{left(@Surname,5)+FirstName is null}@Domine.com
Set @SQL1 = 
'Declare @a int
set @a =5 
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 63
where ' + @EmailOwner + ' is  null  
and left(StripLastName,@a)=left(StripEmailName,@a)
and len(StripFirstName) = 0 and len(StripLastName) > 0
set @a =@a+1
end'
exec sp_executesql @SQL1 


--' + @FirstName + '^{1}+AnyCharacters^{2}+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 64
where ' + @EmailAddress + ' like left(StripFirstName,1)+''__''+StripLastName+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1  


--Surname^{1}+AnyCharacters^{2}+' + @FirstName + '@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 65
where ' + @EmailAddress + ' like left(StripLastName,1)+''__''+StripFirstName+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 


--' + @FirstName + '^{1}+AnyCharacter^{1}+Surname^{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 66
where ' + @EmailAddress + ' like left(StripFirstName,1)+''_''+left(StripLastName,1)+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1


--Surname^{1}+AnyCharacter^{1}+' + @FirstName + '^{1}@Domine.com 
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 67
where ' + @EmailAddress + ' like left(StripLastName,1)+''_''+left(StripFirstName,1)+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--' + @FirstName + '^{1}+AnyCharacter^{1}+Surname^{1}+AnyCharacter^{1}@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 2, RuleStep = 68
where ' + @EmailAddress + ' like left(StripFirstName,1)+''_''+left(StripLastName,1)+''_''+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '^{1}+AnyCharacters^{1}+Surname@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 69
where ' + @EmailAddress + ' like left(StripFirstName,1)+''_''+StripLastName+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1 

--Surname^{1}+AnyCharacters^{1}+' + @FirstName + '@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 70
where ' + @EmailAddress + ' like left(StripLastName,1)+''_''+StripFirstName+''@%''
and ' + @EmailOwner + ' is null 
and len(StripFirstName) > 0 and len(StripLastName) > 0'
exec sp_executesql @SQL1  

--SurName+SurName@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 71
where StripLastName+StripLastName = StripEmailName
and ' + @EmailOwner + ' is null and len(StripEmailName) > 0'
exec sp_executesql @SQL1

--' + @FirstName + '+' + @FirstName + '@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 72
where StripFirstName+StripFirstName = StripEmailName  and len(StripEmailName) > 0
and ' + @EmailOwner + ' is null'
exec sp_executesql @SQL1

--' + @FirstName + '+SurnameBlank@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 73
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+StripFirstName+''%'',StripEmailName) > 0 and len(StripFirstName) > 2
and len(StripLastName) = 0'
exec sp_executesql @SQL1

--Surname+FirstnameBlank@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 74
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+StripLastName+''%'',StripEmailName) > 0
and len(StripFirstName) = 0'
exec sp_executesql @SQL1 

--' + @FirstName + '|Surname+AnyCharacters@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 75
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+StripFirstName+''%'',StripEmailName) > 0
and (
	(ETL_Staging.ETL.edit_distance(replace(StripEmailName,StripFirstName,''''),StripLastName) = 2 and len(StripLastName) > 2)
	or		
	(ETL_Staging.ETL.edit_distance(replace(StripEmailName,StripLastName,''''),StripFirstName) = 2 and len(StripFirstName) > 2)
	)'
exec sp_executesql @SQL1 

--FirstNameFirstLetter+LastName@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 4, RuleStep = 95
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+StripLastName+''%'',StripEmailName) > 0
and left(StripFirstName,3) = LEFT(StripEmailName,3) and len(StripLastName) > 2'
exec sp_executesql @SQL1 


--FirstNameFirstLetter+LastName@Domine.com
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 76
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+StripLastName+''%'',StripEmailName) > 0
and left(StripFirstName,1) = LEFT(StripEmailName,1) and len(StripLastName) > 2'
exec sp_executesql @SQL1 


Set @SQL1 = 
'Declare @a int
set @a =1
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 77
where ' + @EmailOwner + ' is  null  
and left(StripFirstName,@a)=left(StripEmailName,@a)
and len(StripFirstName) = @a and len(StripLastName) = 0
set @a =@a+1
end'
exec sp_executesql @SQL1 

Set @SQL1 = 
'Declare @a int
set @a =1
while @a<=15
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 3, RuleStep = 78
where ' + @EmailOwner + ' is  null  
and left(StripLastName,@a)=left(StripEmailName,@a)
and len(StripLastName) = @a and len(StripFirstName) = 0
set @a =@a+1
end'
exec sp_executesql @SQL1 

--New rule 
Set @SQL1 = 
'Declare @a int
set @a =15
while @a<=15 and @a > 0
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 89
where ' + @EmailOwner + ' is  null  
and left(StripFirstName,@a)=left(StripEmailName,@a)
and len(StripFirstName) > 1 and len(StripLastName) = 1
set @a =@a-1
end'
exec sp_executesql @SQL1 

--New rule 
Set @SQL1 = 
'Declare @a int
set @a =15
while @a<=15 and @a > 0
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 90
where ' + @EmailOwner + ' is  null  
and left(StripFirstName,@a)=left(StripEmailName,@a)
and len(StripFirstName) > 1 and len(StripLastName) > 1
set @a =@a-1
end'
exec sp_executesql @SQL1 

--New rule 
Set @SQL1 = 
'Declare @a int
set @a =18
while @a<=18 and @a > 12
begin
update ' + @TableName + ' set ' + @EmailOwner + ' = 5, RuleStep = 92
where ' + @EmailOwner + ' is  null  
and right(StripFirstName+StripLastName,@a)=right(StripEmailName,@a)
and len(StripFirstName) > 1 and len(StripLastName) > 1
set @a =@a-1
end'
exec sp_executesql @SQL1 

--
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = 1, RuleStep = 94
where ' + @EmailOwner + ' is  null  
and PATINDEX(''%''+StripLastName+''%'',StripEmailName) > 0
and left(StripFirstName,len(StripLastName)) <> left(StripEmailName,len(StripFirstName))
and  len(StripFirstName) > 1 and len(StripLastName) > 2'
exec sp_executesql @SQL1 


---- -1
----Either Email or Contact name is invalid
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -1, RuleStep = 79
where len(StripEmailName) > 0 and  (len(StripFirstName) > 0 or len(StripLastName) > 0) and EmailOwner is null'
exec sp_executesql @SQL1 

----Either Email or Contact name is invalid
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = -1, RuleStep = 91
where len(Emailaddress) > 0 and  len(StripFirstName) > 0 and len(StripLastName) > 0 and EmailOwner is null'
exec sp_executesql @SQL1 


---- -1
----Either Email or Contact name is invalid
Set @SQL1 = 
'update ' + @TableName + ' set ' + @EmailOwner + ' = null, RuleStep = 81
where EmailOwner = -2'
exec sp_executesql @SQL1 


Set @SQL1 = 'IF EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''StripEmailName'')
			 ALTER TABLE ' + @TableName + ' DROP COLUMN StripEmailName'
exec sp_executesql @SQL1 

Set @SQL1 = 'IF EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''StripFirstName'')
			 ALTER TABLE ' + @TableName + ' DROP COLUMN StripFirstName'
exec sp_executesql @SQL1 

Set @SQL1 = 'IF EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''StripLastName'')
			ALTER TABLE ' + @TableName + ' DROP COLUMN StripLastName'
exec sp_executesql @SQL1 

Set @SQL1 = 'IF EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = RIGHT('''+@TableName+''',PATINDEX(''%.%'',REVERSE('''+@TableName+'''))-1) and column_name = ''RuleStep'')
			ALTER TABLE ' + @TableName + ' DROP COLUMN RuleStep'
exec sp_executesql @SQL1 


END

