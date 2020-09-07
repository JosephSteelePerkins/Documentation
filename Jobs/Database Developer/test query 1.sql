IF OBJECT_ID('tempdb..#SOURCE') IS NOT NULL DROP TABLE #SOURCE

CREATE TABLE #SOURCE	
			(
			  S_ID		UNIQUEIDENTIFIER NOT NULL
			  , IMD		NVARCHAR(10)			
			)

CREATE INDEX CIDX ON #SOURCE (S_ID)
GO

INSERT INTO #SOURCE(S_ID, IMD)
			VALUES('175fbac6-407f-4a00-8d8d-9479a92ce868',3),
				  ('14d29432-92e5-4b2b-8e11-fedcdadbf7c4',4)

DECLARE  @C_ID UNIQUEIDENTIFIER
		, @RecTotal int						-- Total number of records in the trusts temp table
		, @Count int						-- Counter to monitor how many records have been processed via the loop
		, @IMD_V NVARCHAR(10)
		, @Update int
		, @Insert int
		, @Add_C_by uniqueidentifier

		-- not sure what this stored proc does. But I think it passes out a uniqueidentifier so can assume this is populated at this point

if @Add_C_by is null  
		--exec crm.dbo.USP_CHANGEAGENT_GETORCREATECHANGEAGENT @Add_C_by output
		set @Add_C_by = '14d29432-92e5-4b2c-8e11-fedcdadbf7c4'
		--print @Add_C_by

SET @Count = 0
SET @Update = 1
SET @Insert = 1
SET @RecTotal = (SELECT count(*) FROM #SOURCE)

WHILE @Count < @RecTotal
BEGIN
	SELECT	@C_ID = S_id
			, @IMD_V = IMD
	
	--select S_id, IMD
	FROM #SOURCE
	ORDER BY S_ID

	OFFSET @COUNT ROWS
	FETCH NEXT 1 ROWS ONLY
	
	select @C_ID
	select @IMD_V
	

--Check to see if the constituent exists and then update the values.
IF EXISTS(select * from CRM.dbo.ATTRIBUTEC7A5E4CE0FCA44948AACEE1766ED901B where CONSTITUENTID = @C_ID)

	PRINT 'EXISTS'
		 UPDATE CRM.dbo.ATTRIBUTEC7A5E4CE0FCA44948AACEE1766ED901B
		 SET value =
		 ( CASE																--Depending on whether the Postcode is valid or not (-99 not valid) it will either update the 
		   WHEN (@IMD_V <> -99) THEN @IMD_V									--constituent record Decile score with the latest IMD Value, however if the Postcode isn't valid
		   ELSE value														--it retains the existing value.  This will be the same for the Comment and Start date.
		   END
		 ),
		   comment = 
		 ( CASE 
		   WHEN (@IMD_V <> -99) THEN 'has a post code'
		   ELSE 'Does not have a post code'	
		   END
		 ),
		   STARTDATE = 
		 ( CASE 
		   WHEN (@IMD_V <> -99) THEN GETDATE()							
		   ELSE STARTDATE													
		   END
		 )
		 WHERE CONSTITUENTID = @C_ID
		 PRINT @UPDATE
		 SET @Update = @Update + 1


-- increment the counter & output results
NEXT:
	PRINT @C_ID
	PRINT @IMD_V
	PRINT @RecTotal
	PRINT @Count
	SET @Count = @Count + 1
END
