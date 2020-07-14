
--------- script from book
-- TK463, Chapter 12

/*********************/
/* Lesson 2 Practice */
/*                   */
/* Exercise 1        */
/*********************/

-- Create logins
USE MASTER;

CREATE LOGIN Dejan
WITH PASSWORD = 'p@S5w0rd';

CREATE LOGIN Grega
WITH PASSWORD = 'p@S5w0rd';

CREATE LOGIN Matija
WITH PASSWORD = 'p@S5w0rd';
GO


-- Create SSISDB Users
USE SSISDB;

CREATE USER Dejan;
CREATE USER Grega;
CREATE USER Matija;
GO

/*********************/
/* Lesson 2 Practice */
/*                   */
/* Exercise 1        */
/*********************/


-- Verify your own settings
SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO


-- Verify Dejan's Settings
EXECUTE AS USER = 'Dejan';
GO

SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO

REVERT;
GO


-- Verify Grega's Settings
EXECUTE AS USER = 'Grega';
GO

SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO

REVERT;
GO


-- Verify Matija's Settings
EXECUTE AS USER = 'Matija';
GO

SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO

REVERT;
GO




------------------ end of script from book












USE [SSISDB]
GO

/****** Object:  User [DESKTOP-CGRB0T0\Developer]    Script Date: 27/03/2019 10:14:19 ******/
DROP USER [DESKTOP-CGRB0T0\Developer]
GO

select * 
from sys.database_permissions 
where grantor_principal_id = user_id ('DESKTOP-CGRB0T0\Developer'); 

SELECT DISTINCT(SUSER_NAME(grantor_principal_id)), grantor_principal_id
FROM SSISDB.sys.database_permissions


select * from internal.operation_permissions






select
    'Database role' as [object_type],
    rdp.name as [path],
    mdp.name as [user] ,
    null as permission_type,
    null as [Permission]
from
    sys.database_role_members drm
inner join
    sys.database_principals rdp
    on drm.role_principal_id = rdp.principal_id
inner join
    sys.database_principals mdp
    on drm.member_principal_id = mdp.principal_id
union all
/* folders */
SELECT
    'folder' as [object_type],
    f.name as [path],
    pri.name as [user],
    permission_type,
    CASE
    WHEN [obj].permission_type=1 THEN 'Read'
    WHEN [obj].permission_type=2 THEN 'Modify'
    WHEN [obj].permission_type=3 THEN 'Execution'
    WHEN [obj].permission_type=4 THEN 'Manage permissions'
    WHEN [obj].permission_type=100 THEN 'Create Objects'
    WHEN [obj].permission_type=102 THEN 'Modify Objects'
    WHEN [obj].permission_type=103 THEN 'Execute Objects'
    WHEN [obj].permission_type=101 THEN 'Read Objects'
    WHEN [obj].permission_type=104 THEN 'Manage Object Permissions'
    END AS [Permission]
FROM
    [internal].[object_permissions] AS obj
INNER JOIN
    [sys].[database_principals] AS pri
    ON obj.[sid] = pri.[sid]
INNER JOIN
    [internal].[folders] as f
    ON f.folder_id=obj.object_id
UNION ALL
/* projects */
SELECT
    'project' as [object_type],
    f.name + '/' + p.name as [path],
    pri.name as [user],
    permission_type,
    CASE
    WHEN [obj].permission_type=1 THEN 'Read'
    WHEN [obj].permission_type=2 THEN 'Modify'
    WHEN [obj].permission_type=3 THEN 'Execution'
    WHEN [obj].permission_type=4 THEN 'Manage permissions'
    WHEN [obj].permission_type=100 THEN 'Create Objects'
    WHEN [obj].permission_type=102 THEN 'Modify Objects'
    WHEN [obj].permission_type=103 THEN 'Execute Objects'
    WHEN [obj].permission_type=101 THEN 'Read Objects'
    WHEN [obj].permission_type=104 THEN 'Manage Object Permissions'
    END AS [Permission]
FROM
    [internal].[project_permissions] AS obj
INNER JOIN
    [sys].[database_principals] AS pri
    ON obj.[sid] = pri.[sid]
INNER JOIN
    [internal].[projects] as p
    ON p.project_id=obj.object_id
INNER JOIN
    [internal].[folders] as f
    ON p.folder_id=f.folder_id
UNION ALL
/* environments */
SELECT
    'environment' as [object_type],
    f.name + '/' + e.environment_name as [path],
    pri.name as [user],
    permission_type,
    CASE
    WHEN [obj].permission_type=1 THEN 'Read'
    WHEN [obj].permission_type=2 THEN 'Modify'
    WHEN [obj].permission_type=3 THEN 'Execution'
    WHEN [obj].permission_type=4 THEN 'Manage permissions'
    WHEN [obj].permission_type=100 THEN 'Create Objects'
    WHEN [obj].permission_type=102 THEN 'Modify Objects'
    WHEN [obj].permission_type=103 THEN 'Execute Objects'
    WHEN [obj].permission_type=101 THEN 'Read Objects'
    WHEN [obj].permission_type=104 THEN 'Manage Object Permissions'
    END AS [Permission]
FROM
    [internal].[project_permissions] AS obj
INNER JOIN
    [sys].[database_principals] AS pri
    ON obj.[sid] = pri.[sid]
INNER JOIN
    [internal].[environments] as e
    ON e.environment_id=obj.object_id
INNER JOIN
    [internal].[folders] as f
  ON e.folder_id=f.folder_id


