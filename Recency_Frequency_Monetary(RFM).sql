
USE BigAnalyticsDB;

-- Step 1 --> Calculate RFM metrics per customer
SELECT CustomerID, Recency,
		Frequency, 
		Monetary,
-- 2nd step > Assign NTILE scores(1-5)
    NTILE(5) OVER (ORDER BY Recency DESC) AS R,
    NTILE(5) OVER (ORDER BY Frequency DESC) AS F,
    NTILE(5) OVER (ORDER BY Monetary DESC) AS M,
-- Step 3: Segment customers based on RFM scores
    CASE 
        WHEN NTILE(5) OVER (ORDER BY Recency DESC) >= 4 
             AND NTILE(5) OVER (ORDER BY Frequency DESC) >= 4 
             AND NTILE(5) OVER (ORDER BY Monetary DESC) >= 4 THEN 'VIP'
        WHEN NTILE(5) OVER (ORDER BY Frequency DESC) >= 4 THEN 'Loyal'
        WHEN NTILE(5) OVER (ORDER BY Recency DESC) <= 2 THEN 'At Risk'
        ELSE 'Regular'
    END AS Segment
FROM (
    SELECT 
        CustomerID,
        DATEDIFF(DAY, MAX(OrderDate), GETDATE()) AS Recency,
        COUNT(*) AS Frequency,
        SUM(TotalAmount) AS Monetary
    FROM CleanOrders
    GROUP BY CustomerID
) AS RFM;