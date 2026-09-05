# Chinook Full-Stack Analysis 
# Phase 3: Power BI

*Part of a three-phase pipeline: SQL → Excel → Power BI. See the top-level README for the full project.*

## Overview
Final stage of the pipeline. The Chinook database is connected directly (via MySQL connector, not CSV export) and modeled as a proper star schema, then visualized as a four-page interactive dashboard using DAX measures spanning aggregation, ranking, time intelligence, and row-level filtering.

## Data Model
8 tables imported directly from MySQL, connected through 8 relationships:
- Artist → Album → Track → InvoiceLine ← Invoice ← Customer ← Employee (support rep)
- Genre → Track
- Employee → Employee (self-referencing "reports to" relationship)

`InvoiceLine` sits at the center as the fact table; every other table is a dimension table describing who, what, or which category a given transaction relates to.

**Self-join workaround:** Power BI's relationship dialog does not allow selecting the same table on both sides of a relationship. Resolved by duplicating the Employee table in Power Query to create `EmployeeManager` — a role-playing dimension representing the same underlying data in a second role. `Employee[ReportsTo]` connects to `EmployeeManager[EmployeeId]`, allowing each employee's manager to be looked up via `RELATED()`.

## Report Structure
- **Executive Summary**: KPI cards (Total Revenue, Total Customers, Total Invoices, Avg Invoice Value), genre revenue chart, top 10 artists, headline finding
- **Catalogue Performance**: Artist → Album → Track drill-down chart, genre revenue with % of total
- **Customer & Employee**: employee portfolio table, revenue-by-country treemap, customer spend tier breakdown, reporting hierarchy table
- **Revenue Stats**: YTD/prior-year/YoY growth cards, monthly revenue trend line chart, yearly summary table, data quality caveat

## Skills Demonstrated
- **Data modeling**: star schema design, direct database connection
- **DAX aggregation**: SUMX (row-by-row revenue calculation), DISTINCTCOUNT
- **DAX safety**: DIVIDE for divide-by-zero protection
- **Relationships**: RELATED(), used both for genre lookup on Track and manager lookup via the duplicated Employee table
- **Dynamic ranking**: RANKX combined with ALL() to rank across the complete, unfiltered table regardless of active report filters
- **Time intelligence**: a dedicated marked Date table; TOTALYTD, CALCULATE + SAMEPERIODLASTYEAR for year-over-year comparison
- **Row-context iteration**: FILTER() combined with CALCULATE() to compute revenue from customers meeting a per-customer condition (invoice count), demonstrating how FILTER supplies row context that an inner CALCULATE picks up automatically
- **% of Total pattern**: DIVIDE paired with CALCULATE + ALL, applied independently to both Genre and Country dimensions
- **Calculated column vs. measure**: a customer spend-tier classification was deliberately built twice: once as a static calculated column (fixed at each customer's full history, unaffected by report filters) and once as a measure (recalculates dynamically with an active date filter), demonstrating the practical difference between the two and the business reasoning for choosing one over the other depending on whether a metric should respond to interactive filtering

## Key Findings
Findings from the SQL phase were independently re-derived through DAX and Power BI visuals, serving as a cross-validation check:
- Artist Revenue Rank (RANKX) confirms Iron Maiden as the top revenue artist at $138.60, matching the SQL DENSE_RANK result
- YoY Growth% (time intelligence) matches the year-over-year figures originally calculated with SQL's LAG()
- The reporting hierarchy reconstructed via RELATED() matches the SQL self-join result exactly
- Employee portfolio comparison confirms the same Jane Peacock / Steve Johnson total spend vs. per customer value distinction found in SQL

## Notable Debugging Moments
- The `% of Total Revenue` measure initially had its numerator and denominator reversed (grand total divided by the filtered value rather than the reverse), producing results greater than 100%. Fixed by swapping the arguments so the filtered context sits in the numerator and the ALL()-stripped grand total sits in the denominator.
- The same date-hierarchy auto-grouping issue found in the Excel phase resurfaced in Power BI's default line chart behavior, collapsing all years' same-numbered months together (e.g., merging every January across all five years). Resolved by disabling Auto Date/Time in Power BI's options and binding chart axes to the plain Date field rather than the auto-generated hierarchy.

## Data Quality Note
As established in the SQL phase and reconfirmed in Excel, Chinook's transactional data is synthetically generated: every customer has exactly 6–7 invoices, and invoice totals cluster around fixed multiples of a near-uniform $0.99 track price. 

## Files
- `Chinook PowerBI.pbix` - full interactive report
- `Chinook PowerBI.pdf` - static export for quick preview

## Dataset
Chinook sample database (MySQL): https://github.com/lerocha/chinook-database
