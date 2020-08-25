select count(1) from dw.membership
select count(1) from dw.Contact

select count(1)
from dw.Contact c
inner join dw.membership m
on c.SourceContactID = m.sourcecontactid
and c.MarketCode = m.marketcode
and c.Source = m.source

select count(1) -- 4,852,688
from etl.Contact c
inner join etl.Membership m
on c.SourceContactID = m.sourcecontactid
and c.MarketCode = m.marketcode
and c.Source = m.source

select m.* 
from dw.membership m
left join dw.Contact c
on c.SourceContactID = m.sourcecontactid
and c.MarketCode = m.marketcode
and c.Source = m.source
where c.MarketCode is null

select * from dw.membership where sourcecontactid = '2419473'
select * from dw.contact where sourcecontactid = '2419473'

truncate table dw.contact

exec [etl].[sp_Load_DW_Contact]

select distinct source from etl.Membership where source <> 'amp'
select distinct source from dw.Membership where source <> 'amp'


select 