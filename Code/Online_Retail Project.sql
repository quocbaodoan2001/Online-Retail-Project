-- Expolre Data Analysis
-- Total records: 541909 
-- 165080 rows have no CustomerID
-- 165080 rows have no CustomerID
-- 406829 have CustomerID
-- Negative UnitPrice: 2 rows
-- 1454 (rows) have no Description information also Null values of CustomerID
-- 397884 rows have Quantity > 0 AND UnitPrice > 0
-- 5195 rows duplicate
-- 392669 rows have been cleand.

USE [Online Retail]
GO
------ Cleaning data
WITH online_retail AS (SELECT InvoiceNo, StockCode, Description,  Quantity,InvoiceDate,UnitPrice, CustomerID, Country
FROM [dbo].[Online Retail]
where CustomerID !=0
)
, quantity_unit_price as (SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0),
dup_check as ( SELECT *, ROW_NUMBER () OVER (PARTITION BY InvoiceNo, StockCode, Quantity ORDER BY InvoiceDate) as dup
FROM quantity_unit_price)
SELECT *
INTO Online_Retail_Data_Cleaned
FROM dup_check
WHERE dup = 1 

-----RESULTS
SELECT *
FROM Online_Retail_Data_Cleaned

--------- Create Cohort_Date
SELECT CustomerID,
		Min(InvoiceDate) as first_purchase_date,
		DATEFROMPARTS (YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)),1) as Cohort_Date
INTO #Corhort
FROM Online_Retail_Data_Cleaned
GROUP BY CustomerID

--- Result: 4338 rows affected to #Cohort
SELECT *
FROM #Corhort

--- Creat Cohort Index

SELECT O2.*,
	   cohort_index = Year_diff * 12 + Month_diff + 1
INTO #Cohort_retention_Analysis 
FROM (
		SELECT O1.*,
			   Year_diff = Invoice_Year - Cohort_Year,
			   Month_diff = Invoice_Month - Cohort_Month
		FROM		
		       (SELECT O.*,C.Cohort_Date,
					   YEAR(O.InvoiceDate) as Invoice_Year,
					   MONTH(O.InvoiceDate) as Invoice_Month,					
					   YEAR(C.Cohort_Date) as Cohort_Year,
					   MONTH(C.Cohort_Date) as Cohort_Month
				FROM Online_Retail_Data_Cleaned O
				LEFT JOIN #Corhort C
				ON O.CustomerID = C.CustomerID
				) O1
	   ) O2

--- Result: 392669 rows affected to Cohort_retention

SELECT *
  FROM #Cohort_retention_Analysis
  WHERE CustomerID = '16378' --- Dùng Distinct thì sẽ chỉ đếm tỷ lệ giữ chân khách hàng mua qua từng tháng chứ không đề cập đến revenue có thể phát triển thêm cái này
