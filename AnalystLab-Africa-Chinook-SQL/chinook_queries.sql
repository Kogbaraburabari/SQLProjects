USE chinook;

SHOW TABLES;
-- Schema relationships overview:
-- Artist (1) -> Album (many): one artist has many albums
-- Album (1) -> Track (many): one album has many tracks
-- Genre (1) -> Track (many), MediaType (1) -> Track (many)
-- Customer (1) -> Invoice (many): one customer has many invoices
-- Invoice (1) -> InvoiceLine (many): one invoice has many line items
-- Track (1) -> InvoiceLine (many): a track can appear in many invoice lines
-- Playlist (many) <-> Track (many) via PlaylistTrack (junction table)
-- Employee (1) -> Customer (many): employees support customers

DESCRIBE Track;

-- Query 1: Find all tracks longer than 5 minutes, sorted by length
SELECT Name, Milliseconds, UnitPrice
FROM Track
WHERE Milliseconds > 300000
ORDER BY Milliseconds DESC
LIMIT 10;

-- Query 2: Find genres with more than 100 tracks, showing average track length
SELECT g.Name AS Genre, COUNT(t.TrackId) AS TotalTracks, AVG(t.Milliseconds) AS AvgLengthMs
FROM Track t
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
HAVING COUNT(t.TrackId) > 100
ORDER BY TotalTracks DESC;

-- Query 3: List all customers and their total number of invoices (LEFT JOIN keeps customers with 0 invoices too)
SELECT c.FirstName, c.LastName, c.Country, COUNT(i.InvoiceId) AS TotalInvoices
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY TotalInvoices DESC
LIMIT 10;

-- Query 4: Find tracks priced above the average track price (subquery)
SELECT Name, UnitPrice
FROM Track
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Track)
ORDER BY UnitPrice DESC
LIMIT 10;

-- Query 5: Rank customers by total spend within each country
SELECT c.FirstName, c.LastName, c.Country, SUM(i.Total) AS TotalSpent,
       RANK() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS RankInCountry
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY c.Country, RankInCountry
LIMIT 20;

-- Query 6: Top 10 best-selling tracks by revenue
SELECT t.Name AS Track, SUM(il.UnitPrice * il.Quantity) AS Revenue, SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.Name
ORDER BY Revenue DESC
LIMIT 10;

-- Query 7: Monthly revenue trend
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month, SUM(Total) AS MonthlyRevenue
FROM Invoice
GROUP BY Month
ORDER BY Month;

-- Query 8: Average order value by country
SELECT BillingCountry, COUNT(InvoiceId) AS TotalOrders, ROUND(AVG(Total), 2) AS AvgOrderValue
FROM Invoice
GROUP BY BillingCountry
ORDER BY AvgOrderValue DESC
LIMIT 10;

-- Query 9: Revenue by genre
SELECT g.Name AS Genre, SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY Revenue DESC
LIMIT 10;

-- Query 10: Revenue generated per employee (via the customers they support)
SELECT e.FirstName, e.LastName, e.Title, SUM(i.Total) AS RevenueGenerated
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName, e.Title
ORDER BY RevenueGenerated DESC;

-- Query 11: Classify customers as repeat vs one-time buyers
SELECT
    CASE WHEN InvoiceCount > 1 THEN 'Repeat Customer' ELSE 'One-Time Customer' END AS CustomerType,
    COUNT(*) AS NumberOfCustomers
FROM (
    SELECT CustomerId, COUNT(InvoiceId) AS InvoiceCount
    FROM Invoice
    GROUP BY CustomerId
) AS CustomerInvoiceCounts
GROUP BY CustomerType;

-- Query 12: Top 10 artists by units sold
SELECT ar.Name AS Artist, SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY UnitsSold DESC
LIMIT 10;

-- Query 13: Track each customer's purchase order sequence (1st, 2nd, 3rd purchase, etc.)
SELECT c.FirstName, c.LastName, i.InvoiceDate, i.Total,
       ROW_NUMBER() OVER (PARTITION BY c.CustomerId ORDER BY i.InvoiceDate) AS PurchaseSequence
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
ORDER BY c.CustomerId, PurchaseSequence
LIMIT 20;

-- Query Optimization: Demonstrate performance improvement with indexing

-- Step 1: Check how MySQL executes a filter on InvoiceDate without an index
EXPLAIN SELECT * FROM Invoice WHERE InvoiceDate > '2023-01-01';

-- Step 2: Add an index on InvoiceDate to speed up date-based filtering
CREATE INDEX idx_invoice_date ON Invoice(InvoiceDate);

-- Step 3: Re-check the query plan after adding the index
EXPLAIN SELECT * FROM Invoice WHERE InvoiceDate > '2023-01-01';

-- Optimization Result: Adding an index on InvoiceDate made it available as an option
-- (visible in 'possible_keys'), but MySQL's optimizer still chose a full table scan
-- since the Invoice table only has 412 rows — too small for an index to provide real
-- benefit. Indexing typically shows measurable performance gains on much larger tables
-- (thousands to millions of rows), which is why this optimization would matter more
-- in production-scale data than in this sample dataset.