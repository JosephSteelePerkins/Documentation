
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


  sp_who

  kill 53