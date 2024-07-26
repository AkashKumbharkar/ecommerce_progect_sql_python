create database ecommerce;
use ecommerce;
show tables;

desc customers;
desc geolocation;
desc order_items;
desc orders;
desc payments;
desc products;
describe sellers;

--  List all unique cities where customers are located.
select distinct customer_city from customers ; 

--  Count the number of orders placed in 2017.
select count(order_id) from orders where extract(year from order_estimated_delivery_date) = 2017;

--  Find the total sales per category.
select upper(products.product_category) as category, 
round(sum(payments.payment_value),2) as sales
from products join order_items 
on products.product_id = order_items.product_id
join payments 
on payments.order_id = order_items.order_id
group by category

--  Calculate the percentage of orders that were paid in installments.
select ((sum(case when payment_installments >= 1 then 1
else 0 end))/count(*))*100 as percent_of_order_by_installment from payments;

-- 5. Count the number of customers from each state.
select customer_state as state,count(customer_id) as count_of_customer from customers
group by customer_state;

--  Calculate the number of orders per month in 2018.
select monthname(order_delivered_customer_date) month ,count(order_id) count_of_order from orders
where extract(year from order_delivered_customer_date) = 2018
group by monthname(order_delivered_customer_date) , extract(month from order_delivered_customer_date)
order by extract(month from order_delivered_customer_date) asc

--  Find the average number of products per order, grouped by customer city.

with count_per_order as 
(select orders.order_id, orders.customer_id, count(order_items.order_id) as oc
from orders join order_items
on orders.order_id = order_items.order_id
group by orders.order_id, orders.customer_id)

select customers.customer_city, round(avg(count_per_order.oc),2) average_orders
from customers join count_per_order
on customers.customer_id = count_per_order.customer_id
group by customers.customer_city order by average_orders desc

-- Calculate the percentage of total revenue contributed by each product category.

select upper(products.product_category) category, 
round((sum(payments.payment_value)/(select sum(payment_value) from payments))*100,2) sales_percentage
from products join order_items 
on products.product_id = order_items.product_id
join payments 
on payments.order_id = order_items.order_id
group by category 
order by sales_percentage desc

-- Identify the correlation between product price and the number of times a product has been purchased.

select products.product_category, 
count(order_items.product_id),
round(avg(order_items.price),2)
from products join order_items
on products.product_id = order_items.product_id
group by products.product_category

