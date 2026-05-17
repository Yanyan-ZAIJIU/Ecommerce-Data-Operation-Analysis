-- ads_category_sales
DROP TABLE IF EXISTS ads_category_sales;
CREATE TABLE ads_category_sales AS
SELECT 
		date(o.order_time) order_date,
    p.category,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_cnt
FROM ods_order_item oi
JOIN dim_product p ON oi.global_product_id = p.global_product_id
left join ods_order o on oi.order_id=o.order_id
where o.order_status in ('已付款','已发货','已完成')
GROUP BY date(o.order_time),p.category;