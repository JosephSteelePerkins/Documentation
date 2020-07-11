select * from SSISDB.catalog.operations order by start_time desc

select  o.operation_id, o.object_name, o.start_time, om.message
from SSISDB.catalog.operation_messages om
inner join SSISDB.catalog.operations o
on o.operation_id = om.operation_id
order by o.start_time desc


create table #Status(StatusID int, StatusDescription varchar(100))
insert into #Status values (1,'Created'),(2,'Running'),(3,'Canceled'),(4,'Failed'),(5,'Pending'),(6,'Ended Unexpectedly'),(7,'Succeeded'),(8,'Stopping'),(9,'Completed')

select statusdescription, * 
from SSISDB.catalog.executions e
left join #Status s
on e.status = s.StatusID
 order by start_time desc

select * from SSISDB.catalog.execution_data_statistics where execution_id = 10081
select * from SSISDB.catalog.execution_component_phases where execution_id = 10081
select * from SSISDB.catalog.event_messages order by message_time desc

select StatusDescription, case operation_type
when 200 then 'create_execution'
when 101 then 'deploy_project' end OperationTypeDescription,*
from SSISDB.catalog.operations o
left join #Status s
on o.status = s.StatusID
 order by created_time desc

