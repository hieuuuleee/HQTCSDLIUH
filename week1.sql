SELECT name
FROM sys.databases;

SELECT table_name
FROM INFORMATION_SCHEMA.TABLES
WHERE table_type = 'BASE TABLE'

use master

-- I
-- -- 1. Tao cac kieu du lieu nguoi dung:
EXEC sp_addtype Mota,'nvarchar(40)',NULL
EXEC sp_addtype IDKH,'char(10)','NOT NULL'
EXEC sp_addtype DT,'char(12)',NULL

-- -- 2. Tao cac bang theo cau truc:
-- -- -SanPham
create table SanPham(
	Masp char(6),
	TenSp varchar(20),
	NgayNhap Date,
	DVT char(10),
	SoLuongTon int,
	DonGiaNhap money
);
-- -- -KhachHang
create table KhachHang(
	MaKH IDKH,
	TenKH nvarchar(30),
	Diachi nvarchar(40),
	Dienthoai DT
);
-- -- -HoaDon
create table HoaDon(
	MaHD char(10),
	NgayLap Date,
	NgayGiao Date,
	Makh IDKH,
	DienGiai Mota
);
-- -- -ChiTietHD
create table ChiTietHD(
	MaHD char(10),
	Masp char(6),
	Soluong int
);

-- -- 3. Table HoaDon, sua cot DienGiai thanh nvarchar(100)
alter table HoaDon
alter column DienGiai nvarchar(100);

-- -- 4. Them vao bang SanPham cot TyLeHoaHong float
alter table SanPham
add TyLeHoaHong float;

-- -- 5. Xoa cot NgayNhap trong bang SanPham
alter table SanPham
drop column NgayNhap;

-- -- 6. Tao cac rang buoc khoa chinh va khoa ngoai cho cac bang tren
alter table SanPham
add primary key (Masp);

alter table KhachHang
add primary key (MaKH)

alter table HoaDon
add primary key (MaHD),
	foreign key (Makh) references KhachHang(MaKH);

alter table ChiTietHD
add foreign key (MaHD) references HoaDon(MaHD),
	foreign key (Masp) references SanPham(Masp);

-- -- 7. Them vao bang HoaDon cac rang buoc sau:
alter table HoaDon
add constraint ngayGiaoNgayLap
	check (NgayGiao>=NgayLap),
	constraint MaHD
	check (MaHD LIKE '[a-zA-Z]{2}[0-9]{4}'),
	constraint NgayLap_DF
	DEFAULT Getdate() FOR NgayLap;
