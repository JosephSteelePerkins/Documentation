USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = templog,
   SIZE = 3MB) --this size should be more than the size of Model database
GO


ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev010,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev011,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev012,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev013,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev014,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev015,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev016,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev017,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev018,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev019,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev011,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev02,
   SIZE = 3MB) --this size should be more than the size of Model database
GO


ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev020,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev021,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev022,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev023,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev024,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev03,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev04,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev05,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev06,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev07,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev08,
   SIZE = 3MB) --this size should be more than the size of Model database
GO

ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = tempdev09,
   SIZE = 3MB) --this size should be more than the size of Model database
GO






USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE
   (NAME = templog,
   SIZE = 5MB)
GO

-- then restart SQL Service