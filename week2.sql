use AdventureWorks2008R2

-- SELECT table_name
-- FROM INFORMATION_SCHEMA.TABLES
-- WHERE table_type = 'BASE TABLE'

-- I
-- -- 1 Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng  6  năm 2008  có 
-- tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate,  SubTotal,  trong đó 
-- SubTotal=SUM(OrderQty*UnitPrice)

select d.SalesOrderID, OrderDate, SubTotal=SUM(d.OrderQty*d.UnitPrice)
from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d 
on d.SalesOrderID = h.SalesOrderID
where MONTH(h.OrderDate)=6 and YEAR(h.OrderDate)=2008 and SubTotal>70000
group by d.SalesOrderID, OrderDate
go

-- -- 2)  Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
-- có  mã  vùng  là  US  (lấy  thông  tin  từ  các  bảng  Sales.SalesTerritory, 
-- Sales.Customer,  Sales.SalesOrderHeader,  Sales.SalesOrderDetail).  Thông  tin 
-- bao  gồm  TerritoryID,  tổng  số  khách  hàng  (CountOfCust),  tổng  tiền 
-- (SubTotal) với  SubTotal = SUM(OrderQty*UnitPrice)

select c.TerritoryID,CountOfCust=count(c.CustomerID),SubTotal=SUM(OrderQty*UnitPrice)
from Sales.Customer c join Sales.SalesTerritory t on c.TerritoryID=t.TerritoryID 
					join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
					join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
where t.CountryRegionCode='US'
group by c.CustomerID,c.TerritoryID,t.CountryRegionCode
go

-- -- 3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
-- (CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
-- SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)

select h.SalesOrderID,CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
where substring(d.CarrierTrackingNumber,1,3)='4BD'
group by h.SalesOrderID,CarrierTrackingNumber
go

-- -- 4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
-- trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.

select p.ProductID,p.Name,AverageOfQty=sum(OrderQty)/count(*)
from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
where UnitPrice<25
group by p.ProductID,p.Name
having sum(OrderQty)/count(*)>5
go

-- -- 5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
-- JobTitle, CountOfPerson=Count(*)

select JobTitle, CountOfPerson=Count(*)
from HumanResources.Employee
group by JobTitle
having Count(*)>20
go

-- -- 6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
-- kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
-- BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
-- (sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
-- [Purchasing].[PurchaseOrderDetail])

select * from Purchasing.Vendor where Name like '%Bicycles'

select v.BusinessEntityID, v.Name as Vendor_Name, d.ProductID, SumOfQty=sum(d.OrderQty), SubTotal=sum(d.OrderQty*d.UnitPrice)
from Purchasing.Vendor v join Purchasing.PurchaseOrderHeader h on v.BusinessEntityID=h.VendorID
						join Purchasing.PurchaseOrderDetail d on h.PurchaseOrderID=d.PurchaseOrderID
where Name like '%Bicycles'
group by v.Name,v.BusinessEntityID,d.ProductID
having sum(d.OrderQty*d.UnitPrice)>800000
go

-- -- 7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
-- trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
-- SubTotal

select p.ProductID, p.Name as Product_Name, CountOfOrderID=sum(d.OrderQty*d.UnitPrice)
from Production.Product p join Purchasing.PurchaseOrderDetail d on p.ProductID=d.ProductID
						join Purchasing.PurchaseOrderHeader h on d.PurchaseOrderID=h.PurchaseOrderID
where MONTH(h.OrderDate)>=1 and MONTH(h.OrderDate)<=4 and YEAR(h.OrderDate)=2008
group by p.Name,p.ProductID
having sum(d.OrderQty*d.UnitPrice)>10000
go

-- -- 8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
-- 2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
-- as FullName), Số hóa đơn (CountOfOrders).

select * from Sales.Customer
select * from  Person.Person

select c.PersonID as N'mã khách' , N'họ tên'=(p.FirstName +' '+ p.LastName)
from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
					join Sales.SalesOrderDetail d on d.SalesOrderID=h.SalesOrderID
					join Person.Person p on c.PersonID=p.BusinessEntityID
where YEAR(h.OrderDate)>=2007 and YEAR(h.OrderDate)<=2008
group by c.PersonID,p.FirstName,p.LastName
having count(*)>=25
go

-- -- 9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
-- bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
-- CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
-- Sales.SalesOrderDetail và Production.Product)

select p.ProductID, p.Name, CountOfOrderQty=sum(d.OrderQty), Year=YEAR(h.OrderDate)
from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d on h.SalesOrderID=d.SalesOrderID
							join Production.Product p on p.ProductID=d.ProductID
where p.Name LIKE 'Bike%' or p.Name LIKE 'Sport%'
group by p.ProductID,p.Name,YEAR(h.OrderDate)
having sum(d.OrderQty)>=500
go

-- -- 10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
-- tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
-- bình (AvgofRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory].

select d.DepartmentID,d.Name,AvgofRate=sum(ph.Rate)/count(*)
from HumanResources.Department d join HumanResources.EmployeeDepartmentHistory dh on d.DepartmentID=dh.DepartmentID
								join HumanResources.EmployeePayHistory ph on dh.BusinessEntityID=ph.BusinessEntityID
group by d.DepartmentID,d.Name
having sum(ph.Rate)/count(*)>30
go
						
-- II) Subquery
-- -- 1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
-- trên 100 đơn đặt hàng trong tháng 7 năm 2008

select 'Product Names'=Name,'Product ID'=ProductID
from Production.Product
where ProductID in (
	select d.ProductID --,count(*)
	from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d on d.SalesOrderID=h.SalesOrderID
	where MONTH(h.OrderDate)=7 and YEAR(h.OrderDate)=2008
	group by d.ProductID
	having count(*)>=100
)
go

-- -- 2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
-- trong tháng 7/2008

select 'Product Names'=p.Name,'Product ID'=p.ProductID
from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
						join Sales.SalesOrderHeader h on d.SalesOrderID=h.SalesOrderID
where MONTH(h.OrderDate)=7 and YEAR(h.OrderDate)=2008
group by p.ProductID,p.Name
having count(*)>=all(
	select count(*)
	from Sales.SalesOrderHeader h join Sales.SalesOrderDetail d on d.SalesOrderID=h.SalesOrderID
	where MONTH(h.OrderDate)=7 and YEAR(h.OrderDate)=2008
	group by d.ProductID
)
go

-- -- 3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
-- CustomerID, Name, CountOfOrder

select c.CustomerID, p.LastName, CountOfOrder=count(*)
from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
					join Person.Person p on c.PersonID=p.BusinessEntityID
group by c.CustomerID,p.LastName
having count(*)>=all(
	select count(*)
	from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
	group by c.CustomerID
)
go

-- -- 4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
-- tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
-- bảng Production.Product và Production.ProductModel)



-- -- 5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
-- đa cao hơn giá trung bình của tất cả các mô hình.


-- -- 6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
-- đặt hàng > 5000 (dùng IN, EXISTS)


-- -- 7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
-- nhất trong bảng Sales.SalesOrderDetail


-- -- 8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
-- Nam; dùng 3 cách Not in, Not exists và Left join.


-- -- 9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
-- EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
-- HumanResources.Employees và Sales.SalesOrdersHeader)


-- -- 10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
-- trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008.




