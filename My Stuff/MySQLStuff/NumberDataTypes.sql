-- decimal

drop table #number

create table #number (DecimalExample Decimal (6,5))

-- this works

insert into #number values (1.4343)

-- this doesn't work because 6 minus 5 equals 1 so only 1 number can be stored to the left of the decimal place
insert into #number values (431.4343)

-- this does work

insert into #number values (1.43)

-- money,

create table #numbermoney (MoneyExample money)

-- works

insert into #numbermoney values (32.43)

select * from #numbermoney

insert into #numbermoney values (32.434)


SELECT CONVERT(MONEY, 'q1,000.68')