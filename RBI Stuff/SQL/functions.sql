USE [ETL_Staging]
GO
/****** Object:  UserDefinedFunction [ETL].[edit_distance]    Script Date: 20/12/2018 10:00:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [ETL].[edit_distance](@s1 nvarchar(3999), @s2 nvarchar(3999))
RETURNS int
AS
BEGIN
 DECLARE @s1_len int, @s2_len int
 DECLARE @i int, @j int, @s1_char nchar, @c int, @c_temp int
 DECLARE @cv0 varbinary(8000), @cv1 varbinary(8000)

 SELECT
  @s1_len = LEN(@s1),
  @s2_len = LEN(@s2),
  @cv1 = 0x0000,
  @j = 1, @i = 1, @c = 0

 WHILE @j <= @s2_len
  SELECT @cv1 = @cv1 + CAST(@j AS binary(2)), @j = @j + 1

 WHILE @i <= @s1_len
 BEGIN
  SELECT
   @s1_char = SUBSTRING(@s1, @i, 1),
   @c = @i,
   @cv0 = CAST(@i AS binary(2)),
   @j = 1

  WHILE @j <= @s2_len
  BEGIN
   SET @c = @c + 1
   SET @c_temp = CAST(SUBSTRING(@cv1, @j+@j-1, 2) AS int) +
    CASE WHEN @s1_char = SUBSTRING(@s2, @j, 1) THEN 0 ELSE 1 END
   IF @c > @c_temp SET @c = @c_temp
   SET @c_temp = CAST(SUBSTRING(@cv1, @j+@j+1, 2) AS int)+1
   IF @c > @c_temp SET @c = @c_temp
   SELECT @cv0 = @cv0 + CAST(@c AS binary(2)), @j = @j + 1
 END

 SELECT @cv1 = @cv0, @i = @i + 1
 END

 RETURN @c
END

USE [ETL_Staging]
GO

/****** Object:  UserDefinedFunction [ETL].[fncharacternumber_Only]    Script Date: 20/12/2018 10:00:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER FUNCTION [ETL].[fncharacternumber_Only]    
   (  @InParam   varchar(8000) )    
   RETURNS varchar(8000)    
AS    
   BEGIN    
      IF patindex( '%[^A-Z0-9_]%', @InParam ) > 0    
         BEGIN    
            WHILE patindex( '%[^A-Z0-9_]%', @InParam ) > 0    
               BEGIN    
                  SET @InParam = Stuff( @InParam, patindex( '%[^A-Z0-9_]%', @InParam), 1, '_' )      
               END     
         END    
      RETURN @InParam    
  END 




GO

USE [ETL_Staging]
GO

/****** Object:  UserDefinedFunction [ETL].[fncharacterOnly]    Script Date: 20/12/2018 10:00:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [ETL].[fncharacterOnly]    
   (  @InParam   varchar(8000) )    
   RETURNS varchar(500)    
AS    
   BEGIN    
      IF patindex( '%[^A-Z]%', @InParam ) > 0    
         BEGIN    
            WHILE patindex( '%[^A-Z]%', @InParam ) > 0    
               BEGIN    
                  SET @InParam = Stuff( @InParam, patindex( '%[^A-Z]%', @InParam), 1, '' )      
               END     
         END    
      RETURN @InParam    
  END 


GO

USE [ETL_Staging]
GO

/****** Object:  UserDefinedFunction [ETL].[fnColumnDupes]    Script Date: 20/12/2018 10:00:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [ETL].[fnColumnDupes]    
   (  @InParam   varchar(8000) )    
   RETURNS varchar(8000)    
AS    
   BEGIN    
   SET @InParam = Case when len(LEFT(@InParam,LEN(@InParam)-LEN(LTRIM(RTRIM(SUBSTRING(@InParam,patindex('%Dupes[0-9]%',@InParam),1000)))))) > 0 then 
						LEFT(@InParam,LEN(@InParam)-LEN(LTRIM(RTRIM(SUBSTRING(@InParam,patindex('%Dupes[0-9]%',@InParam),1000)))))
						Else @InParam End
   
      RETURN @InParam    
  END 




GO

USE [ETL_Staging]
GO

/****** Object:  UserDefinedFunction [ETL].[fnNumbersOnly]    Script Date: 20/12/2018 10:00:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [ETL].[fnNumbersOnly]  
   (  @InParam   varchar(8000) )  
   RETURNS varchar(500)  
AS  
   BEGIN  
      IF patindex( '%[^0-9]%', @InParam ) > 0  
         BEGIN  
            WHILE patindex( '%[^0-9]%', @InParam ) > 0  
               BEGIN  
                  SET @InParam = Stuff( @InParam, patindex( '%[^0-9]%', @InParam), 1, '' )    
               END   
         END 
      RETURN case when len(@InParam) > 0 then @InParam else null end
   END  


GO

USE [ETL_Staging]
GO

/****** Object:  UserDefinedFunction [ETL].[RemoveNode]    Script Date: 20/12/2018 10:01:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER FUNCTION [ETL].[RemoveNode](@xml XML)
 RETURNS XML
AS
BEGIN
 --SET @xml.modify('delete  //*[not(node())]')
 IF @xml is not null
 SET @xml.modify('delete //*[not(node())]')
  
 RETURN @xml
END




GO


