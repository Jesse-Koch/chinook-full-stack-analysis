-- CHINOOK DIGITAL MEDIA STORE ANALYSIS
-- Database: Chinook (MySQL) — https://github.com/lerocha/chinook-database


-- SECTION 1: CATALOG REVENUE (GENRE & ARTIST)
-- revenue by artist, ranked
select ar.name artist, 
sum(il.Quantity * il.UnitPrice) revenue,
dense_rank() over(order by sum(il.Quantity * il.UnitPrice) desc) revenue_rank
from invoiceline il 
join track t on t.TrackId = il.TrackId
join album a on a.AlbumId = t.AlbumId
join artist ar on ar.ArtistId = a.ArtistId
group by artist;

-- top 3 artists by revenue, ranked
with artist_revenue as
(
select ar.name artist, 
sum(il.Quantity * il.UnitPrice) revenue,
dense_rank() over(order by sum(il.Quantity * il.UnitPrice) desc) revenue_rank
from invoiceline il 
join track t on t.TrackId = il.TrackId
join album a on a.AlbumId = t.AlbumId
join artist ar on ar.ArtistId = a.ArtistId
group by artist
)
select *
from artist_revenue 
where revenue_rank <= 3;

-- revenue by genre, ranked
select g.name genre, 
sum(il.Quantity * il.UnitPrice) revenue,
dense_rank() over(order by sum(il.Quantity * il.UnitPrice) desc) revenue_rank
from invoiceline il 
join track t on t.TrackId = il.TrackId
join genre g on g.GenreId = t.GenreId
group by genre;

-- top 3 artists by revenue, ranked
with genre_revenue as
(
select g.name genre, 
sum(il.Quantity * il.UnitPrice) revenue,
dense_rank() over(order by sum(il.Quantity * il.UnitPrice) desc) revenue_rank
from invoiceline il 
join track t on t.TrackId = il.TrackId
join genre g on g.GenreId = t.GenreId
group by genre
)
select *
from genre_revenue 
where revenue_rank <= 3;

-- findings: Rock generates $826.65, more than double the next genre (Latin, $382.14)
-- Four of the top five revenue artists are Rock/Metal acts.


-- SECTION 2: CUSTOMER & COUNTRY SPEND
-- total spend by customer, ranked
select c.CustomerId, concat(c.FirstName, ' ', c.LastName) customer_name, c.SupportRepId,
sum(i.Total) total_spend,
dense_rank() over(order by sum(i.Total) desc) spend_rank
from customer c
join invoice i on c.CustomerId = i.CustomerId
group by c.CustomerId, customer_name;

-- total spend by country, ranked
select c.Country, 
sum(i.Total) total_spend,
dense_rank() over(order by sum(i.Total) desc) spend_rank
from customer c
join invoice i on c.CustomerId = i.CustomerId
group by c.Country;

-- finding: USA ($523.06) and Canada ($303.96) together account for roughly
-- 35% of total customer spend.


-- SECTION 3: DATA QUALITY INVESTIGATION
-- invoice count and average invoice size per customer
select c.CustomerId, concat(c.FirstName, ' ', c.LastName) customer_name,
count(i.InvoiceId) as invoice_count,
round(avg(i.Total), 2) as avg_invoice_total,
sum(i.Total) as total_spend
from customer c
join invoice i on c.CustomerId = i.CustomerId
group by c.CustomerId, customer_name
order by total_spend desc;
-- finding: every customer has exactly 7 invoices (one has 6), which doesn't
-- reflect typical customer behavior.

-- frequency of exact invoice totals
select Total, count(*) as frequency
from invoice
group by Total
order by frequency desc;

-- finding: invoice totals cluster heavily around exact multiples of
-- $0.99: 1.98 appears 111 times, 3.96 appears 57 times, 5.94 appears 56 times, etc.
-- This confirms Chinook's sales data is synthetically generated (fixed invoice count x near-uniform track price), 
-- not typical purchasing behavior. Customer-spend and revenue-trend findings
-- throughout this project are presented mainly as technique demonstrations.


