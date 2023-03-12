 use orders;
 
 # 1st Question

SELECT
    CONCAT(CASE CUSTOMER_GENDER
    WHEN 'M' THEN 'Mr.'
    WHEN 'F' THEN 'Ms.'
    END, ' ',
    UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME)) AS 'Customer Full Name',
    CUSTOMER_EMAIL AS 'Customer Email ID',
    CUSTOMER_CREATION_DATE AS 'Customer Creation Date',
    CASE
        WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B'
        WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'Category C'
    END AS "Customer's Category"
FROM ONLINE_CUSTOMER;

-------------------------------------------------------------------------------------------------------------

# 2nd Question

SELECT product.product_id, 
       product.product_desc, 
       product.product_quantity_avail, 
       product.product_price, 
       (product.product_quantity_avail * product.product_price) AS "Inventory_Value", 
       CASE 
          WHEN product.product_price > 20000 THEN product.product_price * 0.8 
          WHEN product.product_price > 10000 THEN product.product_price * 0.85 
          WHEN product.product_price <= 10000 THEN product.product_price * 0.9 
       END AS "New_Price" 
FROM product 
WHERE product.product_id NOT IN (SELECT order_items.product_id FROM order_items) 
ORDER BY "Inventory_Value" DESC;

-------------------------------------------------------------------------------------------------------------

# 3rd Question

SELECT product_class.product_class_code, 
       product_class.product_class_desc, 
       COUNT(product.product_class_code) AS "Count of Product Type", 
       FORMAT(SUM(product.product_quantity_avail * product.product_price),2) AS "Inventory_Value"
FROM product 
JOIN product_class 
ON product.product_class_code = product_class.product_class_code
GROUP BY product_class.product_class_code, product_class.product_class_desc
HAVING SUM(product.product_quantity_avail * product.product_price) > 100000
ORDER BY "Inventory_Value" DESC;

-------------------------------------------------------------------------------------------------------------

# 4th Question

select c.customer_id as CUSTOMER_ID, CONCAT(c.customer_fname," ",c.customer_lname) as FULL_NAME,
c.customer_email as CUSTOMER_EMAIL, c.customer_phone as CUSTOMER_PHONE,a.country as COUNTRY
from online_customer c, address a,
(select b.customer_id, count(b.order_id) from order_header b
where b.customer_id in (select o1.customer_id from order_header o1
                      where order_status='Cancelled')
group by customer_id
having count(customer_id) = 1) as a
where c.address_id = a.address_id
and c.customer_id = a.customer_id;

-------------------------------------------------------------------------------------------------------------

# 5th Question

SELECT shipper.shipper_name, 
       address.city,
       COUNT(DISTINCT customer.customer_id) AS "Number of Customers",
       COUNT(order_header.order_id) AS "Number of Consignments"
FROM ORDER_HEADER
JOIN ONLINE_CUSTOMER customer ON order_header.customer_id = customer.customer_id
JOIN ADDRESS address ON customer.address_id = address.address_id
JOIN SHIPPER shipper ON order_header.shipper_id = shipper.shipper_id
WHERE shipper.shipper_name = 'DHL'
GROUP BY shipper.shipper_name, address.city;

-------------------------------------------------------------------------------------------------------------

# 6th Question

SELECT
pr.PRODUCT_ID,
pr.PRODUCT_DESC,
pr.PRODUCT_QUANTITY_AVAIL,
po.QUANTITY_SOLD,
CASE
WHEN pc.PRODUCT_CLASS_DESC IN('ELECTRONICS', 'COMPUTER')
THEN
CASE WHEN po.QUANTITY_SOLD = 0
    THEN 'No Sales in past, give discount to reduce inventory'
    WHEN pr.PRODUCT_QUANTITY_AVAIL < (po.QUANTITY_SOLD * 0.10)
THEN  'Low inventory, need to add inventory'
WHEN pr.PRODUCT_QUANTITY_AVAIL >= (po.QUANTITY_SOLD * 0.50)
THEN 'Sufficient inventory'
    END
WHEN pc.PRODUCT_CLASS_DESC IN('MOBILES', 'WATCHES')
THEN
CASE WHEN po.QUANTITY_SOLD = 0
    THEN 'No Sales in past, give discount to reduce inventory'
WHEN pr.PRODUCT_QUANTITY_AVAIL < (po.QUANTITY_SOLD * 0.20)
THEN  'Low inventory, need to add inventory'
WHEN pr.PRODUCT_QUANTITY_AVAIL >= (po.QUANTITY_SOLD * 0.60)
THEN 'Sufficient inventory'
    END
ELSE
CASE WHEN po.QUANTITY_SOLD = 0
    THEN 'No Sales in past, give discount to reduce inventory'
