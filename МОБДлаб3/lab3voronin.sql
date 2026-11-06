-- 1
SELECT p.title, c.name AS category, s.store_name
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN sellers s ON p.seller_id = s.id;

-- 2
SELECT p.title
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
WHERE r.id IS NULL;

-- 3
SELECT 
    c.name, 
    COUNT(p.id) AS products_count, 
    AVG(p.price) AS avg_price
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name;

-- 4
SELECT 
    s.store_name, 
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM sellers s
JOIN products p ON p.seller_id = s.id
JOIN order_items oi ON oi.product_id = p.id
GROUP BY s.id, s.store_name
HAVING SUM(oi.quantity * oi.unit_price) > 10000;

-- 5.1
SELECT title, price 
FROM products 
WHERE price > (SELECT AVG(price) FROM products);

-- 5.2
SELECT title
FROM products
WHERE category_id IN (
    SELECT id FROM categories WHERE name = 'пк'
);

-- 5.3
SELECT store_name
FROM sellers s
WHERE EXISTS (
    SELECT 1 FROM products p WHERE p.seller_id = s.id
);

-- 6.1
WITH stats AS (
    SELECT seller_id, COUNT(*) AS total
    FROM products
    GROUP BY seller_id
)
SELECT s.store_name, stats.total
FROM stats
JOIN sellers s ON s.id = stats.seller_id;

-- 6.2
WITH RECURSIVE tree AS (
    SELECT id, name, parent_id
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT c.id, c.name, c.parent_id
    FROM categories c
    JOIN tree t ON c.parent_id = t.id
)
SELECT * FROM tree;

-- 7.1
DROP VIEW IF EXISTS seller_stats;
CREATE OR REPLACE VIEW seller_stats AS
SELECT 
    s.store_name, 
    COUNT(p.id) AS products_count
FROM sellers s
LEFT JOIN products p ON p.seller_id = s.id
GROUP BY s.id, s.store_name;

SELECT * FROM seller_stats;

-- 7.2
DROP VIEW IF EXISTS category_stats;
CREATE OR REPLACE VIEW category_stats AS
SELECT 
    c.name, 
    COUNT(p.id) AS products_count, 
    AVG(p.price) AS avg_price
FROM categories c
LEFT JOIN products p ON p.category_id = c.id
GROUP BY c.id, c.name;

SELECT * FROM category_stats;