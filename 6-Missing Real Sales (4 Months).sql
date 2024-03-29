USE [Club]

--select * into aaaaaaa from MSTR_Jazz_Missing_Real_uploading

	drop table MSTR_Jazz_Missing_Real_uploading


select distinct Real_Date from MSTR_Jazz_Missing_Real_uploading order by 1

select * from MSTR_Jazz_Missing_Real_uploading where real_date = ''
delete from MSTR_Jazz_Missing_Real_uploading where real_date = 'REAL_DATE'

select * from MSTR_Jazz_Missing_Real_uploading where real_date = '1-303377067871'
select * from MSTR_Jazz_Missing_Real_uploading where Account_Number= '1-293050102706'
select * from MSTR_Jazz_Missing_Real_uploading where customer_ref= '1-293050102706'

update MSTR_Jazz_Missing_Real_uploading
set Customer_Ref = Account_Number
	,Account_Number = Real_Date
	,Real_Date = Activation_Date
	,Activation_Date = Tariff
	,Tariff = Customer_Type
	,Customer_Type = Dealer_Code
	,Dealer_Code = left(Activation_Type,4)
	,Activation_Type =right(Activation_Type,len(Activation_Type)-5)
where real_date = '1-303377067871'


alter Table MSTR_Jazz_Missing_Real_uploading add RealDate date ,ActDate date

Update MSTR_Jazz_Missing_Real_uploading
SET
ActDate = cast(Real_Date as date)

--############## Activation Date ######################
select distinct Activation_Date from MSTR_Jazz_Missing_Real_uploading where ActDate is null


update MSTR_Jazz_Missing_Real_uploading set ActDate =  Right([Activation_Date],4)+'-0'		-- Year
									+ Right(left([Activation_Date],3),1)+'-0'--Month
									+ Left([Activation_Date],1)				-- Day
where [Activation_Date] like '_/_/____' and ActDate is null

update MSTR_Jazz_Missing_Real_uploading set ActDate =  Right([Activation_Date],4)+'-'		-- Year
									+ Right(left([Activation_Date],5),2)+'-'--Month
									+ Left([Activation_Date],2)				-- Day
where [Activation_Date] like '__/__/____' and ActDate is null

update MSTR_Jazz_Missing_Real_uploading set ActDate =  Right([Activation_Date],4)+'-'		-- Year
									+ Right(left([Activation_Date],4),1)+'-'--Month
									+ Left([Activation_Date],2)				-- Day
where [Activation_Date] like '__/_/____' and ActDate is null

update MSTR_Jazz_Missing_Real_uploading set ActDate =  Right([Activation_Date],4)+'-'		-- Year
									+ Right(left([Activation_Date],4),2)+'-'--Month
									+ Left([Activation_Date],1)				-- Day
where [Activation_Date] like '_/__/____' and ActDate is null

select * from MSTR_Jazz_Missing_Real_uploading where ActDate is null
delete from MSTR_Jazz_Missing_Real_uploading where ActDate is null

select min(ActDate),Max(ActDate) from MSTR_Jazz_Missing_Real_uploading 


select distinct Activation_Date			from MSTR_Jazz_Missing_Real_uploading 
select distinct Activation_Date,ActDate from MSTR_Jazz_Missing_Real_uploading order by 2 desc

--########## Real Date Format Issue ################


update MSTR_Jazz_Missing_Real_uploading set RealDate =  Right([Real_Date],4)+'-0'		-- Year
									+ Right(left([Real_Date],3),1)+'-0'--Month
									+ Left([Real_Date],1)				-- Day
where [Real_Date] like '_/_/____' and RealDate is null

update MSTR_Jazz_Missing_Real_uploading set RealDate =  Right([Real_Date],4)+'-'		-- Year
									+ Right(left([Real_Date],5),2)+'-'--Month
									+ Left([Real_Date],2)				-- Day
where [Real_Date] like '__/__/____' and RealDate is null

update MSTR_Jazz_Missing_Real_uploading set RealDate =  Right([Real_Date],4)+'-'		-- Year
									+ Right(left([Real_Date],4),1)+'-'--Month
									+ Left([Real_Date],2)				-- Day
where [Real_Date] like '__/_/____' and RealDate is null

update MSTR_Jazz_Missing_Real_uploading set RealDate =  Right([Real_Date],4)+'-'		-- Year
									+ Right(left([Real_Date],4),2)+'-'--Month
									+ Left([Real_Date],1)				-- Day
where [Real_Date] like '_/__/____' and RealDate is null

select * from MSTR_Jazz_Missing_Real_uploading where RealDate is null

select min(RealDate),max(RealDate) from MSTR_Jazz_Missing_Real_uploading 

