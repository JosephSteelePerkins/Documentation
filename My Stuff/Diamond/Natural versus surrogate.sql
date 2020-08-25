-- make sure good amount of data in dw

select count(1) from dw.contact
select count(1) from dw.Membership

-- not using the IsCurrent flag. Haven't put that much data in

-- how long does it take to select all records joining on natural key

select *
from dw.Contact c
inner join dw.Membership m
on c.Source = m.Source
and c.SourceContactID = m.SourceContactID
and c.MarketCode = m.MarketCode

-- 3:36 to return 3,757,000 records

-- next we are going to add the row_id of contact (which is unique) into the membership table
-- no foreign key reference. will this make a difference?

select row_id from dw.Contact 
group by row_id
having count(1) > 1

alter table dw.membership add contact_row_id int


update dw.Membership
set contact_row_id = c.row_id
from dw.Contact c
inner join dw.Membership m
on c.Source = m.Source
and c.SourceContactID = m.SourceContactID
and c.MarketCode = m.MarketCode

-- now join on this field

select *
from dw.Contact c
inner join dw.Membership m
on c.row_id = m.contact_row_id

-- took 7 minutes

-- now try it with the index

CREATE NONCLUSTERED INDEX x_Membership_Contact_Row_id
ON [dw].[Membership] ([contact_row_id])

select *
from dw.Contact c
inner join dw.Membership m
on c.row_id = m.contact_row_id

-- 6 minutes