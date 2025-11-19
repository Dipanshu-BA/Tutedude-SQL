use final_project_ecommerce;

-- 4. Temporal Trends
-- 4.1 What are the monthly sales trends over the past year?
Select year(OrderDate) as `Year`, month(OrderDate) as `Month`, sum(OD.Quantity * P.Price) as Revenue
from orders O 
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on P.ProductID = OD.ProductID
Where OrderDate >= current_date() - interval 12 month
Group by `Year`, `Month`
Order by `Year`, `Month`;


-- 4.2 How does the average order value (AOV) change by month?
Select date_format(OrderDate, "%Y-%m") as Period, Round(sum(OD.Quantity * P.Price)/count(distinct O.OrderId),2) as AOV
from orders O 
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on P.ProductID = OD.ProductID
Group By Period
Order By Period;


-- 5. Regional Insights
-- 5.1 Which regions have the highest order volume and which have the lowest?
Select RegionName, count(O.OrderId) as OrderVolume
From Orders O 
Join Customers C on C.CustomerId = O.CustomerId
Join regions R on R.RegionID = C.RegionID
Group By RegionName
Order By OrderVolume desc;


-- 5.2 What is the revenue per region and how does it compare across different regions?
Select RegionName, Sum(OD.Quantity * P.Price) AS TotalRevenue
From Orders O
Join Customers C on C.CustomerID = O.CustomerID
Join Regions R on R.RegionID = C.RegionID
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on P.ProductID = OD.ProductID
Group by RegionName
Order by TotalRevenue Desc; 


-- 5.3 What is the revenue per region and how does it compare across different regions on Order Volume basis?
With T1 as(
Select RegionName, count(O.OrderId) as OrderVolume
From Orders O 
Join Customers C on C.CustomerId = O.CustomerId
Join regions R on R.RegionID = C.RegionID
Group By RegionName
Order By OrderVolume desc
),
T2 AS(
Select RegionName, Sum(OD.Quantity * P.Price) AS TotalRevenue
From Orders O
Join Customers C on C.CustomerID = O.CustomerID
Join Regions R on R.RegionID = C.RegionID
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on P.ProductID = OD.ProductID
Group by RegionName
Order by TotalRevenue Desc
)
Select T1.RegionName, OrderVolume, TotalRevenue
from T1
Join T2 on T2.RegionName = T1.RegionName;


-- 6. Return & Refund Insights
-- 6.1 What is the overall return rate by product category? 
Select Category, Round(sum(Case When IsReturned = 1 Then 1 Else 0 end)/ count(O.OrderID), 2) as ReturnRate
From Orders O
Join Orderdetails OD on OD.orderId = O.OrderId
Join Products P on P.ProductId = OD.ProductId
group by Category
order by ReturnRate Desc;


-- 6.2 What is the overall return rate by region?
Select RegionName, Round(sum(Case When IsReturned = 1 Then 1 Else 0 end)/ count(O.OrderID), 2) as ReturnRate
From Orders O
Join Customers C on C.CustomerId = O.CustomerId
Join Regions R on R.RegionId = C.RegionId
group by RegionName
order by ReturnRate Desc;


-- 6.3 Which customers are making frequent returns?
Select C.CustomerId, CustomerName, Count(O.OrderID) as ReturnCount
from orders O
Join Customers C on C.CustomerID = O.CustomerID
where IsReturned = 1
Group By CustomerID, CustomerName
Order by ReturnCount Desc
Limit 10;
