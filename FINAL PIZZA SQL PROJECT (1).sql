CREATE DATABASE PIZZAHUT


Select * from orders;
select * from orders_details;
select * from pizza_types;
select * from pizzas;

-- Retrive the total number of orders placed 

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types 
-- Along with their quantities.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS total_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_orders DESC
LIMIT 5;

-- Join the necessary tables to find the total 
-- quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time); 

-- Join relevant tables to find the 
-- category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the
-- Average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each 
-- pizza type to total revenue.

SELECT 
    pizza_types.category,
    round(SUM(orders_details.quantity * pizzas.price)  / 
    (select round(SUM(orders_details.quantity * pizzas.price),2) AS total_sales
FROM
    orders_details 
        JOIN
    pizzas ON  pizzas.pizza_id = orders_details.pizza_id ) * 100 , 2 ) as revenue 
    from pizza_types join pizzas
    on pizza_types.pizza_type_id = pizzas.pizza_type_id 
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.

SELECT 
    order_date, 
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue 
FROM (
    SELECT 
        o.order_date, 
        SUM(od.quantity * p.price) AS revenue 
    FROM 
        orders_details od 
    JOIN pizzas p ON od.pizza_id = p.pizza_id 
    JOIN orders o ON o.order_id = od.order_id 
    GROUP BY 
        o.order_date
) AS Sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    name, 
    revenue 
FROM (
    SELECT 
        pt.category, 
        pt.name, 
        SUM(od.quantity * p.price) AS revenue, 
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn 
    FROM 
        pizza_types pt 
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
    JOIN orders_details od ON od.pizza_id = p.pizza_id 
    GROUP BY 
        pt.category, 
        pt.name
) AS ranked_pizzas 
WHERE rn <= 3;
