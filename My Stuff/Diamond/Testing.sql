-- check only 1 record per source, sourcecontactid, marketcode is flagged as IsCurrent


select Source, SourceContactID, MarketCode, count(case when IsCurrent = 1 then 1 else null end)
from dw.Contact
group by Source, SourceContactID, MarketCode
having count(case when IsCurrent = 1 then 1 else null end) <> 1


select Source, SourceContactID, MarketCode, productcode, count(case when IsCurrent = 1 then 1 else null end)
from dw.membership
group by Source, SourceContactID, MarketCode, productcode
having count(case when IsCurrent = 1 then 1 else null end) <> 1

select count(1) from dw.Membership (nolock) --21,039,200

select count(1) from dw.Membership where iscurrent = 1 -- 1,5028,000

select count(1)
from
(select Source, SourceContactID, MarketCode, productcode
from dw.membership
group by Source, SourceContactID, MarketCode, productcode) x
