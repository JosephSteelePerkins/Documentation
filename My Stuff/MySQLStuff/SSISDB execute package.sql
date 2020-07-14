
use SSISDB

select * from [SSISDB].[internal].[packages]

select * from ssisdb.catalog.environment_references




Declare @execution_id bigint

EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Load into ETL_Staging.dtsx',
    @execution_id=@execution_id OUTPUT,
    @folder_name=N'Diamond',
	  @project_name=N'Diamond',
  	@use32bitruntime=False,
	  @reference_id=1
Select @execution_id
DECLARE @var0 smallint = 1
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,
    @object_type=50,
	  @parameter_name=N'LOGGING_LEVEL',
	  @parameter_value=@var0
EXEC [SSISDB].[catalog].[start_execution] @execution_id

print @execution_id

select * from SSISDB.catalog.executions -- 10017

select * from ssisdb.catalog.operations

se

select * from catalog.executable_statistics where executable_id = 10017