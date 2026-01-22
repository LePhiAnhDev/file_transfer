-- TẠO DATABASE
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'QLNV')
    CREATE DATABASE QLNV;
GO

USE QLNV;
GO

-- XÓA BẢNG NẾU TỒN TẠI
IF OBJECT_ID('TDNN', 'U') IS NOT NULL DROP TABLE TDNN;
IF OBJECT_ID('NhanVien', 'U') IS NOT NULL DROP TABLE NhanVien;
IF OBJECT_ID('DMNN', 'U') IS NOT NULL DROP TABLE DMNN;
IF OBJECT_ID('Phong', 'U') IS NOT NULL DROP TABLE Phong;
IF OBJECT_ID('NGHI_HUU', 'U') IS NOT NULL DROP TABLE NGHI_HUU;
GO

-- CÂU 1: TẠO CÁC BẢNG
CREATE TABLE Phong (
    maph CHAR(3) PRIMARY KEY,
    tenph NVARCHAR(40) NOT NULL,
    diachi NVARCHAR(50),
    tel CHAR(10)
);
GO

CREATE TABLE DMNN (
    mann CHAR(2) PRIMARY KEY,
    tennn NVARCHAR(20) NOT NULL
);
GO

CREATE TABLE NhanVien (
    manv CHAR(5) PRIMARY KEY,
    hoten NVARCHAR(40) NOT NULL,
    gioitinh NCHAR(3) CHECK (gioitinh IN (N'Nam', N'Nữ')),
    ngaysinh DATE,
    luong INT,
    maph CHAR(3),
    sdt CHAR(10),
    ngaybc DATE,
    CONSTRAINT FK_NV_PHONG FOREIGN KEY (maph) REFERENCES Phong(maph)
);
GO

CREATE TABLE TDNN (
    manv CHAR(5),
    mann CHAR(2),
    tdo CHAR(1) CHECK (tdo IN ('A','B','C','D','E')),
    PRIMARY KEY (manv, mann),
    FOREIGN KEY (manv) REFERENCES NhanVien(manv),
    FOREIGN KEY (mann) REFERENCES DMNN(mann)
);
GO

-- NHẬP DỮ LIỆU
INSERT INTO Phong VALUES
('HCA', N'Hành chính', N'371 NK', '0362588541'),
('KDA', N'Kinh doanh', N'371 NK', '0362517395'),
('KTA', N'Kỹ thuật', N'371 NK', '0362567401'),
('QTA', N'Quản trị', N'371 NK', '0362565788');
GO

INSERT INTO DMNN VALUES
('01', N'Anh'),
('02', N'Nga'),
('03', N'Pháp'),
('04', N'Nhật'),
('05', N'Trung Quốc'),
('06', N'Hàn Quốc');
GO

INSERT INTO NhanVien VALUES
('HC001', N'Nguyễn Thị Hà', N'Nữ', '1966-08-27', 7500000, 'HCA', NULL, '1995-02-08'),
('HC002', N'Trần Văn Nam', N'Nam', '1995-12-06', 8000000, 'HCA', NULL, '2017-08-06'),
('HC003', N'Nguyễn Thanh Huyền', N'Nữ', '1998-03-07', 6500000, 'HCA', NULL, '2019-09-24'),
('KD001', N'Lê Tuyết Anh', N'Nữ', '1992-03-02', 7500000, 'KDA', NULL, '2021-02-10'),
('KD002', N'Nguyễn Anh Tú', N'Nam', '1962-04-07', 7600000, 'KDA', NULL, '2000-07-14'),
('KD003', N'Phạm An Thái', N'Nam', '1977-09-05', 6600000, 'KDA', NULL, '2019-10-13'),
('KD004', N'Lê Văn Hải', N'Nam', '1976-02-01', 7900000, 'KDA', NULL, '2017-08-06'),
('KD005', N'Nguyễn Phương Minh', N'Nam', '1980-02-01', 7000000, 'KDA', NULL, '2021-02-10'),
('KT001', N'Trần Đình Khâm', N'Nam', '1971-02-12', 7700000, 'KTA', NULL, '2022-01-01'),
('KT003', N'Phạm Thanh Sơn', N'Nam', '1994-08-20', 7100000, 'KTA', NULL, '2022-01-01'),
('KT004', N'Vũ Thị Hoài', N'Nữ', '1995-05-12', 7500000, 'KTA', NULL, '2021-10-02'),
('KT005', N'Nguyễn Thu Lan', N'Nữ', '1994-05-10', 8000000, 'KTA', NULL, '2021-02-10'),
('KT006', N'Trần Hoài Nam', N'Nam', '1978-02-07', 7800000, 'KTA', NULL, '2017-08-06'),
('TT001', N'Hoàng Nam Sơn', N'Nam', '1969-03-12', 8200000, NULL, NULL, '2015-07-02'),
('KT008', N'Lê Thu Trang', N'Nữ', '1970-06-07', 7500000, 'KTA', NULL, '2018-02-08'),
('KT009', N'Khúc Nam Hải', N'Nam', '1980-07-22', 7000000, 'KTA', NULL, '2015-01-01'),
('TT002', N'Phùng Trung Dũng', N'Nam', '1978-08-28', 7200000, NULL, NULL, '2012-09-24');
GO