select distinct Real_Date			from MSTR_Jazz_Missing_Real_uploading 
select distinct Real_Date,RealDate from MSTR_Jazz_Missing_Real_uploading order by 2 desc

--######## Date Check #######
select * from MSTR_Jazz_Missing_Real_uploading  where ActDate > RealDate
delete from MSTR_Jazz_Missing_Real_uploading  where ActDate > RealDate


select * from MSTR_Jazz_Missing_Real_uploading  where ACTIVATION_TYPE like '%RE%ORG%'

delete from MSTR_Jazz_Missing_Real_uploading  where ACTIVATION_TYPE like '%RE%ORG%'


--##########################################################################
--##########################################################################

select * 
into Real_Duplicate_Missing
from MSTR_Jazz_Missing_Real_uploading where msisdn in (
select msisdn from MSTR_Jazz_Missing_Real_uploading group by msisdn having count(*) > 1)order by 1


---- Delete Duplicate Data 
delete from MSTR_Jazz_Missing_Real_uploading
where msisdn in (select msisdn from Real_Duplicate_Missing)

insert into MSTR_Jazz_Missing_Real_uploading(MSISDN)
select distinct msisdn from Real_Duplicate_Missing
--Jun0

---- Update values Duplicate MSISDNs based on Max(Real Date)

update MSTR_Jazz_Missing_Real_uploading
set COMPANY_NAME	= b.COMPANY_NAME,
	CUSTOMER_REF	= b.CUSTOMER_REF,
	ACCOUNT_NUMBER	= b.ACCOUNT_NUMBER,
	REAL_DATE		= b.REAL_DATE,
	Activation_Date	= b.Activation_Date,
	TARIFF			= b.TARIFF,
	Customer_Type	= b.Customer_Type,
	Dealer_Code		= b.Dealer_Code,
	ACTIVATION_TYPE	= b.ACTIVATION_TYPE
from MSTR_Jazz_Missing_Real_uploading a,(
									select c.*
									from Real_Duplicate_Missing c,
									(select msisdn,MAX(real_Date)MaxRd
									from Real_Duplicate_Missing
									group by MSISDN )d
									where c.msisdn = d.msisdn
									and c.real_date =d.MaxRd )b
where a.msisdn = b.msisdn 
and a.account_number is null
--Jun0

delete from Real_Duplicate_Missing where Dealer_code is null or Dealer_Code = '' or Dealer_Code = '-'
--Jun0

update MSTR_Jazz_Missing_Real_uploading set dealer_code = 'NA' where dealer_code is null or dealer_code = '' or Dealer_Code = '-'
--Jun0

update MSTR_Jazz_Missing_Real_uploading set dealer_code = 'NA' 
where  DATALENGTH(Dealer_Code) not in(3,4, 5) and Dealer_Code not in ('NA') 
--Jun0

update MSTR_Jazz_Missing_Real_uploading
set Dealer_Code = b.Dealer_code 
from MSTR_Jazz_Missing_Real_uploading a,Real_Duplicate_Missing b
where a.msisdn = b.msisdn
and a.Dealer_code = 'NA'
--Jun0

drop table JazzReal_Temp_Missing
drop table Real_Duplicate_Missing
--

select	'0'+right(MSISDN,10)Sub,Company_Name,Customer_Ref,Account_Number,
	--cast (real_date as date)Real_Date, haris change datetime converterror2622020
	realdate Real_Date,ActDate Activation_Date,Tariff,Customer_Type, Dealer_Code,Activation_type
into JazzReal_Temp_Missing		
from MSTR_Jazz_Missing_Real_uploading
order by Real_Date 
--Jun 7698

--############ Missing Dealer Codes ##############################

update JazzReal_Temp_Missing set Dealer_Code = 'NA' where Dealer_Code = '' 
update JazzReal_Temp_Missing set Dealer_Code = 'NA' where Dealer_Code = '-' 
--(0

-- Update all missing Dealer Codes

Select * from JazzReal_Temp_Missing

update JazzReal_Temp_Missing
set Dealer_Code = b.DC 
from JazzReal_Temp_Missing a,Postpaid_Activation_Log b
where a.Sub = b.Sub
and a.Dealer_Code  != b.DC 
and DATEDIFF(Day, b.Active_Date,a.Activation_Date)< '45'
and DATEDIFF(Day, b.Active_Date,a.Activation_Date)> '-45'
and a.Dealer_Code in ('NA','000','0000','00000')
--and month(b.Active_Date ) in (month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 3, 0)),month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 2, 0)),month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()-12) - 1, 0)),month(GETDATE()-12)) and year(b.Active_Date ) in (year(GETDATE()-12),year(GETDATE()-12)-1) 
and b.Active_Date >= '2021-04-01'

