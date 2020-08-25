-- check only 1 record per source, sourcecontactid, marketcode is flagged as IsCurrent


select Source, SourceContactID, MarketCode, count(case when IsCurrent = 1 then 1 else null end)
from dw.Contact
group by Source, SourceContactID, MarketCode
having count(case when IsCurrent = 1 then 1 else null end) <> 1