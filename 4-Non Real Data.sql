USE [Club]

----Jazz
--use club 
--select CONVERT(VARCHAR(6),GETDATE()-104,112)
--------------------------------######### Non real #########------------
----delete Non_Real_Data instead of drop
--select * from Non_Real_Data --115082
drop table Non_Real_Data
--go
select *
into Non_Real_Data
from Postpaid_Activation_Log
where Active_Date >=CAST(CONVERT(VARCHAR(6),GETDATE()-104,112) +'01' AS DATETIME)
and sources like '%Ali%data%'
order by Active_Date
--Jun 45969

Select month(active_date), count(*) from Non_Real_Data
Group by month(active_date)

insert into Non_Real_Data
select *
from Postpaid_Activation_Log
where Active_Date >=CAST(CONVERT(VARCHAR(6),GETDATE()-104,112) +'01' AS DATETIME)
and type like '%port%in%'
--Jun 2326

drop table NonReal_Temp
--go
select *
into NonReal_Temp
from Postpaid_Activation_Log
where Active_Date >=CAST(CONVERT(VARCHAR(6),GETDATE()-104,112) +'01' AS DATETIME)
and Sources not like '%Ali%data%' 
and (type not like '%port%in%' or type is null)
--jun 4831

Select datename(month,active_date), count(*) from NonReal_temp
Group by datename(month,active_date)


-- to remove package change orders
--select * from NonReal_Temp
--select * from NonReal_Temp
delete from NonReal_Temp	
where month(Active_Date)= Month(getdate()-12)  and year(Active_Date)= Year(getdate()-12)
	and sub in (select sub from club.dbo.bsdmain_Nov21 ) 
--Jun 77

--Jun 77




 
insert into Non_Real_Data
select * from NonReal_Temp
--Jun2887

Set ansi_warnings off

update Non_Real_Data
set Pack = b.Pack--select *
from Non_Real_Data a, bsdmain b
where a.Sub = b.Sub 
--and Pack like '%Tracker%' --51425
and b.Pack != a.Pack 
--Jun 9609

--select count(*) from certemp --2390818
--select count(*) from [lhe-cam-1\s1].club.dbo.certemp --2407843
--drop table certemp
--select * into certemp from [lhe-cam-1\s1].club.dbo.certemp --2407843

update Non_Real_Data
set Pack = b.Pack
from Non_Real_Data a, bsdmain b
where a.Sub = b.Sub --97341
and (a.Pack is null or a.Pack = '')
--Jun 28479

-- Update Acc #s
update Non_Real_Data
set Acc = b.acc
from Non_Real_Data a, bsdmain b
where a.Sub = b.sub
and a.Acc is null
--Jun131

----------------------------- CER Pack and SUB not avaiable
--select top 10 * from Postpaid_Activation_Log

--select * from Non_Real_Data
--where Pack is null --6050

update Non_Real_Data
set Pack = b.Pack
--select *
from Non_Real_Data a, Postpaid_Activation_Log b
where a.Sub = b.Sub 
and (a.Pack is null or a.Pack = '')
--Jun11

---------------------
update Non_Real_Data set Channel = 'CS' where Channel = 'CO' --Jun 15257
update Non_Real_Data set Channel = null where Channel = 'M2M'-- 0 
update Non_Real_Data set Channel = null where Channel = 'A2P'--0 

-- Duplications
drop table NonReal_Duplicate 

select  *
into NonReal_Duplicate 
from Non_Real_Data where sub in (
select sub from Non_Real_Data group by sub having count(*) > 1) order by sub
--Jun 266

delete from Non_Real_Data 
where sub in (select distinct sub from NonReal_Duplicate)
--Jun266

--select * from NonReal_Duplicate where acc is null

---------------
drop table xyz

select Sub,Min(Active_Date)Active_Date
into xyz
from NonReal_Duplicate
group by Sub
--Jun133

alter table xyz add Acc varchar (20), Name varchar (65) ,DC varchar (10),Pack varchar (20),Sources varchar (40),i_date Date,Channel varchar (30),CAM varchar (70),Region varchar (20),Ali_DC varchar (10),Siebel_DC varchar (10),PackType varchar (20),Type varchar (40)
--go

--select len(Type) from NonReal_Duplicate
--select top 1 * from xyz
--select top 1 * from NonReal_Duplicate

update xyz
set Acc = b.Acc,
	Name = b.Name,
	DC = b.DC,
	Pack = b.Pack,
	Sources = b.Sources,
	i_date = b.i_date,
	Channel = b.Channel ,
	CAM = b.CAM ,
	Region = b.Region ,
	Ali_DC = b.Ali_DC,
	Siebel_DC = b.Siebel_DC ,
	PackType = b.PackType ,
	Type = b.Type
--select *
from xyz a,NonReal_Duplicate b
where a.sub = b.sub
and a.active_date = b.active_date
--Jun133

insert into Non_Real_Data
select Acc,Sub,Name,Active_Date,DC,Pack,Sources,i_Date,Channel,CAM,Region,Ali_DC, Siebel_DC ,PackType,Type from xyz
--Jun 133

alter table Non_Real_Data alter column 	channel varchar (40)
alter table Non_Real_Data alter column 	CAM varchar (70)

--------------- new month haris
update Non_Real_Data
set Channel = b.Channel,
	CAM = b.[Emp Name],
	Region = b.Region
from Non_Real_Data a,ST b -- latest Month
where a.DC = b.JazzID
--Jun50653

----and a.channel is null			--'Not required now as per discussion with NK'
--0
-- Update from BSD Base if not found in Hierarchy
-- Make CAM name null 
update Non_Real_Data
set Channel = b.Channel,
	Region = b.Region
from Non_Real_Data a,bsdmain b
where a.sub = b.sub
and a.channel is null
--Jun 354
delete from Non_Real_Data where pack in ('Dealer','Employee','Ex PMCL','Official','Official for Testing','Official Dealer','ES Standard')
--jun 712
--#####################################################

alter table Non_Real_Data add FRC_MBU varchar (15), FRC_New_MBU varchar (30),FRC_New_Region varchar(20)
--go
update Non_Real_Data
set FRC_MBU = b.MBU,
	FRC_New_MBU = b.New_MBU,
	FRC_New_Region = b.New_Region
from Non_Real_Data a,FRC_ST b
where a.DC = b.SaleID
--and a.Channel = 'ES' -- old talha bhai query change

--and channel is null  -- Not required as per NK instuctions
--Jun205

update Non_Real_Data 
set Channel = 'ES',
	Region = 'FRC'
where FRC_MBU is not null
--Jun 205

--Haris 
update Non_Real_Data 
set Channel = 'ES',
	Region = 'FRC'
where Channel is Null 
and Pack = 'JB - 300'
--jun0 
----###################################################
---- Non-Real Data
----###################################################


