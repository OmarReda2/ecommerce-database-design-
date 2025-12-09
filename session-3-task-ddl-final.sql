-- * Create the DB schema script with the following entities 
-- * Identify the relationships between entities


-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- Order details table
CREATE TABLE order_details (
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    quantity SMALLINT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(8,2) NOT NULL,
    
    CONSTRAINT pk_order_product PRIMARY KEY (order_id, product_id)
);
