-- ads_user_rfm_classic_m 分月rfm
DROP TABLE IF EXISTS ads_user_rfm_classic_m;
CREATE TABLE ads_user_rfm_classic_m AS
with 
user_consume as
(
	select 
	date_format(order_date,'%Y-%m') order_month,
	user_id,
	max(order_date) last_order_date,
	sum(total_amount) monetary_sum,
	count(distinct order_id) frequency_cnt
	 from dwd_order_info 
	 group by date_format(order_date,'%Y-%m'),
	user_id
),
user_rfm as
(
	select 
	order_month,
	user_id,
	datediff(last_day(concat(order_month,'-01')),last_order_date) recency_days,
	frequency_cnt,
	monetary_sum
	 from user_consume
),
r_score AS
(
	SELECT
		order_month,
		recency_days,
		ntile(5)over(partition by order_month ORDER BY recency_days desc) r_score 
	FROM
	(SELECT DISTINCT order_month, recency_days FROM user_rfm)r
),
f_score as
(	
	SELECT 
	order_month,
	frequency_cnt,
	ntile(5)over(partition by order_month ORDER BY frequency_cnt ) f_score 
	FROM
	(SELECT DISTINCT order_month,frequency_cnt FROM user_rfm)f
),
m_score as
(
	SELECT
	order_month,
	monetary_sum,
	ntile(5)over(partition by order_month ORDER BY monetary_sum ) m_score 
	FROM
	(SELECT DISTINCT order_month,monetary_sum FROM user_rfm)m
)
	select 
	u.order_month,
	u.user_id,
	u.recency_days,
	u.frequency_cnt,
	u.monetary_sum,
	r_score,
	f_score,
	m_score,
	case 
	when r_score>=3 and f_score>=3 and m_score>=3 then '高价值核心用户' -- 维稳，一切最优服务
	when r_score>=3 and f_score>=3 and m_score<=2 then '忠实复购用户'   -- 提客单价
	when r_score>=3 and f_score<=2 and m_score>=3 then '高潜大额新客用户' -- 高优先促复购
	when r_score>=3 and f_score<=2 and m_score<=2 then '普通新用户'  -- 促复购
	when r_score<=2 and f_score>=3 and m_score>=3 then '流失预警高价值用户' -- 高优先召回
	when r_score<=2 and f_score>=3 and m_score<=2 then '沉睡高频低消用户' -- 低成本唤醒
	when r_score<=2 and f_score<=2 and m_score>=3 then '沉睡大额低频用户' -- 大额专属唤醒
	when r_score<=2 and f_score<=2 and m_score<=2 then '三低用户' -- 低优先，批量泛运营
	end user_segment
	from user_rfm u 
	left join r_score r on u.recency_days=r.recency_days and u.order_month=r.order_month
	left join f_score f on u.frequency_cnt=f.frequency_cnt and u.order_month=f.order_month
	left join m_score m on u.monetary_sum=m.monetary_sum and u.order_month=m.order_month