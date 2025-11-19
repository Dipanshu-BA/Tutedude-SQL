use final_project_ecommerce;

-- 2. Customer Insights
-- 2.1 Who are the top 10 customers by total revenue spent?
select C.customerID, CustomerName, sum(OD.quantity * P.price) as TotalRevenue
from customers C
join orders O on C.CustomerID= O.CustomerID
join orderdetails OD on OD.OrderID = O.OrderID
join products P on P.ProductID = OD.ProductID
Group by C.CustomerID, CustomerName
Order by TotalRevenue Desc
Limit 10;


-- 2.2 What is the repeat customer rate? [Repeat Customers Rate = (Customer with more than 1 order) / (Customer with atleast 1 order)]
Select Round((Count(Distinct Case when OrderCount > 1 then CustomerID End) / Count(distinct CustomerID))*100,2) as Repeat_Customer_Rate
From (Select CustomerID, count(orderID) as OrderCount
From Orders
group by customerID) T;


-- 2.3 What is the average time between two consecutive orders for the same customer Region-wise?
With RankedOrders AS(
Select O.CustomerID, O.OrderDate, C.RegionID,
		row_number() over (Partition by O.customerID order by O.OrderDate) as rn
from orders O
Join customers C on O.CustomerID = C.CustomerID
),
OrderPairs AS (
Select curr.CustomerId, curr.RegionId, Datediff(curr.OrderDate, `prev`.OrderDate) as DaysBetween
From RankedOrders curr
Join RankedOrders `prev` on curr.CustomerId = `prev`.CustomerId and curr.rn = `prev`.rn +1
),
Region AS(
Select CustomerId, RegionName, DaysBetween
from OrderPairs OP
join regions R on R.RegionID = OP.RegionId
)
Select RegionName, Round(Avg(DaysBetween),2) as AvgDaysBetween
from Region
group by RegionName
order by AvgDaysBetween;

-- Practice along with customer wise Avg Days Between
With RankedOrders as(
select C.CustomerId, C.CustomerName, O.OrderId, O.OrderDate, C.RegionId,
		row_number() over ( partition by C.CustomerId order by O.OrderDate) as rn
from Customers C 
Join orders O on C.CustomerId = O.CustomerID
),
OrderPairs as(
Select curr.CustomerId, curr.CustomerName, curr.RegionId, datediff(curr.OrderDate, `prev`.OrderDate) as DaysBetween
from RankedOrders curr
Join RankedOrders `prev` on curr.CustomerId = `prev`.CustomerId and curr.rn = `prev`.rn + 1
),
Region as(
Select CustomerId, CustomerName, RegionName, DaysBetween
from OrderPairs OP
Join regions R on OP.RegionId = R.RegionID
)
Select RegionName, CustomerId, CustomerName, round(avg(DaysBetween)) as AvgDaysBetween
from Region
Group By RegionName, CustomerId
Order by AvgDaysBetween;


-- 2.4 Customer Segment (based on total spend)
-- 	Platinum: Total Spend > 1500
-- 	Gold: 1000–1500
-- 	Silver: 500–999
-- 	Bronze: < 500
With CustomerSpend as(
Select O.CustomerId, Sum(OD.Quantity * P.price) as TotalSpend
from orders O
Join orderdetails OD on O.OrderId = OD.OrderID
Join products P on OD.ProductID = P.ProductID
group by O.CustomerID
)
Select CS.CustomerId, C.CustomerName,
		Case
			When TotalSpend> 1500 then 'Platinum'
            when TotalSpend> 1000 then 'Gold'
            When TotalSpend> 500 then 'Silver'
            When TotalSpend< 500 then 'Bronze'
		End as Segment
From CustomerSpend CS
Join customers C on CS.CustomerId = C.CustomerID
;


-- 2.5 What is the customer lifetime value (CLV)? [CLV = Total Revenue Per Customer]
Select C.CustomerId, C.CustomerName, Sum(OD.Quantity * P.Price) as Revenue
from Customers C
Join orders O on O.CustomerID= C.CustomerID
Join orderdetails OD on OD.OrderID = O.OrderID
Join products P on OD.ProductID = P.ProductID
group by C.CustomerId
Order by Revenue Desc;
