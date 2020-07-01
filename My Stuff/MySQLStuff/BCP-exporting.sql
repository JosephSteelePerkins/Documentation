drop table joe
create table joe (Field1 varchar(10), Field2 varchar(10))

insert into joe values ('dd','dd')
insert into joe values ('dd','dd')



EXEC master ..xp_cmdshell  'BCP "Select fields FROM [SDS_Exporter].dbo.tmp_AF_Exp18_20191216134_SCD_nvar order by roworder" queryout "C:\More2 Client Processes\SDS_Extractor\Test\FunnelReport_20191216.csv" -S M2LAP162\MSSQLSERVER2017 -T -q -r"\n" -c -C 65001'

EXEC master..xp_cmdshell 'BCP "Select * from joe.dbo.joe r" queryout "C:\More2 Client Processes\SDS_Extractor\Test\joe.csv" -S M2LAP162 -T -q -r"\n" -c -C 65001'



EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
