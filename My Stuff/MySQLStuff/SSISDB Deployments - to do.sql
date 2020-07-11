SELECT fld.Name as FolderName

,fld.created_By_Name as folderCreatdBy

,fld.Created_time as folderCreateddate
,proj.name projectName
,proj.created_time
,proj.last_deployed_time
,proj.deployed_by_name
,proj.folder_id
,pkg.[project_version_lsn]
,pkg.[name] as Pakagename
,pkg.[description]
,pkg.[package_format_version]
,pkg.[version_major]
,pkg.[version_minor]
,pkg.[version_build]
,pkg.[version_comments]
FROM [SSISDB].[internal].folders fld
left outer join [SSISDB].[internal].[projects] proj on proj.folder_id=fld.folder_id
left outer join [SSISDB].[internal].[packages] pkg on pkg.project_id=pkg.project_id
order by created_time desc


select * from [SSISDB].[internal].folders

select name, version_build from [SSISDB].[internal].[packages] order by name, version_build

use SSISDB

SELECT folders.name [Folder Name]
      ,projects.name [Project Name]
      ,packages.name [Package Name]
      ,version_major [Version Major]
      ,version_minor [Version Minor]
      ,version_build [Version Build]
      ,project_version_lsn [Project LSN]
      ,object_versions.created_time [Installed]
      ,IIF(object_versions.object_version_lsn=projects.object_version_lsn,'Yes','No') [Latest Version?]
FROM    internal.packages
JOIN    internal.projects
ON      projects.project_id=packages.project_id
JOIN    internal.object_versions
ON      object_versions.object_id=projects.project_id
AND     object_versions.object_version_lsn=packages.project_version_lsn
JOIN    internal.folders
ON      folders.folder_id=projects.folder_id
ORDER BY projects.name,packages.name,version_build DESC,project_version_lsn DESC