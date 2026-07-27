# Sales Data: SQL Querying & Optimization

**Program:** AnalystLab Africa Internship — Week 3
**Tool used:** MySQL Workbench

## Objective
Query a denormalized sales reporting dataset (2,755 order line items, 25 columns) to answer
business questions on revenue, customers, product lines, and regions while applying advanced
SQL concepts (self-joins, subqueries, window functions) and testing query optimization via indexing.

## Dataset
`sales_data_sample` a single flat table combining order, product, and customer/shipping details
in one denormalized structure (typical of exported reporting/BI data, unlike a normalized
transactional schema). Key columns: `ORDERNUMBER`, `PRODUCTLINE`, `SALES`, `ORDERDATE`, `STATUS`,
`QTR_ID`/`MONTH_ID`/`YEAR_ID`, `CUSTOMERNAME`, `TERRITORY`, `COUNTRY`, `DEALSIZE`.

## Queries & Key Findings

**Highest-value individual orders**  top order was $14,082.80 (Sharp Gifts Warehouse, Vintage Cars).
7 of the top 10 highest-value orders were Classic Cars or Vintage Cars.

**Revenue by product line** Classic Cars leads decisively: $3.92M total sales from 967 orders,
*and* the highest average order value ($4,053.38) — a clear priority line for investment.

**Self-join: orders above their own product line's average** the top order sold over 4.5× its
product line's average, confirming it as a genuine outlier rather than just a high-volume line effect.

**Subquery: orders above the company-wide average** the same top 10 orders led both this and
the product-line comparison, confirming these are exceptional across the whole business, not just
within their category.

**Window function: customer order ranking** using `RANK() OVER (PARTITION BY CustomerName ...)`
to find each customer's best order individually (e.g. Alpha Cognac's top order was 25%+ higher
than their second-best), enabling account-level analysis rather than one global ranking.

**Top 10 customers by spend** Euro Shopping Channel leads by a wide margin ($912,294.11),
~40% more than the #2 customer.

**Revenue trend across years a data validation catch:** raw yearly totals initially suggested
a sharp decline in 2005. Checking `MIN/MAX(ORDERDATE)` per year revealed each year only had
partial-year data (2003 & 2004 through September, 2005 through May only) making raw totals an
unfair comparison. Recalculating using only the Jan-May window every year shares showed revenue
actually **grew consistently** year over year (2003 → 2004 → 2005)  the opposite conclusion from
the flawed comparison.

**Revenue by territory** EMEA leads ($4.98M, 1,407 orders), followed by NA ($3.85M). APAC and
Japan remain comparatively small markets with room for expansion.

**Order status breakdown**  ~94% of orders shipped successfully, only ~2% cancelled — a
generally healthy fulfillment pipeline.

**Deal size distribution** Large deals average $8,293.75 but only number 157 orders, while
Medium and Small deals together make up over 94% of order volume day-to-day revenue depends
more on consistent smaller deals than occasional large ones.

**Top product line by year (window function)**  Classic Cars ranked #1 in every recorded year
(2003-2005), confirming it as a consistent flagship line rather than a one-time trend.

## Query Optimization
Tested indexing on `PRODUCTLINE` (a frequently filtered column) using `EXPLAIN`:
- First `CREATE INDEX` attempt failed (`Error 1170`)  `PRODUCTLINE` was a `TEXT` column, which
  requires a specified key length, unlike `VARCHAR`. Resolved using `PRODUCTLINE(50)`.
- **Before indexing:** full table scan (`type = ALL`, 2,755 rows examined)
- **After indexing:** MySQL used the index directly (`type = ref`)
- This was a genuine, measurable improvement  unlike an earlier test on a much smaller table,
  showing that indexing benefits scale with table size and query selectivity.

## Files in this project
- [`sales_queries.sql`](./sales_queries.sql) — all 11 queries plus indexing/optimization tests

## Skills applied
`SQL` `MySQL Workbench` `Self-Joins` `Subqueries` `Window Functions (RANK, PARTITION BY)` `Query Optimization (EXPLAIN, Indexing)` `Data Validation` `Business Insight Reporting`
