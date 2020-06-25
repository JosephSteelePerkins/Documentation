-- JoeTest has been given the 'public' role in the SSISDB database
-- he can't see any packages and can't see any rows in this table



-- lets add him to the ssis_logreader role

USE [SSISDB]
GO
ALTER ROLE [ssis_logreader] ADD MEMBER [JoeTest]
GO

-- now he can see this table but still can't see any packages

select * from SSISDB.catalog.operations

-- obviously giving him ssis_admin role means he can see everything BUT because it
-- is a SQL account, he can't execute the package!

USE [SSISDB]
GO
ALTER ROLE [ssis_admin] ADD MEMBER [JoeTest]
GO

-- for now lets revoke it again

USE [SSISDB]
GO
ALTER ROLE [ssis_admin] DROP MEMBER [JoeTest]
GO

-- give him read access to the specific folder

EXEC [SSISDB].[catalog].[grant_permission] @object_type=1, @object_id=3, @principal_id=13, @permission_type=1
GO

-- he can now see the packages, and can deploy. But can't do it because of the
-- SQL Authentication issue again

-- this time we'll do the same thing with a windows authenticated login
-- give him read-only

EXEC [SSISDB].[catalog].[grant_permission] @object_type=1, @object_id=3, @principal_id=17, @permission_type=1
GO

-- can see everything but can't deploy

-- given him execute rights

-- still can't execute the package


-- give him modify rights
EXEC [SSISDB].[catalog].[grant_permission] @object_type=1, @object_id=3, @principal_id=17, @permission_type=102
GO

-- still can't execute

-- give him execute rights on the project itself

EXEC [SSISDB].[catalog].[grant_permission] @object_type=2, @object_id=4, @principal_id=17, @permission_type=1
GO

EXEC [SSISDB].[catalog].[grant_permission] @object_type=2, @object_id=4, @principal_id=17, @permission_type=3
GO

-- this time it worked