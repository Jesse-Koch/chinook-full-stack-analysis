## Chinook Full-Stack Analysis
## Phase 1: SQL (MySQL)
*Part of a three-phase pipeline: SQL → Excel → Power BI. See the top-level README for the full project.*

## Overview
Relational analysis of the Chinook digital media store database (11 tables: customers, invoices, tracks, albums, artists, genres, employees, playlists) using MySQL. This phase extracts and analyzes the data; its outputs feed directly into the Excel and Power BI phases that follow.

## Business Questions Answered
1. Which genres and artists generate the most revenue?
2. Who are the top customers by spend, and which countries generate the most revenue?
3. Does each sales support rep's customer portfolio differ in value?
4. How does revenue trend over the dataset's 5-year span, by year and by month?
5. What is the company's reporting hierarchy?
6. Which genres dominate playlist curation (via the Playlist–Track many-to-many relationship)?

## Skills Demonstrated
- Multi-table JOINs up to 5 tables deep (Artist → Album → Track → InvoiceLine → Invoice)
- Self-JOIN to reconstruct the employee reporting hierarchy
- Many-to-many relationships via a junction table (Playlist ↔ PlaylistTrack ↔ Track)
- Window functions: DENSE_RANK() for revenue ranking, LAG() for year-over-year and month-over-month growth
- CTEs to aggregate before ranking
- Safe division using NULLIF to prevent divide-by-zero errors when calculating per-customer averages
- YEAR()/MONTH() datetime grouping 

## Key Findings
1. Rock dominates the catalogue on every measure tested. It generates $826.65 in revenue (more than double the next genre, Latin, at $382.14) and appears 3,238 times across playlists, which is more than every other genre combined.
2. Four of the top five revenue-generating artists (Iron Maiden, Metallica, Led Zeppelin, and others) are Rock/Metal acts, directly explaining Rock's genre-level dominance. Most classical/orchestral artists generated only $0.99 each, from just one track sale.
3. The reporting hierarchy (via self-join) shows two branches under General Manager Andrew Adams: Nancy Edwards oversees the three employees who actually manage customer accounts, while Michael Mitchell's branch has no customer responsibilities, explaining why 5 of 8 employees showed no customer activity in the analysis.
4. Among active sales reps: Jane Peacock generates the highest total spend ($833.04) and highest per-customer invoice by managing the most customers (21), but Steve Johnson's smaller portfolio (18 customers) generates the highest average spend per customer ($40.01).

## Data-quality finding: synthetic generation artifacts
Investigation into customer spend and revenue trends uncovered a structural data artifact in how Chinook's sales data was generated, using three verification queries:
- Every customer has exactly 7 invoices (one has 6), which is not natural customer behavior.
- Invoice totals cluster heavily around exact multiples of $0.99 (Chinook's near-uniform per-track price): $1.98 appears 111 times, $3.96 appears 57 times, etc.
- At monthly level, revenue is flat at exactly $37.62 in the large majority of months across all five years, with only occasional random deviation.

*As a result, customer-spend and revenue-trend findings are presented as SQL technique demonstrations rather than genuine business insight, a distinction actively verified through investigation rather than assumed. Catalog/popularity findings (genre, artist, playlist) are not subject to this limitation, since they reflect the underlying music library rather than the generated transaction data.*

## Notable Debugging Moments
- An initial self-join for the employee hierarchy had its join condition reversed (matching direct reports instead of managers), silently building the wrong relationship direction — caught by tracing through what the join condition literally selects for.
- An attempt to safely handle division by zero used COALESCE instead of NULLIF. NULLIF, which converts the problematic 0 itself into NULL before division, was the correct fix.
- Several queries included tables in the JOIN chain that were never referenced in the SELECT or GROUP BY, adding unnecessary complexity without affecting results, and were trimmed for clarity.

## Files
chinook sql queries.sql - all queries organized by business question

## Dataset
Chinook sample database (MySQL): https://github.com/lerocha/chinook-database

## Next Stage
Query outputs from this analysis feed into the Excel stakeholder report and the Power BI dashboard.
