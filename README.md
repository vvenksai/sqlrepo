# Food Quantity Prediction Analysis Using SQL

## Project Overview

### Purpose
The purpose of this project is to develop a predictive analytics model that forecasts daily food quantity requirements for an office canteen based on historical employee attendance and food order data. This will help optimize food procurement, reduce wastage, and improve cost efficiency.

### Project Background
In PSL IT Company, after the COVID-19 pandemic, the working environment transitioned to a hybrid model where employees work 2 days from the office and 3 days from home out of a 5-day workweek. This hybrid setup created a challenge for the company's canteen operations, as it became difficult to accurately estimate how many employees would be present in the office on any given day to prepare appropriate food quantities.

Due to inaccurate forecasting, the canteen either over-prepared or under-prepared food, resulting in increased food wastage, cost inefficiencies, and employee dissatisfaction. To address this, the Food Quantity Prediction Analysis project was initiated.

Using historical data from the last 3 months, including employee attendance and food order history, the system aims to predict the quantity of Veg and Non-Veg meals required for each day of the week, location-wise.

Example Output:
- If Day = Monday and Location = Mumbai, predict:
  - Veg Meals Required = 120
  - Non-Veg Meals Required = 80

The project includes generating SQL scripts and Power BI visuals for graphical representation of daily food quantity requirements from Monday to Friday.

### Business Objectives
- Improve the accuracy of food demand prediction.
- Reduce food waste and optimize inventory.
- Ensure employee satisfaction by maintaining adequate food availability.
- Improve vendor coordination by providing predictive demand insights.

### Scope
- Collect and analyze employee attendance and food order data.
- Develop a machine learning model to predict food quantity requirements.
- Provide real-time dashboards and reports for decision-making.
- Integrate with the existing canteen management system.

## Key Stakeholders
- HR Department: Provides employee attendance data.
- Canteen Manager: Manages daily food orders and monitors demand.
- Data Science Team: Develops predictive models for food demand.
- IT Team: Ensures data integration and system implementation.
- Food Vendors: Adjusts supply based on predictions.

## Functional Requirements
1. The system should collect daily employee attendance data.
2. The system should track canteen food order details.
3. The model should predict food demand based on historical trends.
4. The system should provide a dashboard with predictive insights.
5. Alerts should be generated for unusual demand variations.

## Data Requirements
### Data Sources
- Employee attendance records
- Canteen food order history
- Public holiday and festival data

### Data Attributes
- Employee ID: Unique identifier for employees
- Date: Date of attendance or food order
- Attendance Status: Present, Absent, Work From Home, etc.
- Food Order Status: Completed, Canceled, etc.
- Item Type: Veg, Non-Veg food ordered
- Quantity Ordered: Number of items ordered per employee

## Technical Requirements
- Database: MS SQL Server for data storage
- Machine Learning: Python (Pandas, Scikit-Learn) for predictive modeling
- Visualization: Power BI or Tableau for dashboards
- API Integration: REST API for real-time data updates (optional)

## Risks and Mitigation
| Risk | Mitigation Strategy |
| --- | --- |
| Data Inconsistency | Implement data validation and cleaning processes |
| Prediction Accuracy | Use advanced ML models and refine based on feedback |
| System Downtime | Ensure high availability with cloud-based deployment |

## Success Criteria
- At least 90% accuracy in food demand prediction
- Reduction in food wastage by 20% within six months
- Improved employee satisfaction in food availability surveys

## SQL Script for Data Prediction
```sql
ALTER PROCEDURE Sp_WeeklyFoodQtyPrediction
(
 @City VARCHAR(20),
 @TomorrowWeekDay VARCHAR(10)=NULL
)
AS
BEGIN
    DECLARE @NoOfWeeks INT
    SET @NoOfWeeks = (
        SELECT COUNT(DISTINCT (DATEPART(WEEK, a.date)))
        FROM Employee_Attendance a
        WHERE Status = 'Present'
        AND a.Location = @City
        AND DATENAME(WEEKDAY, a.date) = @TomorrowWeekDay
    )

    SELECT Location, WeekDay, Item,
           SUM(OrderQty / @NoOfWeeks) AS AvgQuantity_Predicted
    FROM (
        SELECT o.Location,
               DATENAME(WEEKDAY, o.Order_Date) AS WeekDay,
               o.Item,
               COUNT(o.Order_ID) AS OrderQty
        FROM Employee_Food_Orders o
        INNER JOIN Employee_Attendance a ON o.Employee_ID = a.Employee_ID AND o.Order_Date = a.Date AND a.Status = 'Present'
        LEFT JOIN Employee_Events_Holidays e ON o.Order_Date = e.Date AND e.Location = o.Location
        WHERE o.Location = @City
        AND DATENAME(WEEKDAY, a.date) = @TomorrowWeekDay
        AND e.date IS NULL
        GROUP BY o.Location, DATENAME(WEEKDAY, o.Order_Date), o.Item
    ) A
    GROUP BY Location, WeekDay, Item
    ORDER BY Location, WeekDay;
END
```

## Project Output
PSL Canteen Food Qty Prediction - Monday
| AvgQuantity_Predicted |
| --- |
| 24.5 |
| 24 |
| 23.5 |
| 23 |
| 22.5 |

## Approval & Sign-Off
| Name | Designation | Signature | Date |
| --- | --- | --- | --- |
| | | | |
