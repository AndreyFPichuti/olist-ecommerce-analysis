-- 1. Estrutura da tabela central
PRAGMA table_info(orders);

-- 2. Primeiros registros
SELECT * FROM orders LIMIT 5;

-- 3. Status dos pedidos
SELECT order_status, COUNT(*) as total
FROM orders
GROUP BY order_status
ORDER BY total DESC;

-- 4. Período dos dados
SELECT 
    MIN(order_purchase_timestamp) as primeiro_pedido,
    MAX(order_purchase_timestamp) as ultimo_pedido
FROM orders;

-- 5. Relacionamento orders x order_items
SELECT
    o.order_id,
    COUNT(oi.order_item_id) as qtd_itens
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY qtd_itens DESC
LIMIT 5

-- Hipótese 1 -> Cama, mesa e banho é a categoria com maior volume de vendas

SELECT
    pc.product_category_name as categoria,
    COUNT(oi.order_id) as total_vendas,
    SUM(oi.price) as receita_total,
    ROUND(SUM(oi.price) / COUNT(oi.order_id), 2) as ticket_medio
FROM order_items as oi
JOIN products as p ON oi.product_id = p.product_id
JOIN product_category as pc ON p.product_category_name = pc.product_category_name
GROUP BY categoria
ORDER BY ticket_medio DESC
LIMIT 10;

-- Hipótese 2 --> Atraso na entrega impacta avaliação?

SELECT 
    CASE WHEN julianday(o.order_delivered_customer_date) - julianday(order_estimated_delivery_date) > 0 THEN 'Atraso' ELSE 'No prazo' END as status_entrega,
    ROUND(AVG(review_score), 2) as media_avaliacao,
    COUNT(*) as total_pedidos
FROM orders as o
JOIN order_reviews as r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY status_entrega

-- Hipótese 3 --> Produtos com avaliação baixa tem ticket médio maior

SELECT 
    r.review_score as nota,
    ROUND(AVG(oi.price), 2) as ticket_medio,
    COUNT(DISTINCT oi.order_id) as total_pedidos
FROM order_items as oi
JOIN order_reviews as r ON oi.order_id = r.order_id
GROUP BY nota
ORDER BY nota DESC

-- Hipótese 4 --> Vendedores de SP dominam em volume de vendas

SELECT
    s.seller_state as estado,
    COUNT(DISTINCT oi.order_id) as total_vendas
FROM order_items as oi 
JOIN sellers as s ON oi.seller_id = s.seller_id 
GROUP BY estado
ORDER BY total_vendas DESC
LIMIT 10

-- Query Bônus - WINDOWS FUNCTIONS

WITH vendas_por_vendedor AS (
    SELECT
        s.seller_state as estado,
        s.seller_id,
        COUNT(DISTINCT oi.order_id) as total_vendas
    FROM order_items oi
    JOIN sellers s ON oi.seller_id = s.seller_id
    GROUP BY s.seller_state, s.seller_id
)
SELECT
    estado,
    seller_id,
    total_vendas,
    RANK() OVER (PARTITION BY estado ORDER BY total_vendas DESC) as ranking_no_estado,
    ROUND(total_vendas * 100.0 / SUM(total_vendas) OVER (PARTITION BY estado), 2) as pct_do_estado
FROM vendas_por_vendedor
WHERE estado = 'SP'
ORDER BY ranking_no_estado
LIMIT 10;