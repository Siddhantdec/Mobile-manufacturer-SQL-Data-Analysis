--SQL Advance Case Study


--Q1--BEGIN 

select distinct L.State from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_LOCATION] as L
on F.IDLocation = L.IDLocation
inner join [dbo].[DIM_DATE] as D
on D.Date = F.Date
where year(D.Date) > 2004






--Q1--END

--Q2--BEGIN
	
select top 1(L.State),count(F.IDCustomer) as No_of_phones_sold from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_LOCATION] as L
on F.IDLocation = L.IDLocation
inner join [dbo].[DIM_MODEL] as M
on M.IDModel = F.IDModel
inner join [dbo].[DIM_MANUFACTURER] as MF
on MF.IDManufacturer = M.IDManufacturer
where Country = 'US' and MF.Manufacturer_Name = 'Samsung'
group by L.State





--Q2--END

--Q3--BEGIN      
	
select L.State, L.ZipCode, F.IDModel,count(F.IDCustomer) as No_of_transactions from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_MODEL] as M
on F.IDModel = M.IDModel
inner join [dbo].[DIM_LOCATION] as L
on L.IDLocation = F.IDLocation
group by L.Zipcode,L.State, F.IDModel







--Q3--END

--Q4--BEGIN

select top 1 (MF.Manufacturer_Name)as Cheapest_cellphone,
M.IDModel,Unit_price from [dbo].[DIM_MODEL] as M
inner join [dbo].[DIM_MANUFACTURER] as MF
on MF.IDManufacturer = M.IDManufacturer
order by Unit_price





--Q4--END

--Q5--BEGIN

select MF.Manufacturer_Name,M.Model_Name,
avg(F.TotalPrice) as Average_price from [dbo].[DIM_MODEL] as M
inner join [dbo].[DIM_MANUFACTURER] as MF
on M.IDManufacturer = MF.IDManufacturer
inner join [dbo].[FACT_TRANSACTIONS] as F
on F.IDModel = M.IDModel
where not MF.Manufacturer_Name = 'HTC'
group by MF.Manufacturer_Name,M.Model_Name
order by Average_price desc

select top 5(MF.Manufacturer_Name),count(F.IDCustomer)as Sales_Quantity from [dbo].[DIM_MODEL] as M
inner join [dbo].[DIM_MANUFACTURER] as MF
on M.IDManufacturer = MF.IDManufacturer
inner join [dbo].[FACT_TRANSACTIONS] as F
on F.IDModel = M.IDModel
group by  MF.Manufacturer_Name
order by Sales_Quantity desc







--Q5--END

--Q6--BEGIN

select C.Customer_Name,avg(TotalPrice) as Average_price from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_CUSTOMER] as C
on F.IDCustomer = C.IDCustomer
inner join [dbo].[DIM_DATE] as D
on D.Date = F. Date
where year(D.date) = 2009 
group by C.Customer_Name
having avg(TotalPrice) > 500
order by Average_price desc







--Q6--END
	
--Q7--BEGIN  
	
with ABCD
as(select F.IDModel,year(F.Date) as Years,sum(Quantity)as Quantity_of_phones,
Row_number() over (partition by year(F.Date) order by sum(Quantity) desc) as Ranks
from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_MODEL] as M
on M.IDModel = F.IDModel
where year(F.Date) in (2008,2009,2010) 
group by F.IDModel,year(F.Date)
)
select * from ABCD
where Ranks < 6








--Q7--END	
--Q8--BEGIN

with XYZ
as (select MF.Manufacturer_Name,year(F.Date) as Years,sum(TotalPrice)as Net_Sales,
Rank() over (partition by year(F.Date) order by sum(TotalPrice) desc) as Ranks
from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_MODEL] as M 
on F.IDModel = M.IDModel
inner join [dbo].[DIM_MANUFACTURER] as MF
on MF.IDManufacturer = M.IDManufacturer
where year(F.Date) in (2009,2010)
group by  MF.Manufacturer_Name,year(F.Date) 
)
select * from XYZ
WHERE Ranks = 2
















--Q8--END
--Q9--BEGIN
	
with SID
as (select MF.Manufacturer_Name,Year(F.Date) as Years,count(F.IDCustomer) as No_of_customers, 
Row_number() over(partition by Year(F.Date) order by count(F.IDCustomer) desc) as Rows_number
from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_MODEL] as M 
on F.IDModel = M.IDModel
inner join [dbo].[DIM_MANUFACTURER] as MF
on MF.IDManufacturer = M.IDManufacturer
where Year(F.Date) in (2009,2010) 
group by MF.Manufacturer_Name,Year(F.Date)
)
select Manufacturer_Name from SID
group by Manufacturer_Name
having not count(Manufacturer_Name) = 2








--Q9--END

--Q10--BEGIN

with New_table 
as(select C.IDCustomer,year(Date) as Years,
avg(Quantity) as Average_Quantity,avg(TotalPrice) as Average_Spend,
Lag(avg(TotalPrice),1,null) over (partition by C.IDCustomer order by C.IDCustomer,year(Date))as New_column 
from [dbo].[FACT_TRANSACTIONS] as F
inner join [dbo].[DIM_CUSTOMER]as C
on F.IDCustomer = C.IDCustomer
group by C.IDCustomer,year(Date))
select *,((Average_Spend/New_column)-1)*100 as Percentage_change from New_table






















--Q10--END
	