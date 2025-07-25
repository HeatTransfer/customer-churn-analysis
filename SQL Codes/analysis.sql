/* 
Churn Defination: 
Customers who haven’t used the product in last 30 days and whose subscription is marked as inactive or canceled.
*/
-- Cut-off date: 30-Jun-2024
-- Let's assume that we're making the report on 01-Jul-2025

/*=============================================================
Get the details of the churned customers as per definition
=============================================================*/
WITH churned_cid AS (
	SELECT
		c.customer_id
	FROM customers c
	LEFT JOIN product_usage p ON c.customer_id = p.customer_id
	LEFT JOIN subscription s ON c.customer_id = s.customer_id
	WHERE s.status IN ('inactive', 'canceled')
	GROUP BY c.customer_id
	HAVING MAX(p.usage_date) IS NULL 
		OR DATEDIFF(DAY, MAX(p.usage_date), DATEFROMPARTS(2024, 6, 30)) > 30
)
SELECT * FROM customers WHERE customer_id IN (SELECT * FROM churned_cid);

/* Outcome: 
We've found out 19 such customers. 
*/

/*====================================================================================================================
Cohort Analysis by signup month: We'll try to figure out MoM active customer count from Jan-2023 onwards for 12 Months
====================================================================================================================*/
-- Step 1: Assign cohort month to each customer
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        DATEFROMPARTS(YEAR(signup_date), MONTH(signup_date), 1) AS cohort_month
    FROM customers
),

-- Step 2: Get usage month from product_usage
usage_months AS (
    SELECT 
        customer_id,
        DATEFROMPARTS(YEAR(usage_date), MONTH(usage_date), 1) AS usage_month
    FROM product_usage
),

-- Step 3: Join and calculate months_since_signup
cohort_usage AS (
    SELECT 
        c.cohort_month,
        u.usage_month,
        DATEDIFF(MONTH, c.cohort_month, u.usage_month) AS months_since_signup,
        u.customer_id
    FROM customer_cohorts c
    JOIN usage_months u ON c.customer_id = u.customer_id
),

-- Step 4: Count unique active users per cohort and month offset
active_counts AS (
    SELECT 
        cohort_month,
        months_since_signup,
        COUNT(DISTINCT customer_id) AS active_users
    FROM cohort_usage
    WHERE cohort_month >= '2023-01-01' AND months_since_signup IS NOT NULL AND months_since_signup <> 0
    GROUP BY cohort_month, months_since_signup
)
-- Step 5: Pivot to get cohort matrix
SELECT cohort_month, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]
FROM active_counts
PIVOT (
    SUM(active_users)
    FOR months_since_signup IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS pivot_table
ORDER BY cohort_month;

/* Observation:
Early cohorts (Jan–Apr 2023) show strong long-term retention, especially April 2023 which consistently retains ~10–11 active users even 8+ months later.
Mid-year cohorts (May–Aug 2023) show moderate engagement, with retention slowly tapering over time but still maintaining activity.
Recent cohorts (Sep–Dec 2023) exhibit initially high usage, but it’s too early to assess long-term retention due to limited months of data.
Overall, April 2023 stands out as the most loyal cohort, while May and onward show signs of slightly lower or more volatile engagement.
*/

/*==========================================================================================================
Correlation b/w (feature used and churning)
==========================================================================================================*/
WITH churn_flag AS (
    SELECT 
        c.customer_id,
        CASE 
            WHEN s.status IN ('inactive', 'canceled') AND 
                 DATEDIFF(DAY, MAX(p.usage_date), '2024-06-30') > 30 THEN 1
            ELSE 0
        END AS churned
    FROM customers c
    LEFT JOIN subscription s ON c.customer_id = s.customer_id
    LEFT JOIN product_usage p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, s.status
),

features_used AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT features_used) AS features_used_last_30_days
    FROM product_usage
    WHERE usage_date BETWEEN DATEADD(DAY, -30, '2024-06-30') AND '2024-06-30'
    GROUP BY customer_id
)

