/* =======================================================
   PHẦN 0: TẠO DATABASE
   ======================================================= */
CREATE DATABASE QuanLyNhanSu_ABC;
GO
USE QuanLyNhanSu_ABC;
GO

/* =======================================================
   PHẦN 1: TẠO BẢNG (TABLES)
   ======================================================= */

-- 1. Bảng Phong (Phòng ban)
CREATE TABLE Phong (
    maph CHAR(3) PRIMARY KEY,
    tenph NVARCHAR(40),
    diachi NVARCHAR(50),
    tel CHAR(10)
);
GO

-- 2. Bảng NhanVien (Nhân viên)
CREATE TABLE NhanVien (
    manv CHAR(5) PRIMARY KEY,
    hoten NVARCHAR(40),
    gioitinh NCHAR(3), -- Nam/Nữ
    ngaysinh DATE,
    luong INT,
    maph CHAR(3) REFERENCES Phong(maph),
    sdt CHAR(10),
    ngaybc DATE -- Ngày biên chế
);
GO

-- 3. Bảng DMNN (Danh mục ngoại ngữ)
CREATE TABLE DMNN (
    mann CHAR(2) PRIMARY KEY,
    tennn NVARCHAR(20)
);
GO

-- 4. Bảng TDNN (Trình độ ngoại ngữ)
CREATE TABLE TDNN (
    manv CHAR(5) REFERENCES NhanVien(manv),
    mann CHAR(2) REFERENCES DMNN(mann),
    tdo CHAR(1), -- Ví dụ: A, B, C
    PRIMARY KEY (manv, mann)
);
GO

/* =======================================================
   PHẦN 2: VIEWS (YÊU CẦU 1 - 5)
   ======================================================= */

-- Yêu cầu 1: Hiển thị các nhân viên có lương từ 9.000.000 trở lên
CREATE VIEW vNhanVien_Luong AS
SELECT manv, hoten, gioitinh, luong, maph
FROM NhanVien
WHERE luong >= 9000000;
GO

-- Yêu cầu 2: View vNVANH gồm mã NV, tên NV, trình độ tiếng Anh
CREATE VIEW vNVANH AS
SELECT nv.manv, nv.hoten, td.tdo
FROM NhanVien nv
JOIN TDNN td ON nv.manv = td.manv
JOIN DMNN dm ON td.mann = dm.mann
WHERE dm.tennn LIKE N'%Anh%'; -- Giả định tên ngôn ngữ chứa chữ 'Anh'
GO

-- Yêu cầu 3: Cho biết số nhân viên của mỗi phòng ban
CREATE VIEW vThongKeNhanVienPhong AS
SELECT p.maph, p.tenph, COUNT(nv.manv) AS SoLuongNhanVien
FROM Phong p
LEFT JOIN NhanVien nv ON p.maph = nv.maph
GROUP BY p.maph, p.tenph;
GO

-- Yêu cầu 4: Liệt kê các nhân viên biết ít nhất 2 ngoại ngữ
CREATE VIEW NhanVien_BietNhieuNgoaiNgu AS
SELECT nv.manv, nv.hoten, COUNT(td.mann) AS SoLuongNgoaiNgu
FROM NhanVien nv
JOIN TDNN td ON nv.manv = td.manv
GROUP BY nv.manv, nv.hoten
HAVING COUNT(td.mann) >= 2;
GO

-- Yêu cầu 5: Hiển thị các phòng ban chưa có nhân viên nào
CREATE VIEW Phong_KhongNhanVien AS
SELECT maph, tenph
FROM Phong
WHERE maph NOT IN (SELECT DISTINCT maph FROM NhanVien WHERE maph IS NOT NULL);
GO

/* =======================================================
   PHẦN 3: STORED PROCEDURES (YÊU CẦU 6 - 10)
   ======================================================= */

-- Yêu cầu 6: Thủ tục thêm mới một phòng ban
CREATE PROCEDURE sp_ThemPhong
    @maph CHAR(3),
    @tenph NVARCHAR(40),
    @diachi NVARCHAR(50),
    @tel CHAR(10)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Phong WHERE maph = @maph)
    BEGIN
        PRINT N'Lỗi: Mã phòng đã tồn tại!';
        RETURN;
    END

    INSERT INTO Phong(maph, tenph, diachi, tel)
    VALUES (@maph, @tenph, @diachi, @tel);
    
    PRINT N'Thêm phòng thành công!';
END;
GO

-- Yêu cầu 7: Thủ tục in danh sách tất cả nhân viên
CREATE PROCEDURE sp_inDanhSachNV
AS
BEGIN
    SELECT * FROM NhanVien;
END;
GO

-- Yêu cầu 8: Thủ tục hiển thị danh sách nhân viên biết ngoại ngữ (theo mã ngoại ngữ truyền vào)
CREATE PROCEDURE sp_NhanVien_BietNgoaiNgu
    @mann CHAR(2)
