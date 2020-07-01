USE [master]

ALTER DATABASE [Diamond]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;


RESTORE DATABASE [Diamond] FROM  DISK = N'C:\Users\Public\Public Backups\DiamondIntegrationTesting.bak' 
WITH  FILE = 1,  MOVE N'Diamond' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Diamond.mdf',  
MOVE N'Diamond_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Diamond_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

ALTER DATABASE [Diamond]
SET multi_user
WITH ROLLBACK IMMEDIATE;




