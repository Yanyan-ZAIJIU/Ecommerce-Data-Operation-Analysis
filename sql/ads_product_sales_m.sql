-- ads_product_sales_m	
DROP TABLE IF EXISTS ads_product_sales_m;
CREATE TABLE ads_product_sales_m AS
with total_cum_pct as
(
	SELECT
		global_product_id,
		product_name,
		category,
-- 		sum(quantity) quantity,
-- 		round(sum(quantity*unit_price),2) revenue,
		round(sum(sum(quantity*unit_price))over(order by sum(quantity*unit_price) desc)/sum(sum(quantity*unit_price))over()*100,2) cum_pct
-- 		sum(sum(quantity*unit_price))over() as total_revenue 
	FROM
		dwd_order_item_product 
	GROUP BY
		global_product_id,
		product_name,
		category
),
ym_cum_pct as
(
	SELECT
		order_year,
		order_month,
		global_product_id,
		product_name,
		category,
		sum(quantity) quantity,
		round(sum(quantity*unit_price),2) revenue,
		round(sum(sum(quantity*unit_price))over(partition by order_year,order_month order by sum(quantity*unit_price)desc)/sum(sum(quantity*unit_price))over(partition by order_year,order_month) *100,2) cum_pct
		
	FROM
		dwd_order_item_product 
	GROUP BY
		order_year,
		order_month,
		global_product_id,
		product_name,
		category
)

select 
ym.order_year,
ym.order_month,
concat(ym.order_year,'-',if(ym.order_month<=9,concat('0',ym.order_month),ym.order_month),'-01') order_date,
ym.global_product_id product_id,
ym.product_name,
ym.category,
ym.quantity,
ym.revenue,
case when ym.cum_pct<=70 then 'A' when ym.cum_pct<=90 then 'B' else 'C' end ym_abc,
-- tt.quantity,
-- tt.revenue,
case when tt.cum_pct<=70 then 'A' when tt.cum_pct<=90 then 'B' else 'C' end total_abc
 from ym_cum_pct ym left join total_cum_pct tt on ym.global_product_id=tt.global_product_id