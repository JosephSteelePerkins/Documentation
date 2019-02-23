-- by default, SQLCMD mode is turned off for a new query
-- turn on at the query window
-- there is no way of turning it on within a script. But the below will tell you whether it is on or not

:setvar DatabaseName "MyDatabase"
GO

IF ('$(DatabaseName)' = '$' + '(DatabaseName)')
    RAISERROR ('This script must be run in SQLCMD mode.', 20, 1) WITH LOG
GO

-- operating system commands are preseded with !!. This is equivalent to running the command in the command window. eg...
 
!!DIR  

-- is equivalent to running this

--C:\Windows\System32>DIR

-- the below example creates a txt file and puts the server version and name into it

:out C:\Samples\testoutput.txt
SELECT @@VERSION As 'Server Version'
SELECT @@SERVERNAME AS 'Server Name'

-- this also includes the output of the DIR command file and puts the server version and name into it
:out C:\Samples\testoutput.txt
SELECT @@VERSION As 'Server Version'
!!DIR  
SELECT @@SERVERNAME AS 'Server Name'

-- what isn't clear from the above is how you would stop any proceeding statements from outputting to the file

-- lets see how the adventure works script used it

-- first it used it to set a variable

 :setvar SqlSamplesSourceDataPath "C:\Samples\AdventureWorksDW\"

-- how is this different from the below? (except you don't have to declare the variable first)

declare @SqlSamplesSourceDataPath varchar(100)
set @SqlSamplesSourceDataPath = 'adsf'

-- probably so it can be used in the bulk insert statements

BULK INSERT [Production].[ProductModelIllustration] FROM '$(SqlSamplesSourceDataPath)ProductModelIllustration.csv'


-- and it isn't used again. I'm going to leave SQLCMD there. More of a DBA thing probably