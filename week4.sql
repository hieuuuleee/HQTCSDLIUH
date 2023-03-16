use AdventureWorks2008R2
go

-- -- 1)  Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của  sản phẩm 
-- có  ProductID=’778’;  nếu  @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
-- trên  500  đơn  hàng”,  ngược  lại  thì  in  ra  chuỗi  “Sản  phẩm  778  có  ít  đơn  đặt
-- hàng”
declare @tongsoHD int
select @tongsoHD=count(p.ProductID)
from Production.Product p join Sales.SalesOrderDetail d on p.ProductID=d.ProductID
where p.ProductID='778'
if @tongsoHD>500
	print N'Sản phẩm 778 có trên  500  đơn  hàng'
else
	print N'Sản  phẩm  778  có  ít  đơn  đặt hàng'
go

-- -- 2)  Viết  một  đoạn  Batch  với  tham  số  @makh  và  @n  chứa  số  hóa  đơn  của  khách 
-- hàng @makh, tham số @nam chứa năm lập  hóa đơn (ví dụ @nam=2008),    nếu
-- @n>0  thì  in  ra  chuỗi:  “Khách  hàng  @makh  có  @n  hóa  đơn  trong  năm  2008” 
-- ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng  @makh không có hóa đơn nào 
-- trong năm 2008”
declare @makh int
declare @n int
declare @nam int
set @makh=2
set @nam=2008
select @n=count(*)
from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
where year(h.OrderDate)=@nam and c.CustomerID=@makh
if @n>0
	print N'Khách hàng '+convert(nvarchar,@makh)+N' có '+convert(nvarchar,@n)+N' hóa  đơn  trong  năm '+convert(nvarchar,@nam)
else
	print N'Khách hàng '+convert(nvarchar,@makh)+N' không có hóa đơn nào trong năm '+convert(nvarchar,@nam)
go

-- -- 3)  Viết  một  batch  tính  số  tiền  giảm  cho  những  hóa  đơn  (SalesOrderID)  có  tổng 
-- tiền>100000,  thông  tin  gồm  [SalesOrderID],  SubTotal=SUM([LineTotal]), 
-- Discount (tiền giảm), với Discount được tính như  sau:
--   Những hóa đơn có SubTotal<100000 thì không  giảm,
--   SubTotal từ 100000 đến <120000 thì giảm 5% của  SubTotal
--   SubTotal từ 120000 đến <150000 thì giảm 10% của  SubTotal
--   SubTotal từ 150000 trở lên thì giảm 15% của  SubTotal
select SalesOrderID, SubTotal, Discount=
	case
		when SubTotal>=100000 and SubTotal<120000 then SubTotal*0.05
		when SubTotal>=120000 and SubTotal<150000 then SubTotal*0.1
		when SubTotal>=150000 then SubTotal*0.15
	end
from Sales.SalesOrderHeader h
where h.SubTotal>=100000
go


-- -- 4)  Viết một Batch với 3 tham số:  @masp, @mancc, @soluongcc, chứa giá trị của 
-- các  field  [ProductID],[BusinessEntityID],[OnOrderQty],  với  giá  trị  truyền  cho 
-- các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
-- gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc,   nếu
-- @soluongcc trả về giá  trị là null  thì in  ra chuỗi  “Nhà cung  cấp 1650  không cung 
-- cấp sản phẩm  4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
-- cung cấp sản phẩm 4 với số lượng là  5”
-- (Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
declare @masp int
declare @mancc int
declare @soluongcc int
set @masp=4
set @mancc=1650
if (
	select sum(d.OrderQty)
	from Purchasing.PurchaseOrderHeader h join Purchasing.PurchaseOrderDetail d on d.PurchaseOrderID=h.PurchaseOrderID
	where d.ProductID=@masp and h.VendorID=@mancc
) is null
begin
	print N'Nhà cung  cấp '+convert(nvarchar,@mancc)+N'  không cung cấp sản phẩm  '+convert(nvarchar,@masp)
end
else
begin
	set @soluongcc=(select count(*)
					from Purchasing.PurchaseOrderHeader h join Purchasing.PurchaseOrderDetail d on d.PurchaseOrderID=h.PurchaseOrderID
					where d.ProductID=@masp and h.VendorID=@mancc)
	print N'Nhà cung  cấp '+convert(nvarchar,@mancc)+N'  cung cấp sản phẩm  '+convert(nvarchar,@masp)+N' với số lượng là '+convert(nvarchar,@soluongcc)
end
go

-- -- 5)  Viết  một  batch  thực  hiện  tăng  lương  giờ  (Rate)  của  nhân  viên  trong 
-- [HumanResources].[EmployeePayHistory]  theo  điều  kiện  sau:  Khi  tổng  lương 
-- giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
-- nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì  dừng.
while (
	select sum(Rate)
	from HumanResources.EmployeePayHistory
	)<6000
	begin
		update HumanResources.EmployeePayHistory
		set Rate=Rate*1.1
		if (select max(rate)
			from HumanResources.EmployeePayHistory
			)>150
			break
		else
			continue
	end