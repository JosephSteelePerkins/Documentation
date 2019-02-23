
use Diamond

drop SEQUENCE Invoice_Seq

CREATE SEQUENCE Invoice_Seq
 AS INTEGER
 START WITH 1
 INCREMENT BY 1
 MINVALUE 1
 MAXVALUE 1000
 NO CYCLE; 

 SELECT NEXT VALUE FOR Invoice_Seq;

 -- use with a query

 select *, NEXT VALUE FOR Invoice_Seq SequenceID
 from AdventureWorksDW.dbo.DimProduct

 -- use in two tables

 
 CREATE TABLE Meats
(ticket_seq INTEGER NOT NULL PRIMARY KEY,
 meat_type VARCHAR(15) NOT NULL);
 
CREATE TABLE Fish
(ticket_seq INTEGER NOT NULL PRIMARY KEY,
 fish_type VARCHAR(15) NOT NULL);

 insert into Fish values (NEXT VALUE FOR Invoice_Seq, 'asd')

 insert into Meats values (NEXT VALUE FOR Invoice_Seq, 'asd')

 select * from fish
 select * from Meats

 -- or use it in the create table

 CREATE TABLE Fruit
(ticket_seq iNTEGER DEFAULT NEXT VALUE FOR Invoice_Seq,
 fish_type VARCHAR(15) NOT NULL);


 insert into Fruit(fish_type) values ('asdf')

 select * from Fruit