-- 3. Product & Order Insights
-- 3.1 What are the top 10 most sold products (by quantity)?
Select P.ProductId, ProductName, Sum(OD.Quantity) as TotalQty
from orderdetails OD
Join products P on OD.ProductID = P.ProductID
Group by P.ProductID, ProductName
order by TotalQty Desc
Limit 10;


-- 3.2 What are the top 10 most sold products (by revenue)?
Select P.ProductId, ProductName, Sum(OD.Quantity * P.Price) as TotalRevenue
from orderdetails OD
Join products P on OD.ProductID = P.ProductID
group by P.ProductID, ProductName
Order by TotalRevenue DESC
Limit 10;


-- 3.3 Which products have the highest return rate? [Return Rate = Returned Qty / Total Qty]
With Sold as(
Select ProductId, Sum(Quantity) as TotalQty
from orderdetails
group by ProductID
),
Returned as(
Select ProductId, Sum(OD.Quantity) as TotalQtyReturned
from orderdetails OD
Join orders O on OD.OrderID = O.OrderID
where IsReturned= 1
Group by ProductID
)
Select ProductName, Round(((R.TotalQtyReturned / S.TotalQty)*100),2) as ReturnRate
from products P
Join Sold S on P.ProductID = S.ProductId
Join Returned R on R.ProductID = P.ProductID
Order by  ReturnRate DESC
Limit 10;


-- 3.4 Return Rate by Category
With Sold As(
Select Category, OD.ProductId, Sum(Quantity) as TotalQty
from orderdetails OD
Join products p on P.ProductID = OD.ProductID
group by Category, OD.ProductID
),
Returned as(
select Category, OD.ProductId, sum(OD.Quantity) as TotalReturnedQty
from orders O
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on OD.ProductID = P.ProductID
where IsReturned = 1
group by Category, OD.ProductId
)
Select S.Category, P.ProductName, Round((R.TotalReturnedQty/S.TotalQty)*100,2) as ReturnRate
from products P
Join Sold S on P.ProductID = S.ProductID
Join Returned R on P.ProductID = R.ProductID
order by ReturnRate DESC
limit 10;


-- 3.5 What is the average price of products per region? [Avg Price = Total Revenue / Total Qty]
Select RegionName, Round(sum(OD.Quantity * P.Price)/ Sum(OD.Quantity), 2) as AvgPrice
from orders O
Join Customers C on C.CustomerID = O.CustomerID
Join Regions R on R.RegionId = C.RegionId
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on P.ProductID= OD.ProductID
Group by RegionName
Order by AvgPrice DESC;


-- 3.6 What is the sales trend for each product category?
Select date_format(OrderDate, "%Y-%m") as Period, Category, Sum(OD.Quantity * P.Price) AS Revenue
From Orders O 
Join orderdetails OD on OD.OrderID= O.OrderID
Join Products P on P.ProductId = OD.ProductID
Group By Period, Category
Order By Category, Period;