
truncate table ##log

create table ##log (Looper int, CreateDate datetime default getdate())


select createdate, count(1) , max(lastname), min(lastname)
from dw.Contact (nolock)
group by createdate
order by 1


delete from dw.Contact where cast(createdate as date) = cast(getdate() as date)


select createdate, min(lastname), max(lastname), count(1), count(case when iscurrent = 1 then 1 else null end)
from dw.Contact (nolock)
--where lastname = '11Adams_6'
group by CreateDate
order by 1

select *
into ctl.LoadLog
from ##log

alter table ctl.LoadLog add PointInStoredProcedure varchar(100)

alter table ctl.LoadLog add NumberOfRecords int

select count(1) from dw.Contact (nolock) where IsCurrent = 1

select * from dw.Contact where lastname = '11Adams_6'

select * from ctl.LoadLog order by createdate desc

select count(1) from dw.contact (nolock) --18,972,850

