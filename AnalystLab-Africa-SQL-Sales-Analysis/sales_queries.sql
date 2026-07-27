USE sales_data;
SHOW TABLES;
DESCRIBE sales_data_sample;

-- Database Setup Notes:
-- This is a single flat/denormalized table (unlike Chinook's relational schema).
-- Each row represents one order line item, combining order info, product info,
-- and customer/shipping info together (no separate normalized tables or foreign keys).
-- This is common in exported sales/reporting data, as opposed to transactional databases.

-- Query 1: Orders with high-value line items, sorted by sales amount
SELECT ORDERNUMBER, CUSTOMERNAME, PRODUCTLINE, SALES, ORDERDATE
FROM sales_data_sample
WHERE SALES > 5000
ORDER BY SALES DESC
LIMIT 10;

-- Query 2: Total and average sales by product line (aggregate + GROUP BY + HAVING)
SELECT PRODUCTLINE, 
       COUNT(*) AS TotalOrders, 
       ROUND(SUM(SALES), 2) AS TotalSales, 
       ROUND(AVG(SALES), 2) AS AvgSales
FROM sales_data_sample
GROUP BY PRODUCTLINE
HAVING COUNT(*) > 50
ORDER BY TotalSales DESC;

-- Query 3: Self-JOIN — compare each order to the average sales of its own product line
SELECT a.ORDERNUMBER, a.PRODUCTLINE, a.SALES, ROUND(b.AvgLineSales, 2) AS AvgLineSales
FROM sales_data_sample a
JOIN (
    SELECT PRODUCTLINE, AVG(SALES) AS AvgLineSales
    FROM sales_data_sample
    GROUP BY PRODUCTLINE
) b ON a.PRODUCTLINE = b.PRODUCTLINE
WHERE a.SALES > b.AvgLineSales
ORDER BY a.SALES DESC
LIMIT 10;

-- Query 4: Subquery — orders priced above the overall average sale
SELECT ORDERNUMBER, CUSTOMERNAME, PRODUCTLINE, SALES
FROM sales_data_sample
WHERE SALES > (SELECT AVG(SALES) FROM sales_data_sample)
ORDER BY SALES DESC
LIMIT 10;

-- Query 5: Window function — rank each customer's orders by sales amount
SELECT CUSTOMERNAME, ORDERNUMBER, SALES,
       RANK() OVER (PARTITION BY CUSTOMERNAME ORDER BY SALES DESC) AS RankWithinCustomer
FROM sales_data_sample
ORDER BY CUSTOMERNAME, RankWithinCustomer
LIMIT 20;

-- Query 6: Top 10 customers by total spend
SELECT CUSTOMERNAME, ROUND(SUM(SALES), 2) AS TotalSpent
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY TotalSpent DESC
LIMIT 10;

-- Query 7: January-to-May revenue comparison across years (fair comparison, since 
-- full-year data isn't available for any year - see date range validation above)
SELECT YEAR_ID, ROUND(SUM(SALES), 2) AS RevenueJanToMay
FROM sales_data_sample
WHERE MONTH_ID BETWEEN 1 AND 5
GROUP BY YEAR_ID
ORDER BY YEAR_ID;

-- Query 8: Revenue by territory
SELECT TERRITORY, COUNT(*) AS TotalOrders, ROUND(SUM(SALES), 2) AS TotalRevenue
FROM sales_data_sample
GROUP BY TERRITORY
ORDER BY TotalRevenue DESC;

-- Query 9: Order status breakdown (how many orders are Shipped, Cancelled, etc.)
SELECT STATUS, COUNT(*) AS OrderCount
FROM sales_data_sample
GROUP BY STATUS
ORDER BY OrderCount DESC;

-- Query 10: Deal size distribution and its average sale value
SELECT DEALSIZE, COUNT(*) AS NumberOfOrders, ROUND(AVG(SALES), 2) AS AvgSaleValue
FROM sales_data_sample
GROUP BY DEALSIZE
ORDER BY AvgSaleValue DESC;

-- Query 11: Top-performing product line by year (window function)
SELECT YEAR_ID, PRODUCTLINE, TotalSales, RankInYear
FROM (
    SELECT YEAR_ID, PRODUCTLINE, ROUND(SUM(SALES),2) AS TotalSales,
           RANK() OVER (PARTITION BY YEAR_ID ORDER BY SUM(SALES) DESC) AS RankInYear
    FROM sales_data_sample
    GROUP BY YEAR_ID, PRODUCTLINE
) ranked
WHERE RankInYear = 1;

CREATE INDEX idx_productline ON sales_data_sample(PRODUCTLINE(50));

-- Query Optimization: Test indexing on a frequently filtered column

-- Step 1: Check query plan without an index
EXPLAIN SELECT * FROM sales_data_sample WHERE PRODUCTLINE = 'Classic Cars';

-- Step 2: Add an index on PRODUCTLINE
CREATE INDEX idx_productline ON sales_data_sample(PRODUCTLINE);

-- Step 3: Re-check the query plan after indexing
EXPLAIN SELECT * FROM sales_data_sample WHERE PRODUCTLINE = 'Classic Cars';

-- Optimization Result: Unlike the Chinook test (which was too small to benefit),
-- indexing PRODUCTLINE here produced a genuine performance improvement. Before
-- indexing: type = ALL (full scan of all 2,755 rows). After indexing: type = ref
-- (MySQL used the index directly), confirming the index was actually applied.
-- This demonstrates that indexing benefits become more pronounced as table size
-- and query selectivity increase.