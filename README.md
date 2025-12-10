## E‑Commerce Database Design

This project provides a production‑ready e‑commerce database schema with a focus on scalability, data integrity, and performance. The design is informed by concepts and best practices from _**Practical Web Database Design Book**_ by **Chris Auld**.

### Key Highlights

-   **Structured schema** covering products, customers, orders, payments, and inventory
    
-   **Performance techniques** including normalization, indexing, and query optimization
    
-   **Transactional integrity** for order processing and payment workflows
    
-   **Extensible design** adaptable for promotions, analytics, or multi‑vendor marketplaces
    
-   **Reference architecture** for developers and students building modern web applications

>  ### 1.  DB schema script
> 
> ### 2. Identify the relationships between entities


 ```sql  
    -- Enable UUID generation
 
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    
    -- Categories table
    CREATE TABLE categories (
        id UUID PRIMARY K
    
    EY DEFAULT gen_random_uuid(),
        name VARCHAR(20) NOT NULL,
        parent_category UUID NULL,
        CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category) REFERENCES categories(id)
    );
    
    -- Products table
    CREATE TABLE products (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
        name VARCHAR(20) NOT NULL,
        description VARCHAR(250),
        price NUMERIC(8,2) NOT NULL CHECK (price >= 0),
        stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
    );
    
    -- Customers table
    CREATE TABLE customers (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        first_name VARCHAR(20) NOT NULL,
        last_name VARCHAR(20),
        email VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL
    );
    
    -- Orders table
    CREATE TABLE orders (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
        order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount > 0)
    );
```

> ### 3. ERD diagram of this sample schema

<img width="1556" height="734" alt="session-3-task-erd" src="https://github.com/user-attachments/assets/124afcb7-2f72-4629-8029-477e01d89156" />

### Category and Product Relations

 - [x] each category contains one or more products
 - [x] each product belongs to one or more categories

### Order and Product Relations 

 - [x] each product can be ordered by zero, one, or more orders
 - [x] each order is an order for one or more products

### Category and Subcategory

 - [x] each category can contain zero, one, or more (sub )categories

### Order and Customer

 - [x] each customer orders zero, one, or more orders
 - [x] each order is ordered by exactly one customer"

> ### 4. SQL query to generate a daily report of the total revenue for a specific date
 ```sql  
    SELECT SUM(od.quantity * od.unit_price) as total_revenue
    FROM order_details od
    JOIN orders o ON od.order_id = o.id
    where order_date::date = '2025-11-01'
 ```

> ### 5. SQL query to generate a monthly report of the top-selling products in a given month.

 ```sql  
	SELECT p.id, p.name, SUM(od.quantity) AS most_sold
	FROM order_details od
	JOIN orders o ON od.order_id = o.id
	JOIN products p ON od.product_id = p.id
	WHERE o.order_date::date >= '2025-11-01'
	  And o.order_date::date <= '2025-12-01'
	GROUP BY p.name, p.id
	ORDER BY most_sold DESC
 ```
> ###  6. SQL query to retrieve a list of customers who have placed orders totaling more than $500 in the past month.  Include customer names andtheir total order amounts. [Complex query].
 ```sql  
	SELECT c.id, c.first_name, c.last_name, SUM(total_amount) as total_orders
	FROM orders o
	JOIN customers c ON c.id = o.customer_id
	WHERE o.order_date::date >= '2025-11-01'
	GROUP BY c.id, c.first_name, c.last_name
	  And o.order_date::date <= '2025-12-01'
	HAVING total_orders > 500
 ```

> ### 7. Apply a denormalization mechanism on customer and order entities
> 
> #### a. create new table with combined columns and from customer and order tables,
 ```sql  
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
 ```

> #### b. insert query join from customer and order (pre-computed) in the new table
 ```sql  
    INSERT INTO customers_orders_denormalized (
        customer_id, first_name, last_name, email, order_id, order_date, total_amount
    )
    select c.id, c.first_name, c.last_name, c.email, c.password, o.id, o.order_date, o.total_amount
    FROM orders o
    JOIN customers c ON o.customer_id = c.id
 ```

> ### 8. SQL query to search for all products with the word "camera" in either 
 ```sql  
    SELECT *
    FROM products p
    WHERE p.name LIKE '%camera%' OR p.description LIKE '%camera%'
 ```

> ### 9.  Query to suggest popular products in the same category for the same author, excluding the Purchsed product from the recommendations
 ```sql  
    SELECT COUNT(od.product_id) as product_count, prod.name as product_name
    FROM order_details od
    INNER JOIN products prod ON od.product_id = prod.id
    INNER JOIN categories cat ON prod.category_id = cat.id
    INNER JOIN orders o ON od.order_id = o.id
    WHERE cat.name = 'recommended Category' 
    	-- AND o.customer_id <> 'customerId' 
    	    AND od.product_id NOT IN (   
            SELECT od2.product_id
            FROM order_details od2
            JOIN orders o2 ON od2.order_id = o2.id
            WHERE o2.customer_id = 'customerId'
        )
    GROUP BY od.product_id, prod.name 
    ORDER BY product_count desc
 ```
