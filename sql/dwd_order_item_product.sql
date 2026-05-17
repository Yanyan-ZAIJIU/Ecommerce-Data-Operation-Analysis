-- dwd_order_item_product
DROP TABLE IF EXISTS dwd_order_item_product;
CREATE TABLE dwd_order_item_product AS 
SELECT
ooi.order_item_id,
ooi.order_id,
ooi.global_product_id,
ooi.quantity,
ooi.unit_price,
dp.product_name,
dp.category,
dp.brand,
oo.order_time,
date(oo.order_time)order_date,
year(oo.order_time)order_year,
month(oo.order_time)order_month,
oo.payment_method,
oo.order_status,
oo.promotion_id,
oo.shipping_method 
FROM
	ods_order_item ooi
	LEFT JOIN dim_product dp ON ooi.global_product_id = dp.global_product_id
	LEFT JOIN ods_order oo ON ooi.order_id = oo.order_id