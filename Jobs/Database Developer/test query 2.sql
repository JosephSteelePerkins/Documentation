DROP TABLE NDCS_ETL.dbo.EN_temp_phone_exclusions;

GO

SELECT		e.tableid,
			e.constituentid,
			e.constituentname,
			e.campaign_date,
			e.phone_consent_to_contact, 
			sc1.STARTDATE AS [VIKI phone solicit code startdate],
			sc1.[DESCRIPTION] AS [VIKI phone solicit code]

INTO		NDCS_ETL.dbo.EN_temp_phone_exclusions

FROM		##temp_EN_consent_errors e

-- solicit code set by this staging record
		LEFT JOIN	(
					-- distinct used to tidy up output where more than 1 donation made on same day
					SELECT DISTINCT csc1.CONSTITUENTID, sc1.[DESCRIPTION], STARTDATE
							FROM	CRM.dbo.CONSTITUENTSOLICITCODE csc1 

									INNER JOIN CRM.dbo.SOLICITCODE sc1 ON csc1.SOLICITCODEID =sc1.ID  
															AND sc1.[DESCRIPTION] LIKE '%phone%'

							WHERE	csc1.COMMENTS LIKE 'EN%' 
								) sc1 ON e.CONSTITUENTID = e.CONSTITUENTID
										 

WHERE		[Interpreted phone consent] <> [NEW Interpreted phone consent]

-- no subsequent opt in
			AND NOT EXISTS	(
								SELECT	CONSTITUENTID
								FROM	CRM.dbo.CONSTITUENTSOLICITCODE csc2 
										INNER JOIN CRM.dbo.SOLICITCODE sc2 ON csc2.SOLICITCODEID =sc2.ID  
											AND sc2.[DESCRIPTION] = 'Phone opt-in'
								WHERE	csc2.CONSTITUENTID = e.constituentid
										AND DATEDIFF(DAY, e.campaign_date, csc2.STARTDATE) > 0
								) 





------------ mine

select count(1)
from [AdventureWorks2017].production.product p
left join [AdventureWorks2017].production.ProductModel pm
on p.ProductModelID = pm.ProductModelID -- 504

select count(1)
from [AdventureWorks2017].production.product p
left join [AdventureWorks2017].production.ProductModel pm
on p.ProductModelID = p.ProductModelID -- 37969

select count(1)
from [AdventureWorks2017].production.product p
cross join [AdventureWorks2017].production.ProductModel pm
on p.ProductModelID = p.ProductModelID -- 37969