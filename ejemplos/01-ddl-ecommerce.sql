-- E-commerce mínimo pero realista
-- Pegar esto en el tab "DDL / SQL" del modal "Mi BD"

CREATE TABLE customers (
  id            UUID PRIMARY KEY,
  email         VARCHAR(255) UNIQUE NOT NULL,
  full_name     VARCHAR(255),
  phone         VARCHAR(50),
  created_at    TIMESTAMP DEFAULT NOW(),
  is_active     BOOLEAN DEFAULT TRUE
);

CREATE TABLE products (
  id            UUID PRIMARY KEY,
  sku           VARCHAR(50) UNIQUE NOT NULL,
  name          VARCHAR(255) NOT NULL,
  description   TEXT,
  price         DECIMAL(10,2) NOT NULL,
  stock         INTEGER DEFAULT 0,
  category      VARCHAR(100),
  created_at    TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
  id            UUID PRIMARY KEY,
  customer_id   UUID REFERENCES customers(id),
  status        VARCHAR(50) NOT NULL,  -- pending, paid, shipped, delivered, cancelled
  total         DECIMAL(10,2) NOT NULL,
  shipping_addr TEXT,
  notes         TEXT,
  created_at    TIMESTAMP DEFAULT NOW(),
  updated_at    TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
  id            UUID PRIMARY KEY,
  order_id      UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id    UUID REFERENCES products(id),
  quantity      INTEGER NOT NULL,
  unit_price    DECIMAL(10,2) NOT NULL
);

CREATE TABLE payments (
  id            UUID PRIMARY KEY,
  order_id      UUID REFERENCES orders(id),
  amount        DECIMAL(10,2) NOT NULL,
  method        VARCHAR(50),  -- card, cash, transfer
  paid_at       TIMESTAMP,
  metadata      JSONB
);
