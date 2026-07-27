# Project 3: SQL Data Analysis

**Tool used:** SQL Server Management Studio (SSMS)

## Objective
Query a retail sales database (1,200 transactions, 14 columns) using SQL to extract business
intelligence around revenue, customer behavior, product demand, marketing performance, and
operational risk.

## Methodology

**Data preparation (in SQL)**
- Replaced 309 NULL `CouponCode` values with `'None'` using `UPDATE`
- Rounded `UnitPrice` and `TotalPrice` to 2 decimal places using `ROUND()` to remove floating-point errors

**Techniques applied**
- `SELECT` with column aliasing
- `WHERE` for row-level filtering
- `GROUP BY` for categorical aggregation
- `ORDER BY` for ranked output
- Aggregate functions: `COUNT`, `SUM`, `AVG`
- `ROUND` / `CONVERT` for numeric precision
- `CASE WHEN` for conditional logic and rate calculations (e.g. cancellation rate %)

Full query file: [`SQL_Queries.sql`](./SQL_Queries.sql)

## Key Findings

**Order volume by product** — fairly balanced across all 7 products (Printer highest at 181 orders, Phone lowest at 156)

**Revenue by product** — Chair generates the highest total revenue despite Printer having more orders, showing Chair's higher price point drives more value per sale. Phone is the weakest performer on both volume and revenue.

**Average order value** — Laptop has the highest average order value per transaction; Phone has the lowest.

**Payment methods** — Credit Card leads in revenue with the highest average order value ($1,127.55). Debit Card generates the lowest revenue.

**Cancellation rate** — Chair has the highest cancellation rate (25.28%) despite being the top revenue product — a significant risk given how much revenue rides on it. Tablet has the lowest.

**Referral source** — Instagram is the strongest acquisition channel; the Referral Program is the weakest.

**Coupon usage** — FREESHIP is the most-used coupon, suggesting customers respond more to free shipping than percentage discounts. 25.75% of orders used no coupon at all.

**Order status** — Cancelled orders represent the single largest revenue category that never converted, outweighing revenue from Delivered orders — flagged as the top operational concern.

## Recommendations
1. Prioritize reducing Chair's cancellation rate (highest revenue product, highest cancellation risk)
2. Review Phone's pricing/positioning — weakest performer across the board
3. Reallocate marketing budget toward Instagram, away from the underperforming Referral Program
4. Expand FREESHIP-style promotions given its strong pull on purchase behavior
5. Build loyalty/cashback incentives targeting Credit Card users (highest AOV segment)
6. Target the 25.75% of customers who never use a coupon with a first-purchase incentive
7. Explore upsell/bundle opportunities for Laptop buyers (highest AOV product)

## Conclusion
The analysis identified cancellations — especially within the Chair category — as the most
urgent threat to revenue, alongside a clear opportunity to double down on Instagram as the top
acquisition channel and rethink Phone's product strategy.

## Skills applied
`SQL` `SSMS` `Data Cleaning (UPDATE, ROUND)` `Aggregation (GROUP BY, COUNT, SUM, AVG)` `CASE WHEN Logic` `Business Insight Reporting`
