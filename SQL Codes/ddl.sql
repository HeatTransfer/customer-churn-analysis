
CREATE DATABASE churnDB;

-- -------------------------------------------------------------------
-- Create Tables (DDL Statements)
-- -------------------------------------------------------------------
-- ['customer_id', 'name', 'signup_date', 'industry', 'plan', 'location']
CREATE TABLE customers ( 
	id INT PRIMARY KEY, 
	[name] VARCHAR(50), 
	signup_date DATE, 
	industry VARCHAR(30),
	[plan] VARCHAR(30), 
	[location] VARCHAR(30) 
);
-- ['customer_id', 'usage_date', 'features_used', 'minutes_spent', 'errors_reported']
CREATE TABLE product_usage (
	customer_id INT NOT NULL,
	usage_date DATE,
	features_used VARCHAR(30),
	minutes_spent FLOAT,
	errors_reported INT,
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);
-- ['customer_id', 'subscription_id', 'start_date', 'end_date', 'status', 'payment_method']
CREATE TABLE subscription (
	customer_id INT NOT NULL,
	id VARCHAR(30) PRIMARY KEY,
	[start_date] DATE,
	[end_date] DATE,
	[status] VARCHAR(30),
	payment_method VARCHAR(30),
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);
-- ['ticket_id', 'customer_id', 'issue_type', 'opened_date', 'resolved_date', 'satisfaction_score']
CREATE TABLE support_tickets (
	id VARCHAR(20) PRIMARY KEY,
	customer_id INT NOT NULL,
	issue_type VARCHAR(50),
	opened_date DATE,
	resolved_date DATE,
	satisfaction_score INT,
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);