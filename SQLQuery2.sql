create proc GETEmployeeAndShipp @startdate date ,@enddate date
as
select e.EmployeeID ,e.FirstName ,e.Country,o.OrderID ,o.ShippedDate
from Employees e join Orders o
on  o.EmployeeID =e.EmployeeID
where o.ShippedDate between  @startdate and @enddate



GETEmployeeAndShipp '1996-07-12 ','1996-08-13 '



create view custmerLiveGermany 
as
select *
from Customers c
where c.Country='Germany'

select *
from custmerLiveGermany 



ALTER view productUnitPrice
as
select *
from Products p
where  P.UnitPrice> (select avg(UnitPrice) avgPrice
from Products p)

select *
from  productUnitPrice
