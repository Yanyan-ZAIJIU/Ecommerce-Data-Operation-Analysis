-- ads_daily_gmv
DROP TABLE IF EXISTS ads_daily_gmv;
CREATE TABLE ads_daily_gmv AS
SELECT 
    order_date,
    COUNT(DISTINCT order_id) AS order_cnt,
    SUM(total_amount) AS gmv
FROM dwd_order_info
GROUP BY order_date
ORDER BY order_date;