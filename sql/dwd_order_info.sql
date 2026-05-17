-- dwd_order_info
DROP TABLE IF EXISTS dwd_order_info;
CREATE TABLE dwd_order_info AS 
SELECT
o.order_id,
o.global_user_id user_id,
o.order_time,
o.total_amount,
o.order_status,
u.registration_date,
DATE( o.order_time ) AS order_date,
YEAR ( o.order_time ) AS order_year,
MONTH ( o.order_time ) AS order_month 
FROM
	ods_order o
	LEFT JOIN ods_user u ON o.global_user_id = u.global_user_id 
WHERE
	o.order_status IN ( '已付款', '已发货', '已完成' ) -- 有效订单状态
	AND o.total_amount > 0;
	