--- Pivot to Cohort
 SELECT *
 INTO Cohort_pivot_Analysis
 FROM (SELECT DISTINCT
		CustomerID,
		Cohort_Date,
		cohort_index
FROM #Cohort_retention_Analysis ) AS Table_Data_Pivot
PIVOT (COUNT(CustomerID)
	   FOR cohort_index IN
	 ([1],
      [2],
      [3],
      [4],
      [5],
      [6],
      [7],
      [8],
      [9],
      [10],
      [11],
      [12],
      [13]
		)) as Table_pivot
ORDER BY Cohort_Date;

------ Result Pivot to Cohort
SELECT *
FROM Cohort_pivot_Analysis
ORDER BY Cohort_Date ---Resulting Difference: (Number 8) & (date:1-5-2021) = 27 <> author 26

--- Exchang Resulting to Rate Retentation 
SELECT Cohort_Date, 
		CONCAT(CAST((1.0* [1]/[1] * 100) AS INT), '%')  as [1],
		CONCAT(CAST((1.0* [2]/[1] * 100) AS INT), '%') as [2],
		CONCAT(CAST((1.0* [3]/[1] * 100) AS INT), '%') as [3],
		CONCAT(CAST((1.0* [4]/[1] * 100) AS INT), '%') as [4],
		CONCAT(CAST((1.0* [5]/[1] * 100) AS INT), '%') as [5],
		CONCAT(CAST((1.0* [6]/[1] * 100) AS INT), '%') as [6],
		CONCAT(CAST((1.0* [7]/[1] * 100) AS INT), '%') as [7],
		CONCAT(CAST((1.0* [8]/[1] * 100) AS INT), '%') as [8],
		CONCAT(CAST((1.0* [9]/[1] * 100) AS INT), '%') as [9],
		CONCAT(CAST((1.0* [10]/[1] * 100) AS INT), '%') as [10],
		CONCAT(CAST((1.0* [11]/[1] * 100) AS INT), '%') as [11],
		CONCAT(CAST((1.0* [12]/[1] * 100) AS INT), '%') as [12],
		CONCAT(CAST((1.0* [13]/[1] * 100) AS INT), '%') as [13]
INTO Cohort_Pivot_Table_Percent
FROM Cohort_pivot_Analysis
ORDER BY Cohort_Date
------ RESULTS

SELECT *
FROM Cohort_Pivot_Table_Percent
ORDER BY Cohort_Date

------------------- Ví dụ về tìm số khách hàng mới trong tháng 
WITH Num1 AS (SELECT DISTINCT CustomerID as T1
FROM [dbo].[Online_Retail_Data_Cleaned]
WHERE InvoiceDate between '2011-01-01' and '2011-01-31'),
NUM2 AS (SELECT DISTINCT CustomerID as T2
FROM [dbo].[Online_Retail_Data_Cleaned]
WHERE InvoiceDate between '2010-12-01' and '2010-12-31')

SELECT COUNT(NUM2.T2)
FROM Num1
LEFT JOIN NUM2
ON NUM1.T1 = NUM2.T2
WHERE NUM2.T2 IS NOT NULL

----- New customers and Returning customers
----- Looking for new customers of the months
SELECT YEAR(Cohort_Date) as Year_CohortDate, MONTH(Cohort_Date) Month_CohortDate,[1] as New_Customers
INTO #Cohort4
FROM [dbo].[Cohort_pivot_Analysis] 
order by Cohort_Date
-----RESULTS
SELECT *
FROM #Cohort4
order by Year_CohortDate, Month_CohortDate
----------------- Total Customers of the months
SELECT YEAR(InvoiceDate) as Year_Invoice, MONTH(InvoiceDate) as Month_Invoice, COUNT( DISTINCT CustomerID) Total_Customer_followed_Month_of_the_Year
INTO #Cohort5
FROM [dbo].[Online_Retail_Data_Cleaned]
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year_Invoice, Month_Invoice
----- RESULTS
SELECT *
FROM #Cohort5
ORDER BY Year_Invoice,Month_Invoice 

------ RPR (Repeat Purchase Rate)
SELECT Year_CohortDate,Month_CohortDate,New_Customers,Total_Customer_followed_Month_of_the_Year as Total_Customers
FROM #Cohort4 A
JOIN #Cohort5 B
ON A.Year_CohortDate = B.Year_Invoice AND A.Month_CohortDate = B.Month_Invoice
ORDER BY Year_CohortDate,Month_CohortDate

------- TOP 20 Revenue of all

WITH Rank_Revenue AS (SELECT Country,Year_Invoice ,MAX(Revenue_followed_Country) as high_revenue, ROW_NUMBER() OVER ( order by MAX(Revenue_followed_Country) desc) as ranking_revenue 
FROM [dbo].[Revenue_by_Country]
GROUP BY Country, Year_Invoice
 )
SELECT *
FROM Rank_Revenue
WHERE ranking_revenue <=20

-------Create The Revenue Trend Table

USE [Online Retail]
GO
WITH Revenue_followed_Quarter_and_Country AS (
		SELECT Country,DATEPART(YEAR,InvoiceDate) AS Year_Invoice, 
		DATEPART(QUARTER,InvoiceDate) AS Quater_Invoice, 
		SUM(Revenue) Revenue_followed_Country
FROM (SELECT *, CAST(Quantity * UnitPrice AS INT) as Revenue
FROM Online_Retail_Data_Cleaned ) T5
GROUP BY Country, DATEPART(YEAR,InvoiceDate), DATEPART(QUARTER,InvoiceDate)
),
Previous_Revenue as ( 
			SELECT *, 
			COALESCE(LAG(Revenue_followed_Country) OVER (PARTITION BY Country ORDER BY Year_Invoice, Quater_Invoice),Revenue_followed_Country) AS prev_revenue
FROM Revenue_followed_Quarter_and_Country),
Difference_Revenue_by_Quater_Year as ( 
		SELECT *,
		(Revenue_followed_Country - prev_revenue) * 100/ prev_revenue AS percent_change
FROM Previous_Revenue)
SELECT  Country,
        Quater_Invoice,
        Revenue_followed_Country,
		prev_revenue,
		CASE WHEN Revenue_followed_Country > prev_revenue then percent_change
			 WHEN Revenue_followed_Country < prev_revenue then - percent_change 
			 ELSE 0
			 END as percent_change_signed
FROM Difference_Revenue_by_Quater_Year
ORDER BY Country,Year_Invoice, Quater_Invoice ASC;

---------- Verson 1 khi Revenue_followed_Country dạng INT thì *100 để bên trong

WITH Revenue_followed_Quarter_and_Country AS (
    SELECT 
        Country,
        DATEPART(YEAR, InvoiceDate) AS Year_Invoice,
        DATEPART(QUARTER, InvoiceDate) AS Quater_Invoice,
        SUM(CAST(Quantity * UnitPrice AS INT)) AS Revenue_followed_Country
    FROM Online_Retail_Data_Cleaned
    GROUP BY Country, DATEPART(YEAR, InvoiceDate), DATEPART(QUARTER, InvoiceDate)
),
Previous_Revenue AS (
    SELECT 
        *,
        COALESCE(LAG(Revenue_followed_Country) OVER (PARTITION BY Country ORDER BY Year_Invoice, Quater_Invoice), Revenue_followed_Country) AS prev_revenue
    FROM Revenue_followed_Quarter_and_Country
),
Difference_Revenue_by_Quarter_Year AS (
    SELECT 
        *,
        CAST((Revenue_followed_Country - prev_revenue) AS DECIMAL(18, 2))/ prev_revenue *100 AS percent_change
    FROM Previous_Revenue
)
SELECT  
    Country,
    Quater_Invoice,
    Revenue_followed_Country,
    prev_revenue,
    CASE 
        WHEN percent_change > 0 THEN percent_change
        WHEN percent_change < 0 THEN percent_change
        ELSE 0
    END AS percent_change_signed
FROM Difference_Revenue_by_Quarter_Year
ORDER BY Country, Year_Invoice, Quater_Invoice ASC;
----------- Verson 2 khi Revenue_followed_Country dạng Demical nên *100 không ảnh hưởng (FINAL)
USE [Online Retail]
GO

WITH Revenue_followed_Quarter_and_Country AS (
    SELECT 
        Country,
        DATEPART(YEAR, InvoiceDate) AS Year_Invoice,
        DATEPART(QUARTER, InvoiceDate) AS Quater_Invoice,
        SUM(CAST(Quantity * UnitPrice AS DECIMAL(18,2))) AS Revenue_followed_Country
    FROM Online_Retail_Data_Cleaned
    GROUP BY Country, DATEPART(YEAR, InvoiceDate), DATEPART(QUARTER, InvoiceDate)
),
Previous_Revenue AS (
    SELECT 
        *,
        COALESCE(LAG(Revenue_followed_Country) OVER (PARTITION BY Country ORDER BY Year_Invoice, Quater_Invoice), Revenue_followed_Country) AS prev_revenue
    FROM Revenue_followed_Quarter_and_Country
),
Difference_Revenue_by_Quarter_Year AS (
    SELECT 
        *,
		 Revenue_followed_Country - prev_revenue as Difference_Revenue,
         (Revenue_followed_Country - prev_revenue) / ABS(prev_revenue) * 100 AS percent_change
    FROM Previous_Revenue
)
SELECT  Country, 
		Year_Invoice,
		Quater_Invoice,
		Revenue_followed_Country,
		prev_revenue,
		Difference_Revenue,
		CAST(percent_change
				 AS DECIMAL(18, 1)       
    ) AS percentage_changing_status
INTO The_Revenue_Trends
FROM Difference_Revenue_by_Quarter_Year
ORDER BY Country, Year_Invoice, Quater_Invoice;

-------------The Reslut of Revenue Trends
SELECT *
FROM The_Revenue_Trends
