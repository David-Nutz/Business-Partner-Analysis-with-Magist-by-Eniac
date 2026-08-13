use magist;

-- revenue sellers
SELECT COUNT(DISTINCT seller_id) AS All_Sellers,
COUNT(DISTINCT CASE
WHEN products.product_category_name IN(
    'telefonia',
    'tablets_impressao_imagem',
    'pcs',
    'informatica_acessorios',
    'audio',
    'eletronicos',
    'consoles_games',
    'pc_gamer')
    THEN seller_id END) AS Tech_Sellers,
ROUND(SUM(price), 0) AS revenue_all_sellers,
ROUND(SUM(CASE
WHEN products.product_category_name IN(
    'telefonia',
    'tablets_impressao_imagem',
    'pcs',
    'informatica_acessorios',
    'audio',
    'eletronicos',
    'consoles_games',
    'pc_gamer')
    THEN price
    ELSE 0
END), 0) AS revenue_tech_sellers
FROM order_items
LEFT JOIN products
	on products.product_id = order_items.product_id;

-- Categories
SELECT pt.product_category_name_english AS category,
	ROUND(SUM(oi.price), 0) AS revenue,
	'Tech' AS category_type
 FROM order_items oi
 JOIN products p 
	ON oi.product_id = p.product_id 
		JOIN product_category_name_translation pt 
			ON p.product_category_name = pt.product_category_name 
            WHERE pt.product_category_name_english 
            IN ( 'audio', 'consoles_games', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony' )
            GROUP BY pt.product_category_name_english UNION ALL
            SELECT category, revenue, 'Non-Tech' AS category_type
            FROM ( SELECT pt.product_category_name_english AS category, ROUND(SUM(oi.price), 0) AS revenue
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
            WHERE pt.product_category_name_english NOT IN 
            ( 'audio', 'consoles_games', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony' )
            GROUP BY pt.product_category_name_english 
            ORDER BY revenue DESC LIMIT 8 ) AS top_non_tech
            ORDER BY revenue DESC;
            

    -- Expensive vs not expensive (Tech and Others)
SELECT
CASE
	WHEN product_category_name_english IN ("computers", "pc_gamer","computers_accessories", "electronics", "telephony")
    THEN "Tech"
    ELSE "Other"
END AS category_group,
CASE
    WHEN order_items.price > (SELECT AVG(price) FROM order_items)
    THEN 'Expensive'
    ELSE 'Not Expensive'
END AS price_group,
COUNT(*) AS products_sold
FROM products
JOIN product_category_name_translation
    ON products.product_category_name
       = product_category_name_translation.product_category_name
JOIN order_items
    ON products.product_id = order_items.product_id
GROUP BY category_group, price_group;

-- total sellers
SELECT COUNT(DISTINCT seller_id) FROM sellers;


-- Tech sellers

SELECT COUNT(DISTINCT sellers.seller_id)
 FROM sellers 
 INNER JOIN order_items 
	ON sellers.seller_id = order_items.seller_id 
INNER JOIN products
    ON order_items.product_id = products.product_id 
INNER JOIN product_category_name_translation 
	ON products.product_category_name = product_category_name_translation.product_category_name 
WHERE product_category_name_english IN 
( 'audio', 'consoles_games', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');

-- total orders

SELECT COUNT(order_item_id) FROM order_items;

#tech orders

SELECT COUNT(*)
FROM order_items
LEFT JOIN products ON order_items.product_id = products.product_id
LEFT JOIN product_category_name_translation
ON products.product_category_name = product_category_name_translation.product_category_name
WHERE product_category_name_english IN 
( 'audio', 'consoles_games', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');


-- Delivery process

SELECT
	CASE WHEN DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date) > 0
        THEN 'Delayed'
        ELSE 'On Time'
    END AS Delivery_Status,
    ROUND(AVG(DATEDIFF(
                order_approved_at,
                order_purchase_timestamp)),1)
                AS Avg_Order_Placement_to_Approval,
    ROUND(AVG(DATEDIFF(
                order_delivered_carrier_date,
                order_approved_at)),1)
                AS Avg_Approval_to_Carrier,
	ROUND(AVG(DATEDIFF(
                order_delivered_customer_date,
                order_delivered_carrier_date)),1)
                AS Avg_Carrier_to_Customer
FROM orders
GROUP BY CASE
        WHEN DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date) > 0
        THEN 'Delayed'
        ELSE 'On Time'
    END;
    



