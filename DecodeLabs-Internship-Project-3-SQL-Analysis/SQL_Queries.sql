SELECT *
FROM Dataset_for_Data_Analytics


UPDATE Dataset_for_Data_Analytics
SET CouponCode = 'None'
WHERE CouponCode IS NULL


UPDATE Dataset_for_Data_Analytics
SET UnitPrice = ROUND(UnitPrice, 2)


UPDATE Dataset_for_Data_Analytics
SET TotalPrice = ROUND(TotalPrice, 2)


SELECT OrderID, Product, Quantity, UnitPrice, TotalPrice
FROM Dataset_for_Data_Analytics
ORDER BY TotalPrice DESC


SELECT OrderID, Product, Quantity, TotalPrice, OrderStatus
FROM Dataset_for_Data_Analytics
WHERE OrderStatus = 'DELIVERED'
ORDER BY TotalPrice DESC


SELECT Product, COUNT(*) AS TotalOrders
FROM Dataset_for_Data_Analytics
GROUP BY Product
ORDER BY TotalOrders DESC


SELECT Product, 
       SUM(TotalPrice) AS TotalRevenue
FROM Dataset_for_Data_Analytics
GROUP BY Product
ORDER BY TotalRevenue DESC


SELECT Product,
       ROUND (AVG(TotalPrice), 2) AS AverageOrderValue
FROM Dataset_for_Data_Analytics
GROUP BY Product
ORDER BY AverageOrderValue DESC


SELECT PaymentMethod,
       COUNT(*) AS TotalOrders,
       ROUND (SUM(TotalPrice), 2) AS TotalRevenue,
       ROUND (AVG(TotalPrice),2) AS AverageOrderValue
FROM Dataset_for_Data_Analytics
GROUP BY PaymentMethod
ORDER BY TotalRevenue DESC


SELECT Product,
       COUNT(*) AS TotalOrders,
       SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
       ROUND(CONVERT(FLOAT, SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END)) * 100 / COUNT(*), 2) AS CancellationRatePercent
FROM Dataset_for_Data_Analytics
GROUP BY Product
ORDER BY CancellationRatePercent DESC


SELECT ReferralSource,
       COUNT(*) AS TotalOrders,
       ROUND(SUM(TotalPrice), 2) AS TotalRevenue,
       ROUND(CONVERT(FLOAT, COUNT(*)) * 100 / 1200, 2) AS PercentageOfOrders
FROM Dataset_for_Data_Analytics
GROUP BY ReferralSource
ORDER BY TotalRevenue DESC


SELECT CouponCode,
       COUNT(*) AS TotalOrders,
       ROUND(SUM(TotalPrice), 2) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM Dataset_for_Data_Analytics
GROUP BY CouponCode
ORDER BY TotalRevenue DESC


SELECT OrderStatus,
       COUNT(*) AS TotalOrders,
       ROUND(SUM(TotalPrice), 2) AS TotalRevenue,
       ROUND(AVG(TotalPrice), 2) AS AvgOrderValue,
       ROUND(CONVERT(FLOAT, COUNT(*)) * 100 / 1200, 2) AS PercentageOfTotal
FROM Dataset_for_Data_Analytics
GROUP BY OrderStatus
ORDER BY TotalRevenue DESC