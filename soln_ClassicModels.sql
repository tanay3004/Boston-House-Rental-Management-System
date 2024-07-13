use classicmodels;

/* 1 */
select count(*) as TotalCustomers
from customers
where city='NYC';

/* 2 */
select count(priceEach) as NotNullPriceValue
from orderdetails
where productCode = 'S24_3969' and priceEach is Not Null;

/* 3 */
select count(DISTINCT priceEach) as NotNullPriceValue
from orderdetails
where productCode = 'S24_3969' and priceEach  is Not Null;

/* 4 */
select productCode, sum(quantityordered) as TotalQuantityOrdered
from orderdetails
where productcode = 'S24_2840'
group by productCode; 

/* 5 */
select sum(quantityordered) as TotalQuantityOrdered
from orderdetails; 

/* 6 */
select avg(priceEach) as WeightedPriceEach
from orderdetails
where productCode = 'S24_2840';

/* 7 */
select avg(distinct priceEach) as UnWeightedPriceEach
from orderdetails
where productCode = 'S24_2840'
group by productCode;

/* 8 */
select productCode, variance(priceEach) as VariancePriceEach
from orderdetails
where productCode = 'S24_2840'
group by productCode;

/* 9 */
select productCode, MIN(priceEach) as MinPriceEach, MAX(priceEach) as MaxPriceEach
from orderdetails
where productCode = 'S24_2840'
group by productCode;

/* 10 */
select productCode , count(*) as outstandingOrders
from orderdetails
where quantityOrdered > 0
group by productCode
having outstandingOrders >= 25;

/* 11 */
select productCode, sum(quantityOrdered) as TotalQuantityOrdered
from orderdetails
group by productCode
having TotalQuantityOrdered > 1000;

/* 12 */
select od.orderNumber, o.orderDate, o.customerNumber, od.quantityOrdered, od.priceEach, (od.quantityOrdered * od.priceEach) as TotalAmount
from orderdetails as od
Join orders as o on od.orderNumber = o.orderNumber
where od.quantityOrdered > 0
order by o.orderDate ASC , o.customernumber DESC;

/* 13 */
select p.productCode, od.orderNumber, od.priceEach
from products as p
join orderdetails as od on p.productCode = od.productCode
where p.productCode = 'S24_2840'
order by od.priceEach DESC;

/* 14 */
select c.customerNumber, c.customerName, o.orderNumber, o.orderDate, od.productCode, p.productName, od.quantityOrdered
from customers c
Join orders as o on c.customerNumber = o.customerNumber
Join orderdetails as od on o.orderNumber = od.orderNumber
join products as p on od.productCode = p.productCode
where od.quantityOrdered > 0;

/* 15 */
select c1.customerName as customerName1 , c1.customerNumber as customerNumber1,
       c2.customerName as customerName2 , c2.customerNumber as customerNumber2
from customers c1
join customers c2 on c1.city=c2.city and c1.customerNumber < c2.customerNumber;

/* 16 Write a SQL query that returns customernumber, customername who have ordered at least one type of productline = 'planes' */
select c.customerName, c.customerNumber
from customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
where p.productLine = 'planes' ;

/* 17 Write a SQL query that returns customername, productname, shippeddate, quantityordered for all shipped orders*/ 
select c.customerName, p.productName, o.shippedDate, od.quantityOrdered
from customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
where o.status = 'Shipped' ;

/* 18 Write a SQL query that returns the productcode, productname, and total quantityordered for each product that is in an order*/
select p.productCode, p.productName, sum(quantityOrdered) as TotalQuantityOrdered
from products p
join orderdetails od on p.productCode = od.productCode
group by p.productCode, p.productName;

/* 19 Write a SQL query that returns customernumber, customername, and if applicable, include the ordernumbers of their orders. 
Namely the information of all customer even if they do not have any order */
select c.customerNumber, c.customerName, o.orderNumber
from customers c
left join orders o on c.customerNumber = o.customerNumber;

/* 20 Write a SQL query that returns all productcode, together with the productname and total quantityordered, 
even if there are currently no outstanding orders for a product
COALESCE is used to handle cases where there are no orders for a product, ensuring that the total quantity is displayed as 0 instead of NULL */
select p.productCode, p.productName, coalesce(sum(od.quantityordered),0) as TotalQuantityOrdered
from products p
left join orderdetails od on p.productCode = od.productCode
group by p.productCode, p.productName;

/* 21 Write a nested SQL query that returns the name of the customer with whom the order number ‘10202’ is placed */
select customerName 
from customers
where customerNumber = (
	select customerNumber
    from orders
    where orderNumber = '10202'
);

/* 22 Write a nested SQL query that returns the names of the customers who ordered the product with productcode ‘S24_2840’ */
select customerName
from customers
where customerNumber in (
	select o.customerNumber 
    from orderdetails od
    join orders o on od.orderNumber = o.orderNumber
    join products p on od.productCode = p.productCode
    where p.productCode = 'S24_2840'
);

/* 23 Write a nested SQL query that returns the names of the customers who ordered the product with productcode ‘S24_2840’ and the product with productcode ‘S50_1341’ */
select customerName
from customers
where customerNumber in (
	select o.customerNumber 
    from orderdetails od
    join orders o on od.orderNumber = o.orderNumber
    join products p on od.productCode = p.productCode
    where p.productCode in ( 'S24_2840', 'S50_1341')
    group by o.customerNumber 
    having count(distinct p.productCode) = 2
);

