
-- what are the advantages of being able to perform a full text search?

-- a query like the below would involve a full table scan. A standard index can't be used. But a full-text index can be used.
select * from Production.ProductReview where comments like '%believe%'

-- to select on a full-text index can use CONTAINS

select * from Production.ProductReview where contains(Comments, 'Great')

-- obviously this doesn't work on a on non-full-text field

select * from Production.ProductReview where contains(EmailAddress, 'Great')

-- or use FREETEXT to find any word

select * from Production.ProductReview where freetext(Comments, 'Great little')

--  CONTAINSTABLE or FREETEXTTABLE for fuzzy (though don't know what the difference is)

SELECT FT_TBL.ProductDescriptionID,  
   FT_TBL.Description,   
   KEY_TBL.RANK  
FROM Production.ProductDescription AS FT_TBL INNER JOIN  
   CONTAINSTABLE (Production.ProductDescription,  
      Description,   
      '(light NEAR aluminum) OR  
      (lightweight NEAR aluminum)'  
   ) AS KEY_TBL  
   ON FT_TBL.ProductDescriptionID = KEY_TBL.[KEY]  
WHERE KEY_TBL.RANK > 2  
ORDER BY KEY_TBL.RANK DESC;  

SELECT KEY_TBL.RANK, FT_TBL.Description  
FROM Production.ProductDescription AS FT_TBL   
     INNER JOIN  
     FREETEXTTABLE(Production.ProductDescription, Description,  
                    'perfect all-around bike') AS KEY_TBL  
     ON FT_TBL.ProductDescriptionID = KEY_TBL.[KEY]  
WHERE KEY_TBL.RANK >= 10  
ORDER BY KEY_TBL.RANK DESC 

-- we will create one on a copy of the Production.Document table

select *
into Production.DocumentJoe
from Production.Document

select  *from Production.Document

-- to create a full-text index first you need to create a catalogue

USE AdventureWorks;  
GO  
CREATE FULLTEXT CATALOG AdvWksDocFTCat; 

CREATE FULLTEXT CATALOG ProductDescription; 

-- there has to be an unique index on the 

CREATE UNIQUE INDEX ui_ukDocJoe ON Production.DocumentJoe(rowguid); 

-- then you can create the full-text index

CREATE FULLTEXT INDEX ON Production.DocumentJoe
(  
    Document                         --Full-text index column name   
        TYPE COLUMN FileExtension    --Name of column that contains file type information  
        Language 2057                 --2057 is the LCID for British English  
)  
KEY INDEX ui_ukDocJoe ON AdvWksDocFTCat --Unique index  
WITH CHANGE_TRACKING AUTO            --Population type;  
GO  

CREATE FULLTEXT INDEX ON Production.ProductDescription
(  
    Description                         --Full-text index column name   
        --TYPE COLUMN Description    --Name of column that contains file type information  
        Language 2057                 --2057 is the LCID for British English  
)  
KEY INDEX pK_ProductDescription_ProductDescriptionID ON ProductDescription --Unique index  
WITH CHANGE_TRACKING AUTO            --Population type;  

select FileExtension from Production.DocumentJoe

-- to see what tables/columns have a fulltext index

SELECT t.name, c.name, fic.*
FROM sys.columns c 
INNER JOIN sys.fulltext_index_columns fic 
ON c.object_id = fic.object_id 
AND c.column_id = fic.column_id
inner join sys.tables t
on c.object_id = t.object_id