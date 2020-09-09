
-- this is your normal left join. returns 504 records

create table #test1 (Name varchar(10), t1ID int )
create table #test2 (Name varchar(10), t2ID int )

insert into #test1 values ('aa',1),('bb',2),('cc',3),('dd',4),('ee',5),('ff',6)
insert into #test2 values ('aa',1),('bb',2),('cc',3),('dd',4),('ff',6),('gg',7)

select * from #test1
select * from #test2

-- inner join we know and love - 5

select count(1)
from #test1 t1
inner join #test2 t2
on t1.t1ID = t2.t2ID

-- left join, obvious -- 6

select count(1)
from #test1 t1
left join #test2 t2
on t1.t1ID = t2.t2ID

-- cross join. this is a cartisian product -- 36

select count(1)
from #test1 
cross join #test2

-- outer join returns all records, where they join and where they don't

select *
from #test1 t1
full outer join #test2 t2
on t1.t1ID = t2.t2ID

-- but what does this weird thing do?
-- it produces a cartesian join
-- which makes sense as all records are being joined with all records where t1ID = t1ID, which is all of them

select count(1)
from #test1 t1
left join #test2 t2
on t1.t1ID = t1.t1ID


-- try it on the product table -- 504

select count(1)
from Production.Product p
left join Production.ProductModel pm
on p.ProductModelID = pm.ProductModelID

-- cross join --64512
-- so ProductID 1 will match with every record in ProductModel table
-- even though it doesn't have a ProductModelID -- 128

select p.ProductID, p.ProductModelID, pm.ProductModelID
from Production.Product p
cross join Production.ProductModel pm
where p.ProductID = 1 
order by p.ProductID

-- this is also a cartisian join

select p.ProductID, p.ProductModelID, pm.ProductModelID
from Production.Product p
left join Production.ProductModel pm
on 1=1
where p.ProductID = 1 
order by p.ProductID

-- but this isn't

select p.ProductID, p.ProductModelID, pm.ProductModelID
from Production.Product p
left join Production.ProductModel pm
on p.ProductModelID = p.ProductModelID
where p.ProductID = 1 
order by p.ProductID

-- that is because ProductModelID is null so won't match with itself. This can be shown here

select *
from Production.Product 
where ProductModelID = ProductModelID
and ProductID = 1

-- and if you convert nulls so they do match you get a cartesian product again

select p.ProductID, p.ProductModelID, pm.ProductModelID
from Production.Product p
left join Production.ProductModel pm
on isnull(p.ProductModelID,0) = isnull(p.ProductModelID,0)
where p.ProductID = 1 
order by p.ProductID


