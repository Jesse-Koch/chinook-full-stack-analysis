# Chinook Full-Stack Analysis
# Phase 2: Excel
 
*Part of a three-phase pipeline: SQL → Excel → Power BI. See the top-level README for the full project.*
 
## Overview
Second stage of the pipeline. SQL query results exported as CSVs, then reshaped into a presentable stakeholder report using Excel.
Deliberate re-solving of several relational problems already handled in SQL, using Excel's own tools, to demonstrate the same underlying logic across two different environments.
 
## Workbook Structure
- **Lookup Practice** — VLOOKUP and XLOOKUP exercises resolving a raw foreign key (SupportRepId) into a readable employee name, including both functions' native fallback handling and an IFERROR()-wrapped alternative
- **Power Query Merge** — the same Customer Spend / Employees relationship, rebuilt using Power Query's Merge Queries tool
- **Stakeholder Summary** — the final presentable report: KPI cells, PivotTables, PivotCharts, and conditional formatting

## Skills Demonstrated
- VLOOKUP and XLOOKUP, including XLOOKUP's built-in not-found fallback argument versus VLOOKUP requiring an external IFERROR() wrapper to achieve the same result
- Power Query Merge Queries (Left Outer join) as a visual equivalent to a SQL LEFT JOIN
- PivotTables and PivotCharts, including Top 10 value filtering
- PivotTable "Show Values As → % Difference From (previous)" for period-over-period growth, without a manual calculated field
- Conditional formatting (color scale / top-N highlighting)
- Combining separate Year and Month fields into a single date value using DATE(), to enable correct chronological charting

## Design Note: Solving the Same Problem Three Ways
Customer Spend and Employees are deliberately joined three separate times in this workbook, via VLOOKUP, via XLOOKUP, and via Power Query Merge, mirroring the SQL JOIN already written in Phase 1. All three intentionally coexist in the file rather than being reduced to one, since the point of this phase is demonstrating the same relational logic expressed through different tools, not simply solving the lookup once.
 
## Notable Debugging Moments
- An early XLOOKUP formula used inconsistent fallback values across two lookups (`""` for FirstName, `"Unknown"` for LastName), which would have produced a malformed result like `" Unknown"` for any unmatched ID. Fixed by checking once, upfront, whether the ID exists at all, and returning one clean fallback message rather than combining two independently-handled fallbacks.
- The monthly revenue line chart initially showed a false, steady upward trend. Traced to Excel's automatic date-grouping behavior, which had collapsed the combined date field down to 12 month buckets (merging January 2021, January 2022, January 2023, etc. into one "January" group) rather than showing 60 distinct chronological points. Fixed by ungrouping the date field, after which the chart correctly displayed the flat, spiking pattern consistent with the SQL-phase findings.

## Data Quality Note
As established in the SQL phase, Chinook's transactional data (customer spend, revenue trend) is synthetically generated rather than reflective of organic business behavior, i.e., every customer has exactly 7 invoices, and invoice totals cluster around fixed multiples of a near-uniform $0.99 track price. 
 
## Files
`Chinook Excel Analysis.xlsx` - full workbook

## Next Stage
The same underlying data is modeled as a proper star schema and visualized as an interactive dashboard in Power BI.