-- SECTION 4: EMPLOYEE / SALES SUPPORT REP PORTFOLIO
-- revenue and customer count per support rep
select e.EmployeeId, concat(e.FirstName, ' ', e.LastName) employee_name, 
count(i.InvoiceId) invoice_count,
count(distinct c.CustomerId) customer_count,
sum(i.Total) total_spend,
round(avg(i.Total), 2) avg_invoice_spend,
round(((sum(i.Total)) / (nullif(count(distinct c.CustomerId), 0))), 2) avg_customer_spend
from employee e
left join customer c on e.EmployeeId = c.SupportRepId
left join invoice i on i.CustomerId = c.CustomerId
group by EmployeeId, employee_name
order by total_spend desc, avg_invoice_spend desc, avg_customer_spend desc;

-- finding: only 3 of 8 employees have assigned customers. Jane Peacock has
-- the highest total spend ($833.04) and highest average invoice ($5.71)
-- by managing the most customers (21), but Steve Johnson's smaller portfolio (18 customers) 
-- has the highest average spend per customer ($40.01).


-- SECTION 5: REVENUE TREND
-- yearly revenue and year-over-year growth
with yearly_revenue as
(
select year(InvoiceDate) invoice_year, 
sum(Total) revenue
from invoice
group by invoice_year
)
select *,
lag(revenue) over(order by invoice_year) prev_year_revenue,
round(((revenue - lag(revenue) over(order by invoice_year)) / (lag(revenue) over(order by invoice_year))) * 100, 1) YoY_growth_pct
from yearly_revenue;
-- finding: revenue oscillates within a narrow $449-$481 range across all
-- five years, with no sustained growth or decline.

-- monthly revenue and month-over-month growth
with monthly_revenue as
(
select year(InvoiceDate) invoice_year, month(InvoiceDate) invoice_month,
sum(Total) revenue
from invoice
group by invoice_year, invoice_month
)
select *,
lag(revenue) over(order by invoice_year, invoice_month) prev_month_revenue,
round(((revenue - lag(revenue) over(order by invoice_year, invoice_month)) / (lag(revenue) over(order by invoice_year, invoice_month))) * 100, 1) MoM_growth_pct
from monthly_revenue;
-- finding: revenue is flat at exactly $37.62 in the large majority of
-- months across all five years, with only occasional random deviation 
-- confirming the data quality issue mentioned previously


-- SECTION 6: EMPLOYEE REPORTING HIERARCHY (SELF-JOIN)
select e1.EmployeeId, concat(e1.FirstName, ' ', e1.LastName) employee_name, e2.EmployeeId, concat(e2.FirstName, ' ', e2.LastName) manager_name
from employee e1
left join employee e2 on e1.ReportsTo = e2.EmployeeId;
-- finding: two branches report to General Manager Andrew Adams. Nancy
-- Edwards oversees the three employees who manage customer accounts
-- (Jane Peacock, Margaret Park, Steve Johnson); Michael Mitchell oversees
-- a separate branch (Robert King, Laura Callahan) with no customer-facing
-- responsibilities, explaining why 5 of 8 employees show no
-- customer activity in Section 4.


-- SECTION 7: PLAYLIST GENRE POPULARITY (MANY-TO-MANY)

select p.PlaylistId, p.Name playlist_name,
count(t.TrackId) track_number
from track t
join playlisttrack pt on pt.TrackId = t.TrackId
join playlist p on p.PlaylistId = pt.PlaylistId
group by p.PlaylistId
order by track_number desc;

select g.Name, count(t.TrackId) playlist_appearances
from genre g
join track t on g.GenreId = t.GenreId
join playlisttrack pt on pt.TrackId = t.TrackId
group by g.Name
order by playlist_appearances desc;

-- finding: Rock appears 3,238 times across all playlists, further confirming Rock's dominance alongside
-- genre revenue (Section 1). 