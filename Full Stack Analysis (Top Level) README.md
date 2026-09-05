# Chinook Full-Stack Analysis: SQL → Excel → Power BI

## Overview
A three-phase analytics pipeline built on the Chinook digital media store database, demonstrating how the same relational data and business questions are extracted, reported, and visualized using three different tools.
```
SQL (extraction & analysis) → Excel (stakeholder report) → Power BI (live dashboard)
```

## Why This Project Is Structured This Way
This project follows a single dataset through a realistic pipeline: SQL is used for the heavy relational extraction and analysis (JOINs, window functions, self-joins); Excel reshapes exported results into a quick, presentable report using lookup functions and Power Query; Power BI models the same data as a proper star schema and builds it into a live, interactive dashboard. The same relational problem (linking a customer to their sales support representative) is deliberately solved three separate times (via SQL JOIN, via Excel VLOOKUP/XLOOKUP/Power Query Merge, and via a Power BI relationship + `RELATED()`) to demonstrate the same underlying logic expressed through three different tools.

## Repository Structure
```
├── sql/
│   ├── chinook_queries.sql
│   └── README.md
├── excel/
│   ├── Chinook_Excel_Report.xlsx
│   └── README.md
├── powerbi/
│   ├── Chinook_PowerBI_Dashboard.pbix
│   ├── Chinook_PowerBI_Dashboard.pdf
│   └── README.md
└── README.md   (this file)
```

## Cross-Tool Validation
The same findings were independently re-derived at each stage, confirming consistency across three separate calculation methods:

| Finding | SQL | Excel | Power BI |
|---|---|---|---|
| Top revenue artist | Iron Maiden, $138.60 (DENSE_RANK) | Confirmed via PivotTable | Confirmed via RANKX |
| Top revenue genre | Rock, $826.65 (aggregation) | Confirmed via PivotChart | Confirmed via % of Total measure |
| YoY revenue growth | Calculated via LAG() | Recalculated via "% Difference From (previous)" | Recalculated via SAMEPERIODLASTYEAR |
| Employee reporting hierarchy | Reconstructed via self-JOIN | — | Reconstructed via RELATED() on a duplicated Employee table |
| Top employee by portfolio value | Jane Peacock (total) / Steve Johnson (per-customer) | — | Confirmed via employee portfolio table |

## Skills Demonstrated Across the Pipeline
- **SQL**: multi-table JOINs (up to 5 tables), self-JOIN, many-to-many traversal, window functions (DENSE_RANK, LAG), CTEs, safe division (NULLIF)
- **Excel**: VLOOKUP, XLOOKUP, Power Query Merge, PivotTables/PivotCharts, period-over-period growth via built-in PivotTable calculations, conditional formatting
- **Power BI**: star schema modeling, role-playing dimensions for self-referencing relationships, RELATED(), RANKX + ALL(), time intelligence (TOTALYTD, SAMEPERIODLASTYEAR), FILTER() with row-context iteration, the % of Total pattern, and a deliberate calculated-column-vs-measure comparison

## Data Quality Finding (applies across all three phases)
Investigation in the SQL phase uncovered that Chinook's transactional data is synthetically generated rather than reflective of natural customer and business behavior: every customer has exactly 6–7 invoices, and invoice totals cluster around fixed multiples of a near-uniform $0.99 track price. This was confirmed through three dedicated diagnostic queries and reconfirmed visually in the Excel monthly revenue trend chart, which show a flat line with occasional spikes rather than genuine seasonality. As a result, customer-spend and revenue-trend findings are presented throughout this project as tool demonstrations rather than genuine business insight (a distinction actively investigated and documented, not assumed). Catalog and popularity findings (genre, artist, playlist revenue) are not subject to this limitation, since they reflect the underlying music library rather than the generated transaction data.

## Key Findings & Recommendations
*Recommendations below are drawn only from the catalog/organizational findings established as trustworthy; no recommendation is based on customer spend, revenue trend, or purchase-frequency patterns, since those were confirmed to reflect Chinook's synthetic data generation rather than genuine business behavior (see Data Quality Finding above).*

**1. Catalog concentration in Rock/Metal**
Rock generates more revenue ($826.65) than the next three genres combined, and dominates playlist curation at a comparable scale (3,238 appearances, more than every other genre combined). This consistency across two independent measures, purchasing and curation, is a stronger signal than either on their own.
*Recommendation:* prioritize Rock/Metal titles in catalogue acquisition and promotional placement, where demonstrated demand concentration is strongest.

**2. Employee portfolio efficiency**
Jane Peacock manages the most customers (21) and generates the highest total revenue, but Steve Johnson's smaller portfolio (18 customers) generates the highest average revenue per customer ($40.01 vs. Jane's $39.67).
*Recommendation:* investigate whether Steve Johnson's approach to customer relationships is replicable. 

**3. Organizational capacity**
5 of 8 employees show no customer-linked activity, entirely concentrated in a single non-sales branch of the reporting hierarchy (under Michael Mitchell). Only the three employees reporting to Nancy Edwards handle customer accounts.
*Recommendation:* if customer-facing capacity ever needs to expand, this analysis identifies exactly where in the organisational hierarchy any support would need to be sourced from.

## How to Explore This Project
- Start with `sql analysis README.md` for the full business-question breakdown and the data-quality investigation
- `Excel Analysis README.md` covers the stakeholder-report phase and the lookup-function comparison
- `Chinook Power BI.md` covers the data model, DAX measures, and dashboard structure
- Open `Chinook Power BI.pbix` in Power BI Desktop for the full interactive experience, or view the included PDF export for a quick static preview

## Dataset
Chinook sample database (MySQL): https://github.com/lerocha/chinook-database
