use DiamondDW

select count(1) from StagingDimContactNonDurable
select count(1) from DimContact

MERGE DimContact AS TARGET
USING StagingDimContactNonDurable AS SOURCE 
ON (TARGET.ContactBusinessKey = SOURCE.ContactBusinessKey)

WHEN NOT MATCHED BY TARGET THEN 
INSERT (FirstName, SecondName,ContactBusinessKey,Source,EmailAddress,TelephoneNumber,AddressLine1,AddressLine2,Town,Postcode,County,Country,SourceStatus,CurrentRecord) 
VALUES (SOURCE.FirstName, SOURCE.SecondName,SOURCE.ContactBusinessKey,SOURCE.Source,SOURCE.EmailAddress,SOURCE.TelephoneNumber
,SOURCE.AddressLine1,SOURCE.AddressLine2,SOURCE.Town,SOURCE.Postcode,SOURCE.County,SOURCE.Country,SOURCE.SourceStatus,1 );

-- change the email address of 10% of records



select count(1)
from StagingDimContactNonDurable s
inner join DimContact dc
on s.ContactBusinessKey = dc.ContactBusinessKey
where isnull(s.FirstName,'') <> isnull(dc.FirstName,'')
or isnull(s.SecondName,'') <> isnull(dc.SecondName,'')
or isnull(s.ContactBusinessKey,'') <> isnull(dc.ContactBusinessKey,'')
or isnull(s.Source,'') <> isnull(dc.Source,'')
or isnull(s.EmailAddress,'') <> isnull(dc.EmailAddress,'')
or isnull(s.TelephoneNumber,'') <> isnull(dc.TelephoneNumber,'')
or isnull(s.AddressLine1,'') <> isnull(dc.AddressLine1,'')
or isnull(s.AddressLine2,'') <> isnull(dc.AddressLine2,'')
or isnull(s.Town,'') <> isnull(dc.Town,'')
or isnull(s.Postcode,'') <> isnull(dc.Postcode,'')
or isnull(s.County,'') <> isnull(dc.County,'')
or isnull(s.Country,'') <> isnull(dc.Country,'')
or isnull(s.SourceStatus,'') <> isnull(dc.SourceStatus,'')

select HASHBYTES ( 'SHA1', isnull(FirstName,'')+isnull(SecondName,'') + isnull(Source,'') + isnull(EmailAddress,'') + isnull(TelephoneNumber,'')
+ isnull(AddressLine1,'') + isnull(AddressLine2,'') + isnull(Town,'') + isnull(Postcode,'') + isnull(County,'') + isnull(SourceStatus,''))
from DimContact



select count(1)
from StagingDimContactNonDurable s
inner join DimContact dc
on s.ContactBusinessKey = dc.ContactBusinessKey
