--DATA_CLEANING_SECTION---
/*  GOALS:
   - Fix data types
   - Handle bad data
   - Create clean table
*/

-- Creating a  CleanOrders table
SELECT o.OrderID, o.CustomerID, o.ProductID,
    -- Here im fixing the date(the invalid becomes NULL)
    TRY_CAST(o.OrderDate AS DATE) as OrderDate,
    -- For replaciing NULL quantity with 0
    ISNULL(o.Quantity, 0) as Quantity,

    -- Fixing TotalAmount (from text -> decimal)
    TRY_CAST(o.TotalAmount AS decimal(10,2)) as TotalAmount, o.Status
into CleanOrders
from Orders o
where try_cast(o.OrderDate AS date) IS NOT NULL;

select * from CleanOrders  ----Here im checking if the table is successfully created and made the required fixes.
--______________________________________________________________________________________________________________________--


---Data quality report (from the  RAW data)
SELECT 
    count(*) as TotalRows,
    Count(case when try_cast(OrderDate as date) IS NULL then 1 end) AS BadDates,
    count(Case when try_cast(TotalAmount as decimal(10,2)) IS NULL then 1 end) as BadAmounts
FROM Orders;
/*Total count of all rows in the orders table irregardless of good or bad, And shows how many have invalid OrderDate or TotalAmount values.*/
--__________________________________________________________________________________________________________________________


--- Advanced Data Quality Check (clean table)----

SELECT 
    COUNT(*) AS Total,
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS MissingQty,
    COUNT(CASE WHEN TotalAmount IS NULL THEN 1 END) AS MissingAmount,
    COUNT(CASE WHEN OrderDate IS NULL THEN 1 END) AS MissingDate
FROM CleanOrders;

/*It counts all rows in CleanOrders and shows how many have missing Quantity, TotalAmount, or OrderDate values.*/