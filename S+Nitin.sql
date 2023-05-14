# 1. Write a query to display customer full name with their title (Mr/Ms),
-- both first name and last name are in upper case, customer email id,
-- customer creation date and display customer’s category after applying below
-- categorization rules:
-- 1) IF customer creation date Year <2005 Then Category A
-- 2) IF customer creation date Year >=2005 and <2011 Then Category B
-- 3) IF customer creation date Year>= 2011 Then Category C
# Hint: Use CASE statement, no permanent change in table required.
# (52 rows)[NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE] 

select case
when CUSTOMER_GENDER = "f" then "Ms"
when CUSTOMER_GENDER = "m" then "Mr"
end as title,
concat (upper(CUSTOMER_FNAME)," ",upper(CUSTOMER_LNAME))as Fullname,CUSTOMER_CREATION_DATE,CUSTOMER_EMAIL,
case 
when CUSTOMER_CREATION_DATE < '2005-01-01' then 'Category A'
when CUSTOMER_CREATION_DATE >= '2005-01-01' and CUSTOMER_CREATION_DATE < '2011-01-01' then 'Category B'
when CUSTOMER_CREATION_DATE >= '2011-01-01' then 'Category C'
end as Catagory
from online_customer;


#2. Write a query to display the following information for the products, which have not been sold:
-- product_id, product_desc, product_quantity_avail, product_price, inventory values
-- (product_quantity_avail*product_price), New_Price after applying discount as per below criteria.
-- Sort the output with respect to decreasing value of Inventory_Value.
-- 1) IF Product Price > 200,000 then apply 20% discount
-- 2) IF Product Price > 100,000 then apply 15% discount
-- 3) IF Product Price =< 100,000 then apply 10% discount
# Hint: Use CASE statement, no permanent change in table required.
# (13 rows)[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] 

select p.PRODUCT_ID,p.PRODUCT_DESC,p.PRODUCT_QUANTITY_AVAIL,p.PRODUCT_PRICE,p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE as inventory_values,
case
when p.PRODUCT_PRICE > 200.000 then p.PRODUCT_PRICE*0.80
when p.PRODUCT_PRICE > 100.000 then p.PRODUCT_PRICE*0.85
when p.PRODUCT_PRICE <= 100.000 then p.PRODUCT_PRICE*0.90
end as new_price
from product p inner join order_items o
on p.PRODUCT_ID=o.PRODUCT_ID
group by PRODUCT_ID
ORDER BY PRODUCT_QUANTITY_AVAIL DESC;


#3. Write a query to display Product_class_code, Product_class_description, Count of Product type in each product
-- class, Inventory Value (p.product_quantity_avail*p.product_price). Information should be
-- displayed for only those product_class_code which have more than 1,00,000 
-- Inventory Value. Sort the output with respect to decreasing value of Inventory_Value.
# (9 rows)[NOTE: TABLES to be used - PRODUCT_CLASS, PRODUCT_CLASS_CODE] 
select * from product_class;

select pr.PRODUCT_CLASS_CODE,pr.PRODUCT_CLASS_DESC,count(pr.PRODUCT_CLASS_CODE) as Product_count,
sum(pro.PRODUCT_PRICE*pro.PRODUCT_QUANTITY_AVAIL) as Inventory_value
from  product pro left join  product_class pr
on pro.PRODUCT_CLASS_CODE = pr.PRODUCT_CLASS_CODE
group by pr.PRODUCT_CLASS_CODE
having Inventory_value > 100000
order by Inventory_value desc;


#4. Write a query to display customer_id, full name, customer_email, customer_phone and country of customers who
-- have cancelled all the orders placed by them
-- (USE SUB-QUERY)
-- (1 row)[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS,OREDER_HEARDER] 

select * from order_header;

select oh.CUSTOMER_ID,concat(upper(oc.CUSTOMER_FNAME)," ",upper(oc.CUSTOMER_LNAME)) as full_name,oc.CUSTOMER_EMAIL,oc.CUSTOMER_PHONE,a.COUNTRY
from online_customer oc join order_header oh using (CUSTOMER_ID) join address a using (ADDRESS_ID)
where oh.customer_id in  (select customer_id from order_header where order_status='Cancelled')
group by oh.customer_id having count(distinct oh.order_status)=1;

#5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the
-- shipper in the city and number of consignments delivered to that city for Shipper DHL
-- (9 rows)[NOTE: TABLES to be used - SHIPPER,ONLINE_CUSTOMER, ADDRESSS,OREDER_HEARDER] 

select * from online_customer;
select * from order_header;
select * from address;
select * from shipper;

select s.SHIPPER_NAME,a.CITY, count(distinct(oh.CUSTOMER_ID)) as CUSTOMER_CATERED, count(a.CITY) as CONSIGNMENTS_DELIVERED
from address a join online_customer oc using (ADDRESS_ID) join order_header oh using (CUSTOMER_ID) join shipper s using (SHIPPER_ID)
where s.SHIPPER_NAME in (select s.SHIPPER_NAME from shipper where s.SHIPPER_NAME='DHL')
group by CITY;

-- 6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold, 
-- quantity available and show inventory Status of products as below as per below condition:

-- a. For Electronics and Computer categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
-- if inventory quantity is less than 10% of quantity sold,show 'Low inventory, need to add inventory', if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, 
-- need to add some inventory', if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

