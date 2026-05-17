--  dws_user_rfm	
DROP TABLE IF EXISTS dws_user_rfm;
CREATE TABLE dws_user_rfm AS
SELECT 
    user_id,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT order_id) AS frequency_cnt,
    SUM(total_amount) AS monetary_sum,
    DATEDIFF("2027-01-01", MAX(order_date)) AS recency_days   -- 最近消费距今天数
FROM dwd_order_info
GROUP BY user_id;