/*  some core analysis queries  */

USE BigAnalyticsDB;


-- 1. Customer Lifetime Value
SELECT CustomerID, SUM(TotalAmount) AS LifetimeValue
FROM CleanOrders
GROUP BY CustomerID
ORDER BY LifetimeValue DESC;
------------------------------------------------


-- 2. Average Order Value

SELECT AVG(TotalAmount) AS AvgOrderValue
FROM CleanOrders;
-----_________________----------------_____________---


-- 3. Repeat vs One-time
SELECT 
    CASE 
        WHEN COUNT(OrderID) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS CustomerType,
    COUNT(*) AS TotalCustomers
FROM CleanOrders
GROUP BY CustomerID;
--________________--------------________________-----------


-- 4. Cancellation Rate
SELECT 
    COUNT(CASE WHEN Status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*) AS CancellationRate
FROM CleanOrders;

--_______________----------------_______________---------


-- 5. Detect high-value outliers
SELECT * FROM CleanOrders
WHERE TotalAmount > (SELECT AVG(TotalAmount) * 3 FROM CleanOrders);