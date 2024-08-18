/* 1) Retrieve the total number of orders placed.*/
SELECT count(*) as total_orders
from orders

/* 2) Calculate the total revenue generated from pizza sales.*/
select SUM(o.quantity*p.price) as total_revenue
from order_details o
join pizzas p on o.pizza_id = p.pizza_id

/* 3) Identify the highest-priced pizza.*/
select pizza_id,pizza_type_id,size,Max(price) as highest_price 
from pizzas

/* 4) Identify the most common pizza size ordered.*/
SELECT p.size,count(size) as common_pizza_size
FROM order_details o
join pizzas p on o.pizza_id = p.pizza_id
group by size
LIMIT 1

/* 5) List the top 5 most ordered pizza types along with their quantities.*/
SELECT name,sum(o.quantity) as quantity
FROM pizzas p
join order_details o on o.pizza_id = p.pizza_id
join pizza_types t on p.pizza_type_id = t.pizza_type_id
group by name
order by quantity desc
LIMIT 5

/* 6) Find the total quantity of each pizza category ordered.*/
SELECT category,sum(o.quantity) as quantity
FROM pizzas p
join order_details o on o.pizza_id = p.pizza_id
join pizza_types t on p.pizza_type_id = t.pizza_type_id
group by category
order by quantity desc

/* 7) Determine the distribution of orders by hour of the day.*/
SELECT strftime('%H',time) as time, COUNT(order_id) AS distribution_of_orders
FROM orders 
group by strftime('%H',time) 
order by COUNT(order_id) DESC

/* 8) Calculate the average number of pizzas ordered per day.*/
select round(avg(quantity),2) as average_orders_per_day 
from (select sum(quantity) as quantity,date
from orders o
join order_details d on o.order_id = d.order_id
group by date)

/* 9) Determine the top 3 most ordered pizza types based on revenue.*/
select t.name as pizza_type, SUM(o.quantity*p.price) as total_revenue
from order_details o
join pizzas p on o.pizza_id = p.pizza_id
join pizza_types t on p.pizza_type_id = T.pizza_type_id
group by t.name
order by SUM(o.quantity*p.price) desc
limit 3

/* 10) Calculate the percentage contribution of each pizza type to total revenue.*/
with sal as( select SUM(o.quantity*p.price) as total_revenue
from order_details o
join pizzas p on o.pizza_id = p.pizza_id
join pizza_types t on p.pizza_type_id = T.pizza_type_id)

select t.category as type, round((SUM(o.quantity*p.price)/s.total_revenue)*100,2) as percentage_contribution
from order_details o
join pizzas p on o.pizza_id = p.pizza_id
join pizza_types t on p.pizza_type_id = T.pizza_type_id
join sal s 
group by type
order by percentage_contribution desc

/* 11) Analyze the cumulative revenue generated over time.*/
select date,round(sum(revenue) over(order by date),2) as cummulative_revenue
from
(select date,SUM(o.quantity*p.price) as revenue
from order_details o
join pizzas p on o.pizza_id = p.pizza_id
join orders t on o.order_id = T.order_id
group by date)

/* 12) Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
with sal as(select pizza_type,category,total_revenue,rank() over(partition by category order by total_revenue desc) as n
from
(select t.name as pizza_type,category, SUM(o.quantity*p.price) as total_revenue
from order_details o
join pizzas p on o.pizza_id = p.pizza_id
join pizza_types t on p.pizza_type_id = T.pizza_type_id
group by t.name,category))

select pizza_type,category 
from sal
where n <= 3


