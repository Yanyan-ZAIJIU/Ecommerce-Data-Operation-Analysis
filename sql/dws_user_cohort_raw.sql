-- dws_user_cohort_raw
DROP TABLE IF EXISTS dws_user_cohort_raw;
CREATE TABLE dws_user_cohort_raw AS
SELECT 
    user_id,
    DATE_FORMAT(first_order_date, '%Y-%m') AS cohort_month,
    order_date,
    DATE_FORMAT(order_date, '%Y-%m') AS order_month
FROM dws_user_rfm
JOIN dwd_order_info USING(user_id);