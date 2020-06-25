-- remember this!

/*
Exam Tip

Make sure you understand the relationship between columnstore indexes and table partitioning thoroughly.
*/

use DiamondDW

drop table DimContact2

select top 1000000 *
into DimContact2
from DimContact  

drop index DimContact2.x_DimContact
CREATE COLUMNSTORE INDEX x_DimContact ON DimContact2 (EmailAddress,FirstName)
CREATE COLUMNSTORE INDEX x_DimContact2 ON DimContact2 (SecondName)