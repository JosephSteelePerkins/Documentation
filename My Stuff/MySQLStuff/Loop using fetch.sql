
declare @count int
declare @RecTotal int

SET @Count = 0
SET @RecTotal = (SELECT count(*) FROM [Production].[Location])

WHILE @Count < @RecTotal
BEGIN
	SELECT	*
	FROM [Production].[Location]
	ORDER BY LocationID

	OFFSET @COUNT ROWS
	FETCH NEXT 1 ROWS ONLY
	
	SET @Count = @Count + 1
end