-- b. For Mobiles and Watches categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 20% of quantity sold, 
-- show 'Low inventory, need to add inventory', if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
-- if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

-- c. Rest of the categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 30% of quantity sold,
-- show 'Low inventory, need to add inventory', if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory', 

-- if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory' -- (USE SUB-QUERY) --
--  [NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS,
select * from product;
select * from product_class;
select * from order_items;

select p.PRODUCT_ID, p.PRODUCT_DESC, sum(p.PRODUCT_QUANTITY_AVAIL) as PRODUCT_QUANTITY_AVAIL, sum(ifnull(oi.PRODUCT_QUANTITY,0)) as QUANTITY_SOLD, 
sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0)) as AVAILABLE_QUANTITY,
case when sum(ifnull(oi.PRODUCT_QUANTITY,0))  = 0 then 'No Sales in past, give discount to reduce inventory'
when pc.product_class_desc = 'Electronics' or pc.product_class_desc = 'Computer' then 
	case when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.1 * sum(ifnull(oi.PRODUCT_QUANTITY,0))  then 'Low inventory, need to add inventory'
		 when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.5 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Medium inventory, need to add some inventory'
         when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) >= 0.5 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Sufficient inventory'
	end 
when pc.product_class_desc = 'Mobiles' or pc.product_class_desc = 'Watches' then 
	case  when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.2 * sum(ifnull(oi.PRODUCT_QUANTITY,0))  then 'Low inventory, need to add inventory'
		  when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.6 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Medium inventory, need to add some inventory'
          when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) >= 0.6 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Sufficient inventory'
	end 
when pc.product_class_desc != 'Mobiles' or pc.product_class_desc = !'Watches' or pc.product_class_desc != 'Electronics' or pc.product_class_desc != 'Computer' then 
	case  when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.3 * sum(ifnull(oi.PRODUCT_QUANTITY,0))  then 'Low inventory, need to add inventory'
		  when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) < 0.7 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Medium inventory, need to add some inventory'
          when  (sum(p.PRODUCT_QUANTITY_AVAIL) - sum(ifnull(oi.PRODUCT_QUANTITY,0))) >= 0.7 * sum(ifnull(oi.PRODUCT_QUANTITY,0)) then 'Sufficient inventory'
	end 
end as INVENTORY_STATUS
from  product as p
left join product_class as pc on p.product_class_code = pc.product_class_code
left join order_items as oi on p.product_id = oi.product_id
group by p.product_id
order by PRODUCT_ID asc;



-- 7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 
-- [NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
select * from carton;

select oi.ORDER_ID,sum(oi.PRODUCT_QUANTITY*p.LEN*p.WIDTH*p.HEIGHT) as product_volume
from product p join order_items oi
on p.PRODUCT_ID = oi.PRODUCT_ID
group by oi.ORDER_ID
having product_volume < ( select LEN*WIDTH*HEIGHT from carton where CARTON_ID=10)
order by product_volume desc;


-- 8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where 
-- mode of payment is Cash and customer last name starts with 'G' 
-- [NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
select * from online_customer;
select * from order_header;
select * from order_items;

select oc.CUSTOMER_ID,concat(oc.CUSTOMER_FNAME," ",oc.CUSTOMER_LNAME) as customer_full_name,sum(oi.PRODUCT_QUANTITY) as total_quantatity,sum(oi.PRODUCT_QUANTITY*p.PRODUCT_PRICE) as total_value
from online_customer oc join order_header oh using (CUSTOMER_ID) join order_items oi using (ORDER_ID) join product p using (PRODUCT_ID)
where PAYMENT_MODE='Cash' and oc.CUSTOMER_LNAME like 'g%'
group by customer_full_name;


-- 9. Write a query to display product_id, product_desc and total quantity of products which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
-- Display the output in descending order with respect to the tot_qty. -- 
-- (USE SUB-QUERY) -- [NOTE: TABLES to be used - order_items, product,order_head, online_customer, address]

select p.PRODUCT_ID,p.PRODUCT_DESC,sum(oi.PRODUCT_QUANTITY) as total_quantity,oi.ORDER_ID
from online_customer oc join order_header oh using (CUSTOMER_ID) join order_items oi using (ORDER_ID) join product p using (PRODUCT_ID)
where oi.ORDER_ID in
(select ORDER_ID from order_items oi join order_header oh using (ORDER_ID) join online_customer oc using (CUSTOMER_ID) join address a using (ADDRESS_ID)
where PRODUCT_ID='201' and a.CITY!="bangalore" and a.CITY!='delhi')
group by ORDER_ID
order by total_quantity desc;


-- 10. Write a query to display the order_id,customer_id and customer fullname, 
-- total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5"
-- [NOTE: TABLES to be used - online_customer,Order_header, order_items,address]

select oh.ORDER_ID,oc.CUSTOMER_ID,concat(oc.CUSTOMER_FNAME," ",oc.CUSTOMER_LNAME) as customer_full_name,sum(oi.PRODUCT_QUANTITY) as total_quantaty
from product p join order_items oi using (PRODUCT_ID) join order_header oh using (ORDER_ID) join online_customer oc using (CUSTOMER_ID) join address a using(ADDRESS_ID)
where oh.ORDER_ID % 2=0 and a.PINCODE not like'5%'
group by oc.CUSTOMER_ID

  