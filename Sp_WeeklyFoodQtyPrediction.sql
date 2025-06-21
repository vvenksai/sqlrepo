
-- Step 1 : Find Day wise Order Qty Last 3 months
--Exec Sp_WeeklyFoodQtyPrediction 'Mumbai','Monday'
ALTER PROCEDURE Sp_WeeklyFoodQtyPrediction
(
 @City VARCHAR(20)
,@TomorrowWeekDay VARCHAR(10)=NULL

)
AS
BEGIN 
	Declare @NoOfWeeks Int 
	Set @NoOfWeeks=(select count(distinct (DatePart(week,  a.date))) 
	from Employee_Attendance a 
	where Status='Present'
	and a.Location=@City
	and DATENAME(WEEKDAY, a.date)=@TomorrowWeekDay
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
		and DATENAME(WEEKDAY, a.date)=@TomorrowWeekDay
		and e.date IS NULL
		group by o.Location,DATENAME(WEEKDAY, o.Order_Date),o.Item
	)A
	group by Location,WeekDay,Item
	order by Location,WeekDay
END