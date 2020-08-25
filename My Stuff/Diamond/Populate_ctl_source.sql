
use DiamondDW

truncate table ctl.source

insert into ctl.Source (Name, Code, Description,IsActive,FilePath,AgeOfFilesHours)
values ('AMPS','AMP','AMPS',1,'C:\Repo\JosephSteelePerkins\Diamond\SourceFiles\AMPS',24),
('Eloqua','ELO','Eloqua',1,'C:\Repo\JosephSteelePerkins\Diamond\SourceFiles\Eloqua',24)

select * from ctl.sourcelog



insert into ctl.source

select code, filepath
from ctl.source
where isactive = 1

truncate table ctl.sourcefile

insert into ctl.sourcefile (Code,FileName) values ('ELO','Contact'), ('AMP','Contact'), ('ELO','Membership')