--Jun 165

Update JazzReal_Temp_Missing
SET dealer_code = b.dealercode
from JazzReal_Temp_Missing a, bsdmain b
where a.Sub = b.Sub
and a.dealer_code = 'NA'

Select * from JazzReal_Temp_Missing where dealer_code = 'NA'
Delete from JazzReal_Temp_Missing where dealer_code = 'NA'

--################## Check ################################
--alter table JazzReal_Temp_Missing drop column [Remarks],column Channel, column CAM ,column Region ,column FRC_MBU,column FRC_New_MBU  ,column FRC_New_Region
alter table JazzReal_Temp_Missing add [Remarks] varchar(30),Channel varchar (20), CAM varchar (60),Region varchar(20) , FRC_MBU varchar (15), FRC_New_MBU varchar (30),FRC_New_Region varchar(20);

-- -- Update Remaks which are already reported Real in last 1 years
 update JazzReal_Temp_Missing
set Remarks = '1 Years Real Check'
--select * from JazzReal_Temp_Missing 
where sub in ( select sub from JazzReal_Temp_Missing
			where sub in ( select sub  from Real_Sales_Log_Final 
					where DATEDIFF(Day, real_date,getdate())< '365'  
						) 
			and activation_type like '%FRESH%SALE%')

--Jun 1036

update JazzReal_Temp_Missing
set Remarks = null
where Remarks = '1 Years Real Check'
and sub not in (select sub from club.dbo.bsdmain_Nov21)--closind base -5 month

--Jun 992


update JazzReal_Temp_Missing
set Channel = b.Channel,
	CAM = b.[Emp Name],
	Region=b.REGION 
from JazzReal_Temp_Missing a,ST b --Change last Month ST 
where a.Dealer_Code = b.JazzID  --and len([Emp Name])>40
--Jun 7451

--######### Issue in 3 letter #######

update JazzReal_Temp_Missing
set Channel = b.Channel,
	CAM = b.[Emp Name]
--select *
from JazzReal_Temp_Missing a,ST b --last month
where right(a.Dealer_Code,3) = b.JazzID
and left(a.Dealer_Code,1) = '0'
and a.Channel is null
--0 

update JazzReal_Temp_Missing
set Channel = b.Channel,
	CAM = b.[Emp Name]
from JazzReal_Temp_Missing a,ST b--old than last month
where a.Dealer_Code = right(b.JazzID,3)
and left(b.JazzID,1) = '0'
and a.Channel is null


update JazzReal_Temp_Missing
set Channel = b.Channel,
	CAM = b.[Emp Name],
	Region=b.REGION 
from JazzReal_Temp_Missing a,ST_Jan22 b --Change last Month ST 
where a.Dealer_Code = b.[JazzID]  --and len([Emp Name])>40
and a.CAM is null


--go

update JazzReal_Temp_Missing
set FRC_MBU = b.MBU,
	FRC_New_MBU = b.New_MBU,
	FRC_New_Region = b.New_Region
from JazzReal_Temp_Missing a,FRC_ST b
where a.Dealer_Code = b.SaleID
--and channel is null  -- Not required as per NK instuctions
--Jun 101

update JazzReal_Temp_Missing 
set Channel = 'ES',
	Region = 'FRC'
where FRC_MBU is not null
--Jun 100

-- Update on
update JazzReal_Temp_Missing
set Channel = b.Channel ,
	Region = b.region
from JazzReal_Temp_Missing a,bsdmain b
where a.sub = b.sub
and a.channel is null
--Jun 140

update JazzReal_Temp_Missing
set Channel = b.Channel ,
	Region = b.Region
from JazzReal_Temp_Missing a,BSDMain b
where a.COMPANY_NAME  = b.nlsname
and a.channel is null
--0

--Haris check for ES
update JazzReal_Temp_Missing 
set Channel = 'ES',
	Region = 'FRC'
where Channel is Null 
and Tariff like 'JB%'
--0

----################### Exclude Packs ################################

update JazzReal_Temp_Missing set Remarks = '/Dealer Pack' where tariff = 'Dealer'--0

