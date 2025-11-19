use final_project_ecommerce;

select *
from customers;

select *
from orderdetails;

select *
from orders;

select *
from products;

select *
from regions;

-- 1. General Sales Insights
-- 1.1 What is the total revenue generated over the entire period?

 select sum(OD.quantity * P.price) as Total_Revenue
 from orderdetails OD
 join products P on OD.ProductID = P.ProductID;
 
-- 1.2 Revenue Excluding Returned Orders
Select sum(OD.quantity * P.price) as Revenue_excluding_return
from orders O
join orderdetails OD on OD.OrderID = O.OrderID
join products P on P.ProductID = OD.ProductID
where O.IsReturned= False;

Select sum(OD.quantity * P.price) as Loss_by_return
from orders O
join orderdetails OD on OD.OrderID = O.OrderID
join products P on P.ProductID = OD.ProductID
where O.IsReturned= True;


-- 1.3 Total Revenue per Year / Month
Select Year(OrderDate) as `year`, month(orderdate) as `month`, sum(OD.quantity * P.price) as Monthly_Revenue
from orders O 
join orderdetails OD on OD.OrderID=O.OrderID
join products P on P.ProductID = OD.ProductID
group by `year`, `month`
order by `year`, `month`;


-- 1.4 Revenue by Product / Category
Select ProductName, Category, sum(OD.quantity * P.price) as Product_Revenue
from orderdetails OD
join products P on P.ProductID = OD.ProductID
group by ProductName, Category
order by Category ASC ,Product_Revenue DESC;


-- 1.5 What is the average order value (AOV) across all orders? [AOV = Total Revenue/Number of Orders]
Select AVG(TotalOrderValue) as AverageOrderValue
From (Select O.OrderId, sum(OD.quantity * P.price) as TotalOrderValue
		from orders O
		join orderdetails OD on OD.OrderID = O.OrderID
		join products P on OD.ProductID = P.ProductID
		Group by O.OrderID) T;


-- 1.6 AOV per Year / Month
Select year(Orderdate) as `Year`,
		month(OrderDate) as `Month`,
		AVG(TotalOrderValue) as AverageOrderValue
from ( Select O.OrderID, O.OrderDate, Sum(OD.quantity * P.price) as TotalOrderValue
		from orders O
        join orderdetails OD on O.orderID = OD.orderID
		join products P on OD.ProductID = P.ProductID
		Group by OrderID) T
        Group by `Year`,`Month`
        Order by `Year`,`Month`;


-- 1.7 What is the average order size by region?
Select R.RegionName, avg(TotalOrderSize) as AverageOrderSize
from (Select O.orderID, C.RegionID, Sum(OD.quantity) as TotalOrderSize
		from orders O 
		join customers C on C.CustomerID = O.CustomerID
		join orderdetails OD on OD.OrderID = O.OrderID
		Group by C.RegionID, O.orderId) T
Join regions R on R.RegionID = T.RegionID
Group by RegionName
Order by AverageOrderSize DESC;