SELECT 
    cf.customer_id,
    ISNULL(fu.features_used_last_30_days, 0) AS features_used_last_30_days,
    cf.churned
FROM churn_flag cf
LEFT JOIN features_used fu ON cf.customer_id = fu.customer_id
ORDER BY cf.customer_id;

/* Observation: 
Correlation value came ~0.5 from pandas,
which is a moderate negative correlation, meaning as the number of features used by a customer increases, 
the likelihood of churn decreases - customers who actively use more features are less likely to churn.
*/

/*=====================================================
Correlation b/w Churning and Unresolved Tickets
=====================================================*/
WITH churn_flag AS (
    SELECT 
        c.customer_id,
        CASE 
            WHEN s.status IN ('inactive', 'canceled') AND 
                 DATEDIFF(DAY, MAX(p.usage_date), '2024-06-30') > 30 THEN 1
            ELSE 0
        END AS churned_flg
    FROM customers c
    LEFT JOIN subscription s ON c.customer_id = s.customer_id
    LEFT JOIN product_usage p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, s.status
),
unresolved_tickets AS (
	SELECT 
		customer_id, COUNT(ticket_id) AS unresolved_ticket_count
	FROM support_tickets
	WHERE resolved_date IS NULL
	GROUP BY customer_id
)
SELECT 
	cf.customer_id, ISNULL(ut.unresolved_ticket_count, 0) AS unresolved_ticket_count, cf.churned_flg
FROM churn_flag cf
LEFT JOIN unresolved_tickets ut
ON cf.customer_id = ut.customer_id
ORDER BY cf.customer_id;

/* Observation:
The correlation between unresolved_ticket_count and churned_flg is -0.0457, which is very close to 0.
Means, there is virtually no linear relationship between the number of unresolved tickets and whether a customer churned.
*/

/*=====================================================
Analyze churn rate by: Industry, plan type, or location
=====================================================*/
WITH churned_cid AS (
	SELECT
		c.customer_id
	FROM customers c
	LEFT JOIN product_usage p ON c.customer_id = p.customer_id
	LEFT JOIN subscription s ON c.customer_id = s.customer_id
	WHERE s.status IN ('inactive', 'canceled')
	GROUP BY c.customer_id
	HAVING DATEDIFF(DAY, MAX(p.usage_date), DATEFROMPARTS(2024, 6, 30)) > 30
),
churned_cust_details AS (
	SELECT * FROM customers 
	WHERE customer_id IN (SELECT * FROM churned_cid)
)
SELECT * INTO churned_cust_details_tbl
FROM churned_cust_details; -- Churned Customer Details Table Created.

-- By Industry
SELECT
	industry, COUNT(customer_id) AS churned_cust_count,
	ROUND(100.0 * COUNT(customer_id) * 1.0 / SUM(COUNT(customer_id)) OVER(), 2) AS total_churned
FROM churned_cust_details_tbl
GROUP BY industry
ORDER BY churned_cust_count DESC;
/* Observation:
E-commerce topped the list, while Fintech being the least
*/
	
-- By Plan
SELECT
	[plan], COUNT(customer_id) AS churned_cust_count,
	ROUND(100.0 * COUNT(customer_id) * 1.0 / SUM(COUNT(customer_id)) OVER(), 2) AS total_churned
FROM churned_cust_details_tbl
GROUP BY [plan]
ORDER BY churned_cust_count DESC;
/* Observation:
Enterprise subscription plan customers are most likely to churn followed by Basic and Pro
*/

-- By Location
SELECT
	[location], COUNT(customer_id) AS churned_cust_count,
	ROUND(100.0 * COUNT(customer_id) * 1.0 / SUM(COUNT(customer_id)) OVER(), 2) AS total_churned
FROM churned_cust_details_tbl
GROUP BY [location]
ORDER BY churned_cust_count DESC;
/* Observation:
Customers from Berlin have mostly churned, while Bangalore customers are the most loyal
*/