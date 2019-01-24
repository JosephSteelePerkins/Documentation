ALTER TABLE test  WITH CHECK ADD CONSTRAINT [CK_test] CHECK  (g = 1 or g =2)

-- check columns exists in TABLE if it does DROP it

IF EXISTS (select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = 'test' and column_name = 'f')
ALTER TABLE test DROP COLUMN f

-- check if index exists

IF EXISTS (select 1 FROM sys.INDEXes WHERE name = 'x_test')
DROP INDEX x_test on test

-- check if constraint exists

IF EXISTS (select 1 FROM INFORMATION_SCHEMA.check_constraints WHERE constraint_name = 'ck_test')
ALTER TABLE test DROP constraint ck_test


-- check if table exists

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='test')
DROP TABLE test

CREATE TABLE test(f1 varchar(10))

-- check if stored procedure exists

IF EXISTS (SELECT * FROM sys.objects WHERE type_desc = 'SQL_STORED_PROCEDURE' AND name = 'up_DeleteChildlessContacts')
DROP PROCEDURE db.up_DeleteChildlessContacts

-- check if primary key exists

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE  CONSTRAINT_TYPE = 'PRIMARY KEY'
    AND TABLE_NAME = '[tblReturnVoucher]' 
    AND TABLE_SCHEMA ='dbo' )

-- check if temp table exists

IF OBJECT_ID('tempdb..#DemographicBest') IS NOT NULL 
	DROP TABLE #DemographicBest
	


