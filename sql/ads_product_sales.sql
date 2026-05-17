-- ads_product_sales	
DROP TABLE IF EXISTS ads_product_sales;
CREATE TABLE ads_product_sales AS
with total_cum_pct as
(
	SELECT
		global_product_id,
		product_name,
		category,
		sum(quantity) quantity,
		round(sum(quantity*unit_price),2) revenue
-- 		sum(sum(quantity*unit_price))over(order by sum(quantity*unit_price) desc) cum_revenue,
-- 		round(sum(sum(quantity*unit_price))over(order by sum(quantity*unit_price) desc)/sum(sum(quantity*unit_price))over()*100,2) cum_pct
-- 		sum(sum(quantity*unit_price))over() as total_revenue 
	FROM
		dwd_order_item_product 
		where order_status in ('已付款','已发货','已完成')
	GROUP BY
		global_product_id,
		product_name,
		category
)

select 
global_product_id product_id,
product_name,
category,
quantity,
revenue,
sum(revenue)over(order by revenue desc) cum_revenue,
sum(revenue)over(order by revenue desc)/sum(revenue)over() cum_pct,
case when sum(revenue)over(order by revenue desc)/sum(revenue)over()<=0.7 then 'A' when sum(revenue)over(order by revenue desc)/sum(revenue)over()<=0.9 then 'B' else 'C' end total_abc
 from  total_cum_pct tt 