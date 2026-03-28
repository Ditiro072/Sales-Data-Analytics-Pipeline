/* For the puspose of reusing queries*/
USE BigAnalyticsDB;

-- Base Sales View
CREATE VIEW view_Sales AS
select 
    o.OrderID,
    o.OrderDate,
    o.Quantity,
    o.TotalAmount,
    o.Status,
    c.Country,
    p.ProductName,
    p.Category
from CleanOrders o
join Customers c ON o.CustomerID = c.CustomerID
Join Products p ON o.ProductID = p.ProductID;

select * from view_Sales
--___________________________________________________________--

-- Revenue View
create view view_Revenue as
select sum(TotalAmount) as TotalRevenue
from CleanOrders;

select * from view_Revenue
--_____________________________________________________________________--


-- Revenue by Country
CREATE VIEW view_RevenueByCountry AS
SELECT 
    c.Country,
    SUM(o.TotalAmount) AS Revenue
FROM CleanOrders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Country;

SELECT * FROM view_RevenueByCountry;
--______________________________________________-


-- Monthly Trends
CREATE VIEW view_MonthlyTrends AS
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(TotalAmount) AS Revenue
FROM CleanOrders
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

Select * FROM view_MonthlyTrends