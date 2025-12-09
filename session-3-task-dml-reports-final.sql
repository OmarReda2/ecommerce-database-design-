-- * Write an SQL query to generate a daily report of the total revenue for a specific date.
	SELECT SUM(od.quantity * od.unit_price) as total_revenue
	FROM order_details od
	JOIN orders o ON od.order_id = o.id
	where order_date::date = '2025-11-01'


-- * Write an SQL query to generate a monthly report of the top-selling products in a given month.
	-- SELECT p.id, p.name, count(od.quantity) AS most_sold
	SELECT p.id, p.name, SUM(od.quantity) AS most_sold
	FROM order_details od
	JOIN orders o ON od.order_id = o.id
	JOIN products p ON od.product_id = p.id
	WHERE o.order_date::date >= '2025-11-01'
	  And o.order_date::date <= '2025-12-01'
	GROUP BY p.name, p.id
	ORDER BY most_sold DESC
	
	
-- * Write a SQL query to retrieve a list of customers who have placed orders totaling more than $500 in the past month. 
--   Include customer names and their total order amounts. [Complex query].
	SELECT c.id, c.first_name, c.last_name, SUM(total_amount) as total_orders
	FROM orders o
	JOIN customers c ON c.id = o.customer_id
	WHERE o.order_date::date >= '2025-11-01'
	GROUP BY c.id, c.first_name, c.last_name
	  And o.order_date::date <= '2025-12-01'
	HAVING total_orders > 500

	
-- * How we can apply a denormalization mechanism on customer and order entities
----> 1- create new table with combined columns and from customer and order tables, 
CREATE TABLE customers_orders_denormalized (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20),
    email VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
	order_id UUID DEFAULT gen_random_uuid(),
	order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount > 0)
);

----> 2- insert query join from customer and order (pre-computed) in the new table
INSERT INTO customers_orders_denormalized (
    customer_id, first_name, last_name, email, order_id, order_date, total_amount
)
select c.id, c.first_name, c.last_name, c.email, c.password, o.id, o.order_date, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id