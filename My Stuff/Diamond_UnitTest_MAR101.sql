
--MAR101*99

use Diamond
-- $(BuildID)

insert into ad.test (BuildID, TestType, TestDescription, TestCount1,TestCount2)
SELECT $(BuildID), 'Unit','Test DespatchMethodID column exists in Membership Table',1,(select 1 FROM INFORMATION_SCHEMA.Columns WHERE TABLE_name = 'Product' and column_name = 'ColumnA')
