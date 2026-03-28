-- Here im joining all tables.
SELECT 
    c.Country,
    p.Category,
    o.*
FROM CleanOrders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID;