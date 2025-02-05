--1 
select C.CustomerID ,C.CompanyName , Round(AVG(O.OrderID),2) as AvargeOrder
from Customers C join Orders O
on c.CustomerID=o.CustomerID
group by C.CustomerID ,C.CompanyName
having AVG(O.OrderID)> 500



--2
select CustomerID ,CompanyName,OrderID
from(
select c.CustomerID ,c.CompanyName,o.OrderID,row_number() over(partition by c.CustomerID order by o.orderdate desc) rawRANK
from Orders o join Customers c
on o.CustomerID =c.CustomerID) NEWTABLE 
where rawRANK=1
order by CustomerID 

--3
select p.ProductID,p.ProductName,ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) totalamount
from [Order Details] od join Products p
on od.ProductID =p.ProductID
group by p.ProductID,p.ProductName

 -- function 
 --1
 create  function  CalculateOrderValue (@OrdID  int)
returns int 
as 
begin
 declare @value int
  select @value =ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 2) 
  from [Order Details] 
  where OrderID=@OrdID 
  

		 return @value
end


select DBO.CalculateOrderValue (10248)



--2
create  function GetCustomerOrderSummary(@CustomerID NVARCHAR(50))
returns @newtable table (
CustID nvarchar (50),
OrderYear int,
TotalOrders int
)
as
begin
insert into @newtable
select CustomerID,year(OrderDate),count(*) tatalotd
from Orders
where CustomerID=@CustomerID 
group by CustomerID, year(OrderDate)

return 
end

select * from GetCustomerOrderSummary('FOLKO')

--3

create or alter function GetTopSellingProducts(@TOPN int )
returns table
as 
return (
select  ProductID ,ProductName,sumQuan
from(select p.ProductID ,ProductName,sum(od.Quantity) sumQuan, ROW_NUMBER() over(order by sum(od.Quantity) desc) rankSumQun
from Products p join [Order Details] od 
on od.ProductID=p.ProductID
group by p.ProductID ,ProductName) newtable
where rankSumQun<=@TOPN 

)
  select * from GetTopSellingProducts(5)


  ---	 stored procedure 
  --1
  create or alter proc GetCustomerOrderHistory @CustomerID  VARCHAR(20)
  as
  select ProductName, sum(od.Quantity)totalQun
  from Products p join [Order Details] od
  on od.ProductID=p.ProductID
  group by ProductName
   
   GetCustomerOrderHistory 'SUPRD'

   --2 
   create or alter proc UpdateProductPrices @CatID  int,@Percentage  decimal
   as
   update Products 
   set UnitPrice = UnitPrice*(1+(@Percentage /100))
   where CategoryID = @CatID 

   select ProductID,ProductName,UnitPrice
   from Products
   where CategoryID=@CatID

   UpdateProductPrices 2,11

   --view
   --1
   create view ProductSalesSummary
   as
   select p.ProductID,ProductName,cat.CategoryName,sum(od.Quantity)Qunsold,sum(od.Quantity*od.UnitPrice*(1-od.Discount))TotalRevenue
   from Products p join Categories cat 
   on p.CategoryID= cat.CategoryID
   join [Order Details] od
   on od.ProductID =p.ProductID
   group by p.ProductID,ProductName,cat.CategoryName

   select * from ProductSalesSummary

   --2
   create or alter view LateShippedOrders
   as
   select OrderID ,CustomerID,OrderDate,RequiredDate,ShippedDate, datediff(day, RequiredDate,ShippedDate )  calculated 
   from Orders
   where ShippedDate>RequiredDate
    
	select * from LateShippedOrders

	--trigger
	--1
	select *
	from Orders
	where ShippedDate is null

	create or alter trigger preventsTheDeletion 
	on orders
	instead of delete
	as
	begin
	declare @valer date
	select @valer= ShippedDate
	from deleted  
	if  @valer  is not null
	select'Cannot delete shipped orders'
	else
	delete from orders where OrderID =(select OrderID  from deleted)
	end
	 
	 delete 
	 from Orders
	 where OrderID= 10395

	  delete 
	 from Orders
	 where OrderID= 11039

	 --2
	 create table PriceUpdateLog (
    LogID int identity(1,1) PRIMARY KEY,
    ProductID INT,
    OldPrice decimal(18, 2),
    NewPrice decimal(18, 2),
    UpdateDate date default GETDATE()
)
 create or alter trigger UPDATEtotheUnitPrice
 on products
 instead of update
 as
 if update(UnitPrice)
 begin
 insert into  PriceUpdateLog ( OldPrice ,NewPrice)
 select d.UnitPrice ,i.UnitPrice
 from deleted d join inserted i
 on d.ProductID=i.ProductID
 update Products
 set UnitPrice =33
 where ProductID =(select ProductID from inserted)
 end

 update Products
 set UnitPrice =33
 where ProductID=5

 update Products
 set ProductName ='me'
 where ProductID=5