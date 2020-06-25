drop table #t

select ContactBusinessKey, HASHBYTES ( 'SHA1', isnull(FirstName,'')+isnull(SecondName,'') + isnull(Source,'') + isnull(EmailAddress,'') + isnull(TelephoneNumber,'')
+ isnull(AddressLine1,'') + isnull(AddressLine2,'') + isnull(Town,'') + isnull(Postcode,'') + isnull(County,'') + isnull(SourceStatus,'')) HashB
into #t
from DimContact

select ContactBusinessKey, HASHBYTES ( 'SHA1', isnull(FirstName,'')+isnull(SecondName,'') + isnull(Source,'') + isnull(EmailAddress,'') + isnull(TelephoneNumber,'')
+ isnull(AddressLine1,'') + isnull(AddressLine2,'') + isnull(Town,'') + isnull(Postcode,'') + isnull(County,'') + isnull(SourceStatus,'')) HashB
into #h
from StagingDimContactNonDurable

select count(1)
from #t t
inner join #h h
on t.ContactBusinessKey = h.ContactBusinessKey
where t.HashB <> h.HashB