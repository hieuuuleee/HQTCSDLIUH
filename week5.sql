use AdventureWorks2008R2
go

-- II) Stored Procedure:
-- -- 1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
-- tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
-- thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)
create procedure TotalDue
@month int,
@year int
as
	select CustomerID, SumOfTotalDue =Sum(TotalDue)
	from Sales.SalesOrderHeader
	where MONTH(OrderDate)=@month and YEAR(OrderDate)=@year
	group by CustomerID
go
exec TotalDue 7,2008
go
-- -- 2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại
-- (SalesYTD) của một nhân viên bất kỳ, với một tham số đầu vào và một tham số
-- đầu ra. Tham số @SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục,
-- tham số @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục.
create procedure FindSalesYTD
@SalesPerson int,
@SalesYTD money output
as
	set @SalesYTD=(
		select sum(SubTotal)
		from Sales.SalesOrderHeader
		where SalesPersonID=@SalesPerson and YEAR(OrderDate)=YEAR(getdate())
	)
go

declare @SalesPerson int,
	@SalesYTD money
set @SalesPerson=282
exec FindSalesYTD @SalesPerson,@SalesYTD output
print convert(nvarchar,@SalesYTD)
go

-- -- 3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
-- giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
create procedure ProductList
@MaxPrice money
as
return
	(select ProductID,ListPrice
	from Production.Product
	where ListPrice<=@MaxPrice)
go

exec ProductList 100
go

-- -- 4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
-- hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
-- bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
-- [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
-- SumOfSubTotal =sum(SubTotal)
-- NewBonus = Bonus+ sum(SubTotal)*0.01


-- -- 5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
-- có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
-- input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
-- ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
-- (Lưu ý: dùng Sub Query)


-- -- 6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
-- là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
-- về trạng thái thành công hay thất bại của thủ tục.


-- -- 7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
-- năm đã cho.


-- III) Function
--  Scalar Function
-- -- 1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
-- giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
-- phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
-- phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
-- Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
-- (Dữ liệu lấy từ bảng
-- [HumanResources].[EmployeeDepartmentHistory] và
-- [HumanResources].[Department])


-- -- 2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
-- @ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
-- vực tương ứng với giá trị của tham số
-- (Dữ liệu lấy từ bảng[Production].[ProductInventory])


-- -- 3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
-- một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
-- @EmplID, @MonthOrder, @YearOrder
-- (Thông tin lấy từ bảng [Sales].[SalesOrderHeader])