/* 24 Write a correlated SQL query that returns the productname of all products with at least 5 orders */
select p.productName
from products p 
where 5<= (
	select count(*) 
    from orderdetails od
    join orders o on od.orderNumber = o.orderNumber
    where od.productCode = p.productCode
);

/* 25 Write a correlated SQL query that returns the customernumber, customername of the customers who ordered a product at a priceeach lower than 
the average priceeach of that product, together with the productcode, productname, priceeach, and quantityordered */
select c.customerName, c.customerNumber, od.quantityOrdered, od.productCode, od.priceEach, p.productCode 
from orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
where od.priceEach < (
	select avg(od_sub.priceEach)  
    from orderdetails od_sub
    where od_sub.productCode = od.productCode    
);

/* 26 Write a correlated SQL query that returns the customernumber, customername with the top 2 most orders (do not use limit) 
If not using LIMIT, then we have to use window function*/
 

/* 27 Write a SQL query that returns the customernumber, customername who ordered the productcode ‘S18_3136’ with the highest priceeach */
select c.customerName, o.customerNumber
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
where od.productCode = 'S18_3136' and od.priceEach = (
		select max(priceEach) 
        from orderdetails 
        where productCode = 'S18_3136'
);

/* 28 Write a SQL query that returns the customernumber, customername who ordered the productcode ‘S18_3136’ and did not pay the lowest priceeach */
select c.customerName, o.customerNumber
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
where od.productCode = 'S18_3136' and od.priceEach > (
		select min(priceEach) 
        from orderdetails 
        where productCode = 'S18_3136'
);     

/* 29 Write a SQL query using ‘EXISTS’ that returns the customernumber, customername who ordered the productcode ‘S18_3136’ */
select c.customerNumber, c.customerName
from customers c
where exists (
	select 1 
    from orders o
    join orderdetails od on o.orderNumber = od.orderNumber
    where o.customerNumber = c.customerNumber and od.productcode = 'S18_3136'
);

/* 30 Write a SQL query that returns the customernumber, customername who are either located in ‘Boston’ or have ordered the productcode ‘S18_3136’ */
select c.customerNumber, c.customerName
from customers c
where c.city = 'Boston' OR exists (
	select 1
    from orders o
    join orderdetails od on o.orderNumber = od.orderNumber
    where o.customerNumber = c.customerNumber and  od.productCode = 'S18_3136'    
);
/* 2nd Method */
select customerName, customerNumber
from customers
where city = 'Boston' or customerNumber in (
	select o.customerNumber
    from orders o
    join orderdetails od on o.orderNumber = od.orderNumber
    where od.productCode = 	'S19_3136'
);

/* 31 Write a SQL query that returns the customernumber, customername who are located in ‘Boston’ and have ordered the productcode ‘S18_3136’. 
(one may use ‘intersect’. However, ‘intersect’ is not supported in MySQL. Thank about an alternative) */
select c.customerName, c.customerNumber
from customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
where c.city = 'Boston' and  od.productCode = 'S18_3136';

/* 32 Write a SQL query that returns the customernumber, customername who have not ordered any product. 
(one may use ‘except’. However, ‘except’ is not supported in MySQL. Think about an alternative) */
select c.customerName, c.customerNumber
from customers c
where not exists (
	select 1
    from orders o
    where o.customerNumber = c.customerNumber
);
/* 2nd Method */
select customerNumber, customerName
from customers
except 
select c.customerNumber, c.customerName
from customers c
join orders o on o.customerNumber = c.customerNumber;


Ques7) Print the customer names and contact titles for customers who have placed orders for products with a unit price higher than $100 or have made purchases in multiple categories. Include only those customers who are located in countries starting with the letter 'U' or have a postal code ending with '5'. Order the results by customer name.
Hint: Use Customers, Orders, Order_detail, Products
 
customers-SELECT `customers`.`CustomerID`,
`customers`.`CompanyName`,
`customers`.`ContactName`,
`customers`.`ContactTitle`,
`customers`.`Address`,
`customers`.`City`,
`customers`.`Region`,
`customers`.`PostalCode`,
`customers`.`Country`,
`customers`.`Phone`,
`customers`.`Fax`
FROM `hackathon`.`customers`;

 
SELECT `orders`.`OrderID`,
`orders`.`CustomerID`,
`orders`.`EmployeeID`,
`orders`.`OrderDate`,
`orders`.`RequiredDate`,
`orders`.`ShippedDate`,
`orders`.`ShipVia`,
`orders`.`Freight`,
`orders`.`ShipName`,
`orders`.`ShipAddress`,
`orders`.`ShipCity`,
`orders`.`ShipRegion`,
`orders`.`ShipPostalCode`,
`orders`.`ShipCountry`
FROM `hackathon`.`orders`;

 
 
SELECT * FROM hackathon.orders;
SELECT `order_details`.`ID`,
`order_details`.`OrderID`,
`order_details`.`ProductID`,
`order_details`.`UnitPrice`,
`order_details`.`Quantity`,
`order_details`.`Discount`
FROM `hackathon`.`order_details`;
SELECT * FROM hackathon.order_details;
 
SELECT `products`.`ProductID`,
`products`.`ProductName`,
`products`.`SupplierID`,
`products`.`CategoryID`,
`products`.`QuantityPerUnit`,
`products`.`UnitPrice`,
`products`.`UnitsInStock`,
`products`.`UnitsOnOrder`,
`products`.`ReorderLevel`,
`products`.`Discontinued`
FROM `hackathon`.`products`;