update JazzReal_Temp_Missing set Remarks = '/ES Standard Pack' where tariff = 'ES Standard' --71
update JazzReal_Temp_Missing set Remarks = '/Official Pack' where tariff = 'Official' --38
update JazzReal_Temp_Missing set Remarks = '/Official Dealer Pack' where tariff = 'Official Dealer' --4
update JazzReal_Temp_Missing set Remarks = '/Official for Testing Pack' where tariff = 'Official for Testing' --18
update JazzReal_Temp_Missing set Remarks = '/Official Special' where tariff = 'Official Special'--0
update JazzReal_Temp_Missing set Remarks = '/Employee' where tariff = 'Employee'
--0
update JazzReal_Temp_Missing set Region = 'Central 1' where Region like '%Central%1%'--694
update JazzReal_Temp_Missing set Region = 'Central 2' where Region like '%Central%2%'--396
update JazzReal_Temp_Missing set Region = 'Central 3' where Region like '%Central%3%'--244
update JazzReal_Temp_Missing set Region = 'Central 4' where Region like '%Central%4%' --111
update JazzReal_Temp_Missing set Region = null where Region like 'null' ----0

Select * from JazzReal_Temp_Missing where remarks is not null and tariff not like '%tracker%'

Select * from real_sales_log_final where Sub = '03004008732'


--Conversion failed when converting date and/or time from character string.
--update JazzReal_Temp_Missing
--set Real_Date ='2020-02-07'
----select *
--from JazzReal_Temp_Missing a, real_sales_log_final b
--where a.Sub ='03018265189' and a.sub=b.sub
--alter table Real_Sales_Log_Final alter column CAM varchar(60)

Set ansi_warnings off

insert into Real_Sales_Log_Final( sub,Company_Name ,Customer_Ref ,Account_Number , Real_Date ,Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,i_Date ,Sources)
select sub, Company_Name ,Customer_Ref ,Account_Number ,cast(Real_Date as date) Real_Date, Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,cast(getdate() as date)i_Date ,'Talha Process'Sources
from JazzReal_Temp_Missing
where Remarks is null
and Sub not in (select sub from Real_Sales_Log_Final 
				where DATEDIFF(Day, real_date,getdate())< '300'
				)
order by Real_Date  


insert into Real_Sales_Log_Final ( sub, Company_Name ,Customer_Ref ,Account_Number ,Real_Date ,Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,i_Date ,Sources)
select sub,Company_Name ,Customer_Ref ,Account_Number ,Real_Date , Activation_Date ,Tariff ,Customer_Type ,Dealer_Code ,Activation_type ,Remarks,Channel,CAM,Region,FRC_MBU ,FRC_New_MBU ,FRC_New_Region ,cast(getdate() as date)i_Date ,'Talha Process'Sources
from JazzReal_Temp_Missing
where Remarks is not null
and Sub not in (select sub from Real_Sales_Log_Final 
				where DATEDIFF(Day, real_date,getdate())< '300'
				and Remarks is not null)
order by Real_Date 
--Jun


--select Sub as MSISDN ,ACCOUNT_NUMBER as AccountID,Dealer_Code , TARIFF as Tariff_Name , Real_Date as Real_Date,Activation_Date as Activation_Date ,COMPANY_NAME ,CAM as DealerName,Region,Channel,FRC_MBU,FRC_New_MBU,FRC_New_Region
--from Real_Sales_Log_Final
update Real_Sales_Log_Final
set Region = channel
where Channel in ('ASC','ADC')and  Region not in ('ASC','ADC')
and Remarks is null
and month(Real_Date)=  month(GETDATE()-12) 
and year(Real_Date)= year(GETDATE()-12) 
--Jun36


--select Sub as MSISDN ,ACCOUNT_NUMBER as AccountID,Dealer_Code , TARIFF as Tariff_Name , Real_Date as Real_Date,Activation_Date ,COMPANY_NAME ,CAM as DealerName,Region,Channel
--from Real_Sales_Log_Final
--update real_sales_log_final
--set remarks ='Activation year not 2020'
--where  Remarks is null and year(activation_date) != '2020'
--and month(Real_Date)= month(GETDATE()-12) and year(Real_Date)= year(GETDATE()-12)

--update real_sales_log_final
--set remarks = null
--where Remarks  ='Activation year not 2020'
--and year(activation_date) != '2020'

--##########################################################################
--###################### Update Real Date ####################################################
select *
from Real_Sales_Log_final
where Real_Date >= '2021-11-01' and Real_Date < '2022-04-01' and i_Date >= '2022-05-01'
and Activation_Type not like '%re%org%'and CAM is not null and Remarks is null
and tariff not like 'Warid%'
and tariff not like 'Sis%'
and tariff not like 'DG%'

update Real_Sales_Log_final
set Actual_Date = Real_Date
	,Real_Date = '2022-05-01'
where Real_Date >= '2022-01-01' and Real_Date <= '2022-04-30' and i_Date >= '2022-06-06'
and Activation_Type not like '%re%org%'and CAM is not null and Remarks is null
and tariff not like 'Warid%'
and tariff not like 'Sis%'
and tariff not like 'DG%'


select * from real_report
where Actual_date is not null