AS
BEGIN
    SELECT nv.manv, nv.hoten, dm.tennn, td.tdo
    FROM NhanVien nv
    JOIN TDNN td ON nv.manv = td.manv
    JOIN DMNN dm ON td.mann = dm.mann
    WHERE td.mann = @mann;
END;
GO

-- Yêu cầu 9: Thủ tục thống kê số lượng nhân viên của từng phòng ban
CREATE PROCEDURE sp_ThongKeNhanVien
AS
BEGIN
    SELECT p.tenph, COUNT(nv.manv) AS SoLuongNV
    FROM Phong p
    LEFT JOIN NhanVien nv ON p.maph = nv.maph
    GROUP BY p.tenph;
END;
GO

-- Yêu cầu 10: Thủ tục xóa nhân viên theo mã (Xử lý xóa bảng con TDNN trước)
CREATE PROCEDURE sp_XoaNhanVien
    @manv CHAR(5)
AS
BEGIN
    -- Kiểm tra nhân viên có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE manv = @manv)
    BEGIN
        PRINT N'Không tìm thấy nhân viên để xóa.';
        RETURN;
    END

    BEGIN TRANSACTION
        BEGIN TRY
            -- Bước 1: Xóa dữ liệu liên quan ở bảng TDNN
            DELETE FROM TDNN WHERE manv = @manv;
            
            -- Bước 2: Xóa nhân viên ở bảng NhanVien
            DELETE FROM NhanVien WHERE manv = @manv;
            
            COMMIT TRANSACTION;
            PRINT N'Đã xóa nhân viên thành công.';
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            PRINT N'Lỗi khi xóa: ' + ERROR_MESSAGE();
        END CATCH
END;
GO

/* =======================================================
   PHẦN 4: FUNCTIONS (YÊU CẦU 11 - 15)
   ======================================================= */

-- Yêu cầu 11: Hàm trả về danh sách nhân viên thuộc phòng ban (Table-valued Function)
CREATE FUNCTION fn_DSNhanVienPhong (@maph CHAR(3))
RETURNS TABLE
AS
RETURN (
    SELECT manv, hoten, ngaysinh, luong, sdt
    FROM NhanVien
    WHERE maph = @maph
);
GO

-- Yêu cầu 12: Hàm trả về các nhân viên biết từ 2 ngoại ngữ trở lên (Table-valued Function)
CREATE FUNCTION fn_NhanVien_CoNhieuNn ()
RETURNS TABLE
AS
RETURN (
    SELECT nv.manv, nv.hoten
    FROM NhanVien nv
    JOIN TDNN td ON nv.manv = td.manv
    GROUP BY nv.manv, nv.hoten
    HAVING COUNT(td.mann) >= 2
);
GO

-- Yêu cầu 13: Hàm kiểm tra tuổi nghỉ hưu (Scalar Function)
-- Quy định: Nam >= 60, Nữ >= 55
CREATE FUNCTION fn_kiemtraHuu (@manv CHAR(5))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @tuoi INT;
    DECLARE @gioitinh NCHAR(3);
    DECLARE @ketqua NVARCHAR(50);

    -- Lấy thông tin
    SELECT @gioitinh = gioitinh, 
           @tuoi = DATEDIFF(YEAR, ngaysinh, GETDATE())
    FROM NhanVien
    WHERE manv = @manv;

    -- Kiểm tra
    IF (@gioitinh = N'Nam' AND @tuoi >= 60) OR 
       (@gioitinh = N'Nữ' AND @tuoi >= 55)
        SET @ketqua = N'Đã đủ tuổi nghỉ hưu';
    ELSE
        SET @ketqua = N'Chưa đủ tuổi nghỉ hưu';

    RETURN @ketqua;
END;
GO

-- Yêu cầu 14: Hàm tính thâm niên công tác (Scalar Function)
CREATE FUNCTION fn_TinhThamNien (@manv CHAR(5))
RETURNS INT
AS
BEGIN
    DECLARE @thamnien INT;

    SELECT @thamnien = DATEDIFF(YEAR, ngaybc, GETDATE())
    FROM NhanVien
    WHERE manv = @manv;

    IF @thamnien IS NULL SET @thamnien = 0;

    RETURN @thamnien;
END;
GO

-- Yêu cầu 15: Hàm trả về danh sách các phòng ban có lương trung bình > 8.000.000
CREATE FUNCTION fn_PhongLuongTrungBinhCao ()
RETURNS TABLE
AS
RETURN (
    SELECT p.maph, p.tenph, AVG(nv.luong) AS LuongTrungBinh
    FROM Phong p
    JOIN NhanVien nv ON p.maph = nv.maph
    GROUP BY p.maph, p.tenph
    HAVING AVG(nv.luong) > 8000000
);
GO