WHEN pr.PRODUCT_QUANTITY_AVAIL < (po.QUANTITY_SOLD * 0.30)
THEN  'Low inventory, need to add inventory'
WHEN pr.PRODUCT_QUANTITY_AVAIL >= (po.QUANTITY_SOLD * 0.70)
THEN 'Sufficient inventory'
    END
END INVENTORY_STATUS
FROM PRODUCT pr
INNER JOIN (
SELECT
pr.PRODUCT_ID,
pr.PRODUCT_DESC,
SUM(COALESCE(oi.PRODUCT_QUANTITY,0)) QUANTITY_SOLD
FROM PRODUCT pr
LEFT JOIN ORDER_ITEMS oi
ON pr.PRODUCT_ID = oi.PRODUCT_ID
GROUP BY pr.PRODUCT_ID, pr.PRODUCT_DESC) po
ON pr.PRODUCT_ID = po.PRODUCT_ID
INNER JOIN PRODUCT_CLASS pc
ON pr.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE;

-------------------------------------------------------------------------------------------------------------

# 7th Question

WITH carton_volume AS (
SELECT 
        carton_id, 
        len * width * height as volume
    FROM 
        carton
    WHERE 
        carton_id = 10
),

order_volume AS (
    SELECT 
        oi.order_id, 
        SUM(p.len * p.width * p.height * oi.product_quantity) as volume
    FROM 
        order_items oi 
        JOIN product p ON oi.product_id = p.product_id
    GROUP BY 
        oi.order_id
)

SELECT 
    ov.order_id, 
    ov.volume
FROM 
    order_volume ov
    JOIN carton_volume cv ON ov.volume <= cv.volume
ORDER BY 
    ov.volume DESC
    limit 1;

-------------------------------------------------------------------------------------------------------------

# 8th Question

SELECT 
  ONLINE_CUSTOMER.CUSTOMER_ID,
  CONCAT(ONLINE_CUSTOMER.CUSTOMER_FNAME, ' ', ONLINE_CUSTOMER.CUSTOMER_LNAME) AS "Customer Full Name",
  SUM(ORDER_ITEMS.PRODUCT_QUANTITY) as "Total Quantity",
  SUM(ORDER_ITEMS.PRODUCT_QUANTITY * PRODUCT.PRODUCT_PRICE) as "Total Value"
FROM ONLINE_CUSTOMER
JOIN ORDER_HEADER ON ONLINE_CUSTOMER.CUSTOMER_ID = ORDER_HEADER.CUSTOMER_ID
JOIN ORDER_ITEMS ON ORDER_HEADER.ORDER_ID = ORDER_ITEMS.ORDER_ID
JOIN PRODUCT ON ORDER_ITEMS.PRODUCT_ID = PRODUCT.PRODUCT_ID
WHERE ORDER_HEADER.PAYMENT_MODE = 'Cash'
AND ONLINE_CUSTOMER.CUSTOMER_LNAME LIKE 'G%'
GROUP BY ONLINE_CUSTOMER.CUSTOMER_ID;

-------------------------------------------------------------------------------------------------------------

# 9th Question

SELECT
product.product_id,
product.product_desc,
SUM(order_items.product_quantity) as total_quantity
FROM order_items
JOIN product ON product.product_id = order_items.product_id
JOIN order_header ON order_header.order_id = order_items.order_id
JOIN online_customer ON order_header.customer_id = online_customer.customer_id
JOIN address ON online_customer.address_id = address.address_id
WHERE order_items.order_id IN (SELECT order_id FROM order_items WHERE product_id = 201)
AND address.city NOT IN ('Bangalore', 'New Delhi')
AND order_items.product_id != 201
AND order_header.order_status = 'Shipped'
GROUP BY product.product_id, product.product_desc
ORDER BY total_quantity DESC;

-------------------------------------------------------------------------------------------------------------

# 10th Question
    
select distinct OH.ORDER_ID, OH.CUSTOMER_ID,
concat(OnlCust.CUSTOMER_FNAME,' ',OnlCust.CUSTOMER_LNAME) as Customer_Full_Name, 
SUM(OI.product_quantity) as Total_Quantity
from online_customer onlCust
inner join address addr on addr.ADDRESS_ID = OnlCust.ADDRESS_ID
inner join order_header OH on OH.CUSTOMER_ID=OnlCust.CUSTOMER_ID
inner join order_items OI on OI.ORDER_ID=OH.ORDER_ID
where OH.ORDER_STATUS = 'Shipped' and (OH.ORDER_ID % 2) = 0 and addr.PINCODE not like '5%'
GROUP BY oh.order_id, oh.customer_id, customer_full_name;

    


