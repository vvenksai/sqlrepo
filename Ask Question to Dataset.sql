
-- Ask Question to Dataset

select top 10 * from Employee_Attendance
select top 10 * from Employee_Food_Orders
select * from Employee_Events_Holidays

-- 1. Which months, Week, Days of data are given?
select distinct DATENAME(month,date) Months from Employee_Attendance
select count(distinct (DatePart(week,  a.date))) NoOfWeeks from Employee_Attendance a
select count(distinct date) TotalDay from Employee_Attendance

-- 2. Location Wise Distinct Employee
select Location ,count(distinct Employee_ID) as NoOfEmp 
from Employee_Attendance 
group by Location

--3. Pecentage of EMP Working Mode

select Location ,status ,count(distinct Employee_ID) as NoOfEmp 
from Employee_Attendance 
group by Location,status
order by Location,status

--4. How many days,Weeks, Month data available of Food order
select count(distinct Order_Date) TotalDay from Employee_Food_Orders
select distinct DATENAME(month,Order_Date) NoOfMonths from Employee_Food_Orders
select count(distinct (DatePart(week,  a.date))) NoOfWeeks from Employee_Attendance a

--5. Write Query for Week Day Wise predictive Food Order Qty

-- Step 1 : Find Day wise Order Qty Last 3 months(Any One Location)
select o.Location,
o.Order_Date,
o.Item,
count(o.Order_ID) as OrderQty
from Employee_Food_Orders o
Inner join Employee_Attendance a on o.Employee_ID=a.Employee_ID and o.Order_Date=a.Date and a.Status='Present'
left join Employee_Events_Holidays e on o.Order_Date=e.Date and e.Location=o.Location
where o.Location='mumbai'
group by o.Location,o.Order_Date,o.Item
order by o.Location,o.Order_Date,o.Item

-- Step 2 : Find Week Day wise Order Qty Last 3 months
select o.Location,
DATENAME(WEEKDAY, o.Order_Date) As WeekDay,
o.Item,
count(o.Order_ID) as OrderQty

from Employee_Food_Orders o
Inner join Employee_Attendance a on o.Employee_ID=a.Employee_ID and o.Order_Date=a.Date and a.Status='Present'
left join Employee_Events_Holidays e on o.Order_Date=e.Date and e.Location=o.Location
where o.Location='mumbai'
and e.date IS NULL
group by o.Location,o.Order_Date,o.Item
order by o.Location,o.Order_Date,o.Item

--Step 3 : Group wise Week Day  Total Order Qty Last 3 months
select o.Location,
DATENAME(WEEKDAY, o.Order_Date) As WeekDay,
o.Item,
count(o.Order_ID) as OrderQty
from Employee_Food_Orders o
Inner join Employee_Attendance a on o.Employee_ID=a.Employee_ID and o.Order_Date=a.Date and a.Status='Present'
left join Employee_Events_Holidays e on o.Order_Date=e.Date and e.Location=o.Location
where o.Location='mumbai'
and e.date IS NULL
group by o.Location,DATENAME(WEEKDAY, o.Order_Date),o.Item

--Step 4 : Calculate the Avg Predicted Quantity Week Day wise 
Declare @NoOfWeeks Int 
Set @NoOfWeeks=(select count(distinct (DatePart(week,  a.date))) from Employee_Attendance a where Status='Present')
Select Location,WeekDay,Item,
sum(OrderQty /@NoOfWeeks) as AvgQuantity_Predicted
from (
select o.Location,
DATENAME(WEEKDAY, o.Order_Date) As WeekDay,
o.Item,
count(o.Order_ID) as OrderQty
from Employee_Food_Orders o
Inner join Employee_Attendance a on o.Employee_ID=a.Employee_ID and o.Order_Date=a.Date and a.Status='Present'
left join Employee_Events_Holidays e on o.Order_Date=e.Date and e.Location=o.Location
where o.Location='mumbai'
and e.date IS NULL
group by o.Location,DATENAME(WEEKDAY, o.Order_Date),o.Item
)A
group by Location,WeekDay,Item
order by Location,WeekDay


--Step 5 : Create Store Procedure with Input Parameter 
ALTER PROCEDURE Sp_WeeklyFoodQtyPrediction
(
 @TomorrowWeekDay VARCHAR(10)=NULL
,@City VARCHAR(20)
)
AS
BEGIN 
	Declare @NoOfWeeks Int 
	Set @NoOfWeeks=(select count(distinct (DatePart(week,  a.date))) 
	from Employee_Attendance a 
	where Status='Present'
	and a.Location=@City
	)

	Select Location,WeekDay,Item,
	sum(OrderQty /@NoOfWeeks) as AvgQuantity_Predicted
	from (
		select o.Location,
		DATENAME(WEEKDAY, o.Order_Date) As WeekDay,
		o.Item,
		count(o.Order_ID) as OrderQty
		from Employee_Food_Orders o
		Inner join Employee_Attendance a on o.Employee_ID=a.Employee_ID and o.Order_Date=a.Date and a.Status='Present'
		left join Employee_Events_Holidays e on o.Order_Date=e.Date and e.Location=o.Location
		where o.Location=@City
		and e.date IS NULL
		group by o.Location,DATENAME(WEEKDAY, o.Order_Date),o.Item
	)A
	group by Location,WeekDay,Item
	order by Location,WeekDay
END


-- 6. Validate the OutPut

select date ,Location,count(distinct Employee_ID) as NoOfEMP
from Employee_Attendance
where Location='mumbai'
and Status='Present'
group by date,Location
order by date,Location

--Union all 

select Order_Date  ,Location,count(Order_ID) as NoofOrder 
from Employee_Food_Orders
where Location='Mumbai'
and Status='Completed'
group by Order_Date,Location
order by Order_Date,Location
