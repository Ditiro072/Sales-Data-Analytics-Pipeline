/* 
   Stored proceducers for Business logic purposes
*/

USE BigAnalyticsDB;

-- 1. Total Revenue
Create Procedure procedure_TotalRevenue as
BEGIN
    SELECT SUM(TotalAmount) as TotalRevenue
   from CleanOrders;
END;

EXECUTE procedure_TotalRevenue;
---similar to the revenue view in Views.sql


-- 2. Top 10 products
CREATE PROCEDURE procedure_TopProducts AS
BEGIN
    SELECT TOP 10 
        p.ProductName,
        SUM(o.Quantity) AS Sold
    FROM CleanOrders o
    JOIN Products p ON o.ProductID = p.ProductID
    GROUP BY p.ProductName
    ORDER BY Sold DESC;
END;

Exec procedure_TopProducts;



-- 3. Revenue by category
CREATE PROCEDURE procedure_RevenueByCategory
AS
begin
    select p.Category, SUM(o.TotalAmount) as Revenue
    from  CleanOrders o
    Join Products p ON o.ProductID = p.ProductID
    GROUP BY p.Category
    ORDER BY Revenue DESC;
END;

EXEC procedure_RevenueByCategory