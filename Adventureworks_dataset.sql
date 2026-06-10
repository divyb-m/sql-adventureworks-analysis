-- Q1: Which customers have placed the most orders?
select cl."CustomerKey", cl."FirstName", cl."LastName", sum("OrderQuantity") as total_orders
from (SELECT "CustomerKey", "OrderQuantity" FROM adventureworks_sales_data2020
    UNION ALL
    SELECT "CustomerKey", "OrderQuantity" FROM adventureworks_sales_data2021
    UNION ALL
    SELECT "CustomerKey", "OrderQuantity" FROM adventureworks_sales_data2022
) AS s
inner join adventureworks_customer_lookup as cl on s."CustomerKey" = cl."CustomerKey"
group by "FirstName", "LastName", cl."CustomerKey" 
order by "total_orders"desc;

--Q2: What are the top 10 best-selling products by order quantity?
select "ProductName", pl."ProductKey", sum("OrderQuantity") as total_order_quantity
from (select "ProductKey", "OrderQuantity" from adventureworks_sales_data2020
	union all
	select "ProductKey", "OrderQuantity" from adventureworks_sales_data2021
	union all
	select "ProductKey", "OrderQuantity" from adventureworks_sales_data2022) as s
	inner join adventureworks_product_lookup as pl on s."ProductKey" = pl."ProductKey"
	group by "ProductName", pl."ProductKey" 
	order by "total_order_quantity" desc
limit 10;

--Q3: Which product category generates the highest total revenue?
SELECT 
    cat."CategoryName",
    ROUND(SUM(s."OrderQuantity" * pl."ProductPrice")::numeric, 2) AS total_revenue
FROM (
    SELECT "ProductKey", "OrderQuantity" FROM adventureworks_sales_data2020
    UNION ALL
    SELECT "ProductKey", "OrderQuantity" FROM adventureworks_sales_data2021
    UNION ALL
    SELECT "ProductKey", "OrderQuantity" FROM adventureworks_sales_data2022
) AS s
INNER JOIN adventureworks_product_lookup AS pl ON s."ProductKey" = pl."ProductKey"
INNER JOIN adventureworks_product_subcategories_lookup AS sc ON pl."ProductSubcategoryKey" = sc."ProductSubcategoryKey"
INNER JOIN adventureworks_product_categories_lookup AS cat ON sc."ProductCategoryKey" = cat."ProductCategoryKey"
GROUP BY cat."CategoryName"
ORDER BY total_revenue DESC;

--Q4: What is the return rate by product?
SELECT s."ProductKey", pl."ProductName",
    ROUND(((r.total_returns / s.total_orders::numeric) * 100), 2) AS return_rate
FROM (
    SELECT "ProductKey", SUM("OrderQuantity") AS total_orders
    FROM (
        SELECT "ProductKey", "OrderQuantity" FROM adventureworks_sales_data2020
        UNION ALL
        SELECT "ProductKey", "OrderQuantity" FROM adventureworks_sales_data2021
        UNION ALL
        SELECT "ProductKey", "OrderQuantity" FROM adventureworks_sales_data2022
    ) AS all_sales
    GROUP BY "ProductKey"
) AS s
LEFT JOIN (
    SELECT "ProductKey", SUM("ReturnQuantity") AS total_returns
    FROM adventureworks_returns_data
    GROUP BY "ProductKey"
) AS r ON r."ProductKey" = s."ProductKey"
JOIN adventureworks_product_lookup AS pl ON pl."ProductKey" = s."ProductKey"
ORDER BY return_rate DESC;

--Q5: How do sales compare across 2020, 2021, and 2022?
---Calculate revenue for each year since data tables are stratified based on year 
--2020:
select  SUM(s20."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as revenue_2020
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2020 as s20 on pl."ProductKey" = s20."ProductKey"  
order by revenue_2020; 
--2021
select  SUM(s21."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as revenue_2021
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2021 as s21 on pl."ProductKey" = s21."ProductKey"  
order by revenue_2021;
--2022
select  SUM(s22."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as revenue_2022
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2022 as s22 on pl."ProductKey" = s22."ProductKey"  
order by revenue_2022;

--Determine best sales year (year with the highest revenue):
select '2020' as year, SUM(s20."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as Net_revenue
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2020 as s20 on pl."ProductKey" = s20."ProductKey" 
union all 
select '2021' as year, SUM(s21."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as Net_revenue
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2021 as s21 on pl."ProductKey" = s21."ProductKey" 
union all
select '2022' as year, SUM(s22."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as Net_revenue
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2022 as s22 on pl."ProductKey" = s22."ProductKey"
order by Net_revenue desc;

--Q6: Which territory has the highest average order value?
select tl."Region", tl."SalesTerritoryKey", (SUM(sq.Net_revenue)/ COUNT(*)) as Average_order_values
from (select '2020' as year, s20."TerritoryKey", SUM(s20."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as Net_revenue
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2020 as s20 on pl."ProductKey" = s20."ProductKey" 
group by s20."TerritoryKey"
union all 
select '2021' as year, s21."TerritoryKey", SUM(s21."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as Net_revenue
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2021 as s21 on pl."ProductKey" = s21."ProductKey" 
group by s21."TerritoryKey"
union all
select '2022' as year, s22."TerritoryKey", SUM(s22."OrderQuantity" *(pl."ProductPrice"- pl."ProductCost")) as Net_revenue
from adventureworks_product_lookup as pl
inner join adventureworks_sales_data2022 as s22 on pl."ProductKey" = s22."ProductKey"
group by s22."TerritoryKey"
) as sq
join adventureworks_territory_lookup as tl on tl."SalesTerritoryKey" = sq."TerritoryKey"
group by tl."Region",  tl."SalesTerritoryKey" 
order by average_order_values desc;


--Q7: Which customers have never returned a product?
-- Returns table doesn't have any customer information so this answer cannot be accurately answered as returns are not 
--limited to 1 customer performing the purchase as well as the return of the item

