USE BigAnalyticsDB;

-- 1. Top customers per country{Window function}
SELECT *
FROM (
    SELECT 
        c.Country,
        o.CustomerID,
        sum(o.TotalAmount) as Revenue,
        rank() OVER (PARTITION BY c.Country order by sum(o.TotalAmount) Desc) As rnk
    FROM CleanOrders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY c.Country, o.CustomerID
) t
WHERE rnk <= 3;



-- 2. Running revenue trend(Daily)
SELECT OrderDate,
    SUM(TotalAmount) OVER (ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningRevenue
FROM CleanOrders;


-- 3. High value orders(Top 10% instead of 5%)
WITH Threshold 
AS ( SELECT TOP 1 
         PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY TotalAmount) 
        OVER() AS Value
    FROM CleanOrders)
SELECT *
FROM CleanOrders
WHERE TotalAmount >= (SELECT Value FROM Threshold);


-- 4. Customer activity(customer retention)
------------------------------------------------
SELECT CustomerID,
    Count(Distinct FORmat(OrderDate,'yyyy-MM')) as ActiveMonths
from CleanOrders
Group by CustomerID
ORDER by ActiveMonths DESC;


-- 5. Profit per Order
-- Assuming cost = 70% of revenue per order

SELECT OrderID, CustomerID, TotalAmount AS Revenue,

    TotalAmount * 0.7 as Cost,
    TotalAmount * 0.3 as Profit
from CleanOrders;


-- 6. Average profit per customer 
select CustomerID,
    AVG(TotalAmount * 0.3) As AvgProfit
From CleanOrders
Group BY CustomerID
ORDER BY AvgProfit DESC;


-- 7. Product sales distribution(%)
SELECT p.ProductName,
    SUM(o.Quantity) AS TotalSold,
    ROUND(SUM(o.Quantity) * 100.0 / SUM(SUM(o.Quantity)) OVER(),2) AS PercentOfTotal
FROM CleanOrders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY PercentOfTotal DESC;



-- 8. Repeat Purchase Rate//(FIXED LOGIC)
Select 
    COUNT(CASE WHEN Orders > 5 Then 1 END) * 100.0 / COUNT(*) AS RepeatRate
FROM (
    SELECT CustomerID, COUNT(*) AS Orders
    From CleanOrders
    GROUp by CustomerID
) t;


-- 9. Monthly revenue +Growth
------------------------------------------------
WITH MonthlyRevenue AS (
    Select
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(TotalAmount) AS Revenue
    FROM CleanOrders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT year, month, Revenue,
    Round(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year, Month)) 
        * 100.0 / NULLIF(LAG(Revenue) over (order by Year, Month),0)
    ,2) as GrowthPercent
FROM MonthlyRevenue
ORDER BY Year, Month;



-- 10. Category performance
SELECT p.Category,
    Sum(o.TotalAmount) AS Revenue,
    Sum(o.Quantity) AS Quantity,
    Avg(o.TotalAmount / NULLIF(o.Quantity,0)) as AvgPrice
From CleanOrders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP by p.Category
ORDER BY Revenue DESC;


-- 11. Cancellation Rate by Category
------------------------------------------------
SELECT p.Category,
    ROUND(
        COUNT(CASE WHEN o.Status = 'Cancelled' THEN 1 END) * 100.0 
        / COUNT(*)
    ,2) AS CancelRate
FROM CleanOrders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.Category;



-- 12. New vs Returning Customers//(FIXED LOGIC)
-- Based on LAST 3 MONTHS
WITH CustomerOrders AS (
    SELECT 
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate,
        MAX(OrderDate) AS LastOrderDate
    FROM CleanOrders
    GROUP BY CustomerID
)
SELECT 
    CASE 
        WHEN FirstOrderDate >= DATEADD(MONTH,-3,GETDATE()) THEN 'New'
        ELSE 'Returning'
    END AS CustomerType,
    COUNT(*) AS TotalCustomers
FROM CustomerOrders
GROUP BY 
    CASE 
        WHEN FirstOrderDate >= DATEADD(MONTH,-3,GETDATE()) THEN 'New'
        ELSE 'Returning'
    END;


