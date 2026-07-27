# Chinook Music Store: SQL Querying & Business Analysis

**Program:** AnalystLab Africa Internship — Week 3
**Tool used:** MySQL Workbench

## Objective
Query the Chinook database a fully relational music store schema (11 tables) to answer
real business questions on sales, customers, genres, and artists, while applying joins,
subqueries, and window functions.

## Dataset
Chinook Database: `Album`, `Artist`, `Customer`, `Employee`, `Genre`, `Invoice`, `InvoiceLine`,
`MediaType`, `Playlist`, `PlaylistTrack`, `Track`.

**Key relationships:** Artist → Album → Track (one-to-many chain) · Genre/MediaType → Track ·
Customer → Invoice → InvoiceLine · Employee → Customer (support rep) · Playlist ↔ Track
(many-to-many via `PlaylistTrack`).

## Queries & Key Findings

**Longest tracks reveal a data quirk** the longest "tracks" run 40-90+ minutes (e.g. one at
88 minutes), revealing these are actually full TV episodes stored in the same table as songs —
an important structural detail before treating every row as a "song."

**Genre catalog depth vs. length** Rock dominates the catalog (1,297 tracks, more than double
the next genre, Latin at 579). Metal has the longest average track length (~5.2 min) despite a
smaller catalog.

**LEFT JOIN for complete customer counts** used `LEFT JOIN` instead of `INNER JOIN` so
customers with zero invoices still appear (with a count of 0) rather than being silently
excluded important for correctly identifying inactive customers.

**Subquery: above-average priced tracks** dominated by the same TV episodes from Query 1,
confirming the dataset mixes media types under one pricing model a useful check before any
pricing analysis.

**Window function: customer rank by country** `RANK() OVER (PARTITION BY Country ...)` gives
each country its own #1 spender rather than one global ranking, enabling fair, localized
customer analysis.

**Top-selling tracks reveal a long tail** even the #1 track by revenue earned under $5 (5
units sold). No single track dominates; revenue is spread thinly across thousands of tracks,
meaning catalog-wide marketing would outperform promoting a handful of "top sellers."

**Monthly revenue is remarkably stable** holding close to a steady baseline across 60 months
with only minor spikes/dips, suggesting a stable subscriber-like base rather than seasonal or
viral demand.

**Average order value by country** Chile has the highest average order value but only 7 total
orders, while the USA leads in volume (91 orders) at a lower average a reminder that a high
average can come from a small, non-scalable customer base rather than a reliable revenue driver.

**Revenue by genre concentrates around Rock** Rock leads revenue by a wide margin, more than
double the next genre unlike the long-tail pattern at the individual-track level, genre-level
demand does concentrate meaningfully, making Rock the clear priority for genre-based promotions.

**Revenue per support employee** fairly evenly spread across the three reps (within ~$113 of
each other), suggesting balanced account workload rather than concentration under one person.

**100% repeat-buyer rate** every customer in the dataset is classified as a repeat buyer. A
strong signal on its face, but likely reflects how the sample dataset was generated rather than
real-world behavior a reminder to sanity-check whether patterns reflect genuine behavior or
the dataset's construction before drawing conclusions.

**Top artists by units sold** Iron Maiden leads by a wide margin, but didn't appear among the
top individual tracks by revenue showing their strength comes from consistent volume across
many tracks rather than one standout hit, relevant for licensing value assessments.

**Customer purchase sequence** `ROW_NUMBER() OVER (PARTITION BY CustomerId ...)` assigns each
customer's purchases a running sequence (1st, 2nd, 3rd...), the foundation for cohort analysis
or time-between-purchases metrics.

## Query Optimization
Tested indexing on `InvoiceDate`:
- **Before indexing:** full table scan (`type = ALL`, 412 rows examined)
- **After indexing:** the index appeared as a `possible_key`, but MySQL's optimizer still chose
  a full scan the table (412 rows) was too small for the index to provide real benefit
- **Takeaway:** indexing shows negligible benefit on small tables like this one, but the same
  technique produces measurable gains on much larger tables (see the companion [Sales Data SQL
  project](../AnalystLab-Africa-SQL-Sales-Analysis), where indexing *did* show a measurable
  improvement on a larger table)

## Files in this project
- [`chinook_queries.sql`](./chinook_queries.sql) all 14 queries plus indexing/optimization tests

## Skills applied
`SQL` `MySQL Workbench` `Joins (INNER, LEFT)` `Subqueries` `Window Functions (RANK, ROW_NUMBER, PARTITION BY)` `Query Optimization (EXPLAIN, Indexing)` `Relational Schema Design` `Business Insight Reporting`
