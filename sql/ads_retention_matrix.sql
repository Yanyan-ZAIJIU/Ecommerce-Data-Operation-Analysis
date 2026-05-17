-- ads_retention_matrix
-- 留存率矩阵（按月份切分）
DROP TABLE IF EXISTS ads_retention_matrix;
CREATE TABLE ads_retention_matrix AS
WITH cohort_users AS (
    -- 每个用户所属同期群（首次下单月份）
    SELECT DISTINCT
        user_id,
        DATE_FORMAT(first_order_date, '%Y-%m') AS cohort_month
    FROM dws_user_rfm
),
user_orders as (
    -- 用户各月是否有下单（去重）
    SELECT DISTINCT
        user_id,
        DATE_FORMAT(order_date, '%Y-%m') AS order_month
    FROM dwd_order_info
),
cohort_size AS (
    -- 每个同期群的总用户数
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS total_users
    FROM cohort_users
    GROUP BY cohort_month
),
cohort_retention AS (
    SELECT 
        c.cohort_month,
        uo.order_month,
        COUNT(DISTINCT c.user_id) AS active_users
    FROM cohort_users c
    LEFT JOIN user_orders uo ON c.user_id = uo.user_id
    WHERE uo.order_month IS NOT NULL
    GROUP BY c.cohort_month, uo.order_month
)
SELECT 
    cr.cohort_month,
    cr.order_month,
    TIMESTAMPDIFF(MONTH, CONCAT(cr.cohort_month, '-01'), CONCAT(cr.order_month, '-01')) AS month_index,
    cr.active_users,
    cs.total_users,
    ROUND(cr.active_users * 100.0 / cs.total_users, 2) AS retention_rate
FROM cohort_retention cr
JOIN cohort_size cs ON cr.cohort_month = cs.cohort_month
ORDER BY cr.cohort_month, month_index;