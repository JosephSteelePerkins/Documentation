
USE [master]
GO
ALTER DATABASE [DiamondDW] ADD FILEGROUP [PrimaryMOD] CONTAINS MEMORY_OPTIMIZED_DATA 
GO

ALTER DATABASE [DiamondDW] ADD FILE ( NAME = N'Optimized_Data', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Optimized_Data.mdf') TO FILEGROUP [PrimaryMOD] 
GO


USE [DiamondDW]
GO
ALTER DATABASE [DiamondDW]  REMOVE FILE [Optimized_Data]
GO
ALTER DATABASE [DiamondDW] REMOVE FILEGROUP [PrimaryMOD]
GO
truncate table diamonddw.dbo.dimcontactbig
truncate table diamonddw.[dbo].[StagingDimContact]
use DiamondDW

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='StagingDimContactNonDurable')
DROP TABLE StagingDimContactNonDurable

CREATE TABLE [dbo].[StagingDimContactNonDurable](
	[ContactKey] [int] IDENTITY(1,1) NOT NULL primary key nonclustered,
	[FirstName] [nvarchar](100) NULL,
	[SecondName] [nvarchar](100) NULL,
	[ContactBusinessKey] [varchar](1000) NULL,
	[Source] [varchar](100) NULL,
	[EmailAddress] [nvarchar](100) NULL,
	[TelephoneNumber] [varchar](100) NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[Town] [nvarchar](100) NULL,
	[Postcode] [nvarchar](100) NULL,
	[County] [nvarchar](100) NULL,
	[Country] [varchar](100) NULL,
	[SourceStatus] [varchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[InferredMember] [bit] NULL,
	[CurrentRecord] [bit] NULL,
	[ToDate] [datetime] NULL,
	[TaskID] [varchar](50) NULL,
	[ExecutionStartTime] [datetime] NULL
)

With(Memory_optimized=on,Durability=SCHEMA_ONLY)

insert into  StagingDimContactNonDurable (FirstName) values ('dd')