INSERT INTO TDNN VALUES
('HC001','01','A'),('HC001','02','B'),
('HC002','01','C'),('HC002','03','C'),
('HC003','01','D'),
('KD001','01','C'),('KD001','02','B'),
('KD002','01','D'),('KD002','02','A'),
('KD003','01','B'),('KD003','02','C'),
('KD004','01','C'),('KD004','04','A'),('KD004','05','A'),
('KD005','01','B'),('KD005','02','D'),('KD005','03','B'),('KD005','04','B'),
('KT001','01','D'),('KT001','04','E'),
('KT003','01','D'),('KT003','03','C'),
('KT004','01','D'),('KT004','03','A'),
('KT005','01','C'),('KT005','02','A'),('KT005','04','B'),
('KT006','01','B'),('KT006','03','C'),
('KT008','01','B'),('KT008','02','D'),('KT008','03','A'),
('TT002','01','B'),('TT002','02','C'),('TT002','03','A'),('TT002','04','D');
GO

-- CÂU 3
INSERT INTO NhanVien VALUES
('QT001', N'Tên của bạn', N'Nam', '1990-01-01', 9500000, 'QTA', NULL, GETDATE());

INSERT INTO TDNN VALUES
('QT001','01','C'),
('QT001','04','A');
GO

-- CÂU 4
SELECT manv, hoten, maph, luong FROM NhanVien WHERE manv = 'KD001';

-- CÂU 5
SELECT *, YEAR(GETDATE()) - YEAR(ngaysinh) AS tuoi
FROM NhanVien
WHERE YEAR(GETDATE()) - YEAR(ngaysinh) < 32;

-- CÂU 6
SELECT DISTINCT nv.*
FROM NhanVien nv
JOIN TDNN td ON nv.manv = td.manv
WHERE td.mann = '01' AND td.tdo IN ('A','B','C');

-- CÂU 7
SELECT *, YEAR(GETDATE()) - YEAR(ngaybc) AS sonambc
FROM NhanVien
WHERE YEAR(GETDATE()) - YEAR(ngaybc) > 10;

-- CÂU 8
SELECT *
FROM NhanVien
WHERE (gioitinh = N'Nam' AND YEAR(GETDATE()) - YEAR(ngaysinh) >= 60)
   OR (gioitinh = N'Nữ' AND YEAR(GETDATE()) - YEAR(ngaysinh) >= 55);

-- CÂU 9
SELECT manv, hoten, ngaysinh, luong
FROM NhanVien
WHERE luong BETWEEN 7000000 AND 8000000;

-- CÂU 10
SELECT * FROM NhanVien ORDER BY luong ASC;

-- CÂU 11
SELECT COUNT(*) AS TongSoNV, AVG(luong) AS LuongTB
FROM NhanVien
WHERE maph = 'KDA';

-- CÂU 12
SELECT nv.manv, nv.hoten, nv.maph, p.tenph
FROM NhanVien nv
LEFT JOIN Phong p ON nv.maph = p.maph;

-- CÂU 13
SELECT *
FROM NhanVien
WHERE YEAR(GETDATE()) - YEAR(ngaysinh) >
      (SELECT AVG(YEAR(GETDATE()) - YEAR(ngaysinh)) FROM NhanVien);

-- CÂU 14
SELECT nv.manv, nv.hoten, COUNT(td.mann) AS SoNgoaiNgu
FROM NhanVien nv JOIN TDNN td ON nv.manv = td.manv
GROUP BY nv.manv, nv.hoten
HAVING COUNT(td.mann) > 2;

-- CÂU 15
SELECT *
FROM NhanVien
WHERE ngaybc < '2017-01-01'
  AND maph IN ('KTA','KDA');

-- CÂU 16
SELECT *
FROM NhanVien
ORDER BY
RIGHT(hoten, CHARINDEX(' ', REVERSE(hoten) + ' ') - 1),
ngaysinh DESC;

-- CÂU 17
SELECT DISTINCT nv.manv, nv.hoten, nn.tennn, td.tdo
FROM NhanVien nv
JOIN TDNN td ON nv.manv = td.manv
JOIN DMNN nn ON td.mann = nn.mann
WHERE td.mann IN ('01','03') AND td.tdo IN ('A','B','C');

-- CÂU 18
SELECT nn.*
FROM DMNN nn
LEFT JOIN TDNN td ON nn.mann = td.mann
WHERE td.mann IS NULL;

-- CÂU 19
SELECT nv.*
FROM NhanVien nv
LEFT JOIN TDNN td ON nv.manv = td.manv
WHERE td.manv IS NULL;

-- CÂU 20
SELECT nv.manv, nv.hoten, COUNT(td.mann) AS SoNgoaiNgu
FROM NhanVien nv JOIN TDNN td ON nv.manv = td.manv
GROUP BY nv.manv, nv.hoten
HAVING COUNT(td.mann) >= 3;

-- CÂU 21
UPDATE NhanVien
SET luong = luong * 1.15
WHERE maph = 'KTA';
GO

-- CÂU 22
CREATE TABLE NGHI_HUU (
    manv CHAR(5) PRIMARY KEY,
    hoten NVARCHAR(40),
    gioitinh NCHAR(3),
    ngaysinh DATE,
    luong INT,
    maph CHAR(3),
    sdt CHAR(10),
    ngaybc DATE
);
GO

INSERT INTO NGHI_HUU
SELECT *
FROM NhanVien
WHERE (gioitinh = N'Nam' AND YEAR(GETDATE()) - YEAR(ngaysinh) >= 60)
   OR (gioitinh = N'Nữ' AND YEAR(GETDATE()) - YEAR(ngaysinh) >= 55);
GO

DELETE FROM TDNN
WHERE manv IN (SELECT manv FROM NGHI_HUU);
GO

DELETE FROM NhanVien
WHERE manv IN (SELECT manv FROM NGHI_HUU);
GO

-- KIỂM TRA
SELECT * FROM NGHI_HUU;
SELECT * FROM NhanVien;
GO
