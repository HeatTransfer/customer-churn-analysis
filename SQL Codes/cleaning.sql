SELECT * FROM customers where customer_id=1;
SELECT * FROM product_usage where customer_id=1 order by usage_date;
SELECT * FROM subscription where customer_id=1;
SELECT * FROM support_tickets;

-- Some Cleaning operations in SQL Engine

/* need to do this, because sqlalchemy forces the column to store
datetime object in if_exists='replace' mode - it recreates the schema
automatically */

ALTER TABLE customers
ALTER COLUMN signup_date DATE;

ALTER TABLE product_usage
ALTER COLUMN usage_date DATE;

ALTER TABLE subscription
ALTER COLUMN [start_date] DATE;

ALTER TABLE subscription
ALTER COLUMN [end_date] DATE;

ALTER TABLE support_tickets
ALTER COLUMN [opened_date] DATE;

ALTER TABLE support_tickets
ALTER COLUMN [resolved_date] DATE;


UPDATE customers
SET signup_date = CAST(signup_date AS DATE);

UPDATE product_usage
SET usage_date = CAST(usage_date AS DATE);

UPDATE subscription
SET [start_date] = CAST([start_date] AS DATE);

UPDATE subscription
SET [end_date] = CAST([end_date] AS DATE);

UPDATE support_tickets
SET [opened_date] = CAST([opened_date] AS DATE);

UPDATE support_tickets
SET [resolved_date] = CAST([resolved_date] AS DATE);

/*
On close observation, we found some discrepancies in 'status' column.
Some records, even having an 'end_date', are marked as 'status' = 'active'.
N.B. We're considering 'inactive' users as users who had an subscription for at least 6 Months and
the rest as 'cancelled'
*/
UPDATE subscription
SET [status] = 'inactive'
WHERE [end_date] < '2024-06-30' AND DATEDIFF(DAY, [start_date], [end_date]) > 180;

UPDATE subscription
SET [status] = 'canceled'
WHERE [end_date] IS NOT NULL AND DATEDIFF(DAY, [start_date], [end_date]) < 180;

UPDATE subscription
SET [status] = 'active'
WHERE [end_date] > '2024-06-30' OR [end_date] IS NULL;

-- any usage_date in product_usage table can't be earlier than signup_date in customers table
UPDATE p
SET p.usage_date = 
    CASE 
        WHEN c.signup_date > p.usage_date THEN c.signup_date 
        ELSE p.usage_date 
    END
FROM product_usage p
JOIN customers c ON p.customer_id = c.customer_id;

-- any start_date in subscription table can't be earlier than earliest usage_date in product_usage table
WITH min_usage AS (
    SELECT 
        customer_id, 
        MIN(usage_date) AS earliest_usage
    FROM product_usage
    GROUP BY customer_id
)
UPDATE s
SET s.start_date = 
    CASE 
        WHEN m.earliest_usage > s.start_date THEN m.earliest_usage
        ELSE s.start_date
    END
FROM subscription s
JOIN min_usage m ON s.customer_id = m.customer_id;

-- subscription end_date cannot be earlier than start_date
UPDATE subscription
SET end_date = 
    CASE 
        WHEN end_date < start_date AND status = 'inactive' THEN DATEADD(MONTH, 7, start_date)
		WHEN end_date < start_date AND status = 'canceled' THEN DATEADD(MONTH, 3, start_date)
        ELSE end_date 
    END;

