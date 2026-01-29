CREATE OR ALTER FUNCTION dbo.fc_docsonguyen (@so INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN
        CASE @so
            WHEN 0 THEN N'Không'
            WHEN 1 THEN N'Một'
            WHEN 2 THEN N'Hai'
            WHEN 3 THEN N'Ba'
            WHEN 4 THEN N'Bốn'
            WHEN 5 THEN N'Năm'
            WHEN 6 THEN N'Sáu'
            WHEN 7 THEN N'Bảy'
            WHEN 8 THEN N'Tám'
            WHEN 9 THEN N'Chín'
            WHEN 10 THEN N'Mười'
            ELSE N''
        END
END
GO

-- Bài 1: Viết hàm fc_tachho tách họ từ chuỗi họ tên
-- Ví dụ: Nguyễn Văn Nam -> Nguyễn
CREATE OR ALTER FUNCTION dbo.fc_tachho (@hoten NVARCHAR(100))
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @ho NVARCHAR(20)
    SET @hoten = LTRIM(RTRIM(@hoten))

    IF CHARINDEX(' ', @hoten) > 0
        SET @ho = LEFT(@hoten, CHARINDEX(' ', @hoten) - 1)
    ELSE
        SET @ho = @hoten

    RETURN @ho
END
GO

-- Bài 3: Viết hàm fc_tachten tách tên từ chuỗi họ tên (Làm bài 3 trước để hỗ trợ bài 2)
-- Ví dụ: Nguyễn Văn Nam -> Nam
CREATE OR ALTER FUNCTION dbo.fc_tachten (@hoten NVARCHAR(100))
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @ten NVARCHAR(20)
    SET @hoten = LTRIM(RTRIM(@hoten))

    IF CHARINDEX(' ', @hoten) > 0
        SET @ten = RIGHT(@hoten, CHARINDEX(' ', REVERSE(@hoten)) - 1)
    ELSE
        SET @ten = @hoten

    RETURN @ten
END
GO

-- Bài 2: Viết hàm fc_tachhodem tách họ đệm (chữ lót)
-- Ví dụ: Nguyễn Văn Nam -> Văn
CREATE OR ALTER FUNCTION dbo.fc_tachhodem (@hoten NVARCHAR(100))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @hodem NVARCHAR(50)
    SET @hoten = LTRIM(RTRIM(@hoten))

    DECLARE @firstSpace INT = CHARINDEX(' ', @hoten)
    DECLARE @lastSpace INT = LEN(@hoten) - CHARINDEX(' ', REVERSE(@hoten)) + 1

    IF @firstSpace > 0 AND @lastSpace > @firstSpace
        SET @hodem = SUBSTRING(@hoten, @firstSpace + 1, @lastSpace - @firstSpace - 1)
    ELSE
        SET @hodem = N''

    RETURN @hodem
END
GO

-- Bài 4: Viết hàm fc_doc3so đọc số có 3 chữ số
-- Ví dụ: 123 -> Một trăm hai mươi ba
CREATE OR ALTER FUNCTION dbo.fc_doc3so (@so INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    IF @so = 0 RETURN N'Không'

    DECLARE @tram INT, @chuc INT, @donvi INT
    DECLARE @kq NVARCHAR(100) = N''

    SET @tram = @so / 100
    SET @chuc = (@so % 100) / 10
    SET @donvi = @so % 10

    IF @tram > 0
        SET @kq = dbo.fc_docsonguyen(@tram) + N' trăm '

    IF @chuc > 1
        SET @kq += dbo.fc_docsonguyen(@chuc) + N' mươi '
    ELSE IF @chuc = 1
        SET @kq += N' mười '
    ELSE IF @chuc = 0 AND @tram > 0 AND @donvi > 0
        SET @kq += N' lẻ '

    IF @donvi > 0
    BEGIN
        IF @donvi = 1 AND @chuc > 1
            SET @kq += N' mốt'
        ELSE IF @donvi = 5 AND @chuc > 0
            SET @kq += N' lăm'
        ELSE
            SET @kq += dbo.fc_docsonguyen(@donvi)
    END

    RETURN LTRIM(@kq)
END
GO

-- Bài 5: Viết hàm fc_doc10so (đọc số lớn, ví dụ tiền tệ)
-- Logic: Tách thành các cụm Tỷ - Triệu - Nghìn - Đồng và gọi fc_doc3so
CREATE OR ALTER FUNCTION dbo.fc_doc10so (@so BIGINT)
RETURNS NVARCHAR(500)
AS
BEGIN
    IF @so = 0 RETURN N'Không'

    DECLARE @ty INT, @trieu INT, @nghin INT, @dong INT
    DECLARE @kq NVARCHAR(500) = N''

    SET @ty = @so / 1000000000
    SET @trieu = (@so % 1000000000) / 1000000
    SET @nghin = (@so % 1000000) / 1000
    SET @dong = @so % 1000

    IF @ty > 0 SET @kq += dbo.fc_doc3so(@ty) + N' tỷ '
    IF @trieu > 0 SET @kq += dbo.fc_doc3so(@trieu) + N' triệu '
    IF @nghin > 0 SET @kq += dbo.fc_doc3so(@nghin) + N' nghìn '
    IF @dong > 0 SET @kq += dbo.fc_doc3so(@dong)

    RETURN LTRIM(RTRIM(@kq))
END
GO

-- Bài 6: Tính doanh thu của năm chỉ định
CREATE OR ALTER FUNCTION dbo.fc_doanhthunam (@nam INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @doanhthu FLOAT
    
    SELECT @doanhthu = SUM(ct.SoLuong * ct.DonGia)
    FROM dbo.HoaDon hd
    JOIN dbo.ChiTietHoaDon ct ON hd.MaHD = ct.MaHD
    WHERE YEAR(hd.NgayLap) = @nam

    RETURN ISNULL(@doanhthu, 0)
END
GO

-- Bài 7: Tính doanh thu của mặt hàng chỉ định
CREATE OR ALTER FUNCTION dbo.fc_doanhthumathang (@mahang CHAR(10))
RETURNS FLOAT
AS
BEGIN
    DECLARE @doanhthu FLOAT
    
    SELECT @doanhthu = SUM(SoLuong * DonGia)
    FROM dbo.ChiTietHoaDon
    WHERE MaHang = @mahang

    RETURN ISNULL(@doanhthu, 0)
END
GO

-- Bài 8: Tính doanh thu của khách hàng chỉ định
CREATE OR ALTER FUNCTION dbo.fc_doanhthuKH (@makh CHAR(10))
RETURNS FLOAT
AS
BEGIN
    DECLARE @doanhthu FLOAT
    
    SELECT @doanhthu = SUM(ct.SoLuong * ct.DonGia)
    FROM dbo.HoaDon hd
    JOIN dbo.ChiTietHoaDon ct ON hd.MaHD = ct.MaHD
    WHERE hd.MaKH = @makh

    RETURN ISNULL(@doanhthu, 0)
END
GO

-- Bài 9: Đếm số lần mua hàng của khách hàng chỉ định
CREATE OR ALTER FUNCTION dbo.fc_solanmuahang (@makh CHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @solan INT
    
    SELECT @solan = COUNT(MaHD)
    FROM dbo.HoaDon
    WHERE MaKH = @makh

    RETURN ISNULL(@solan, 0)
END
GO

-- Bài 10: Tính tổng số lượng bán được của mặt hàng theo tháng chỉ định
-- (Nếu tháng nhập vào NULL hoặc 0 thì tính tất cả các tháng)
CREATE OR ALTER FUNCTION dbo.fc_soluongban (@mahang CHAR(10), @thang INT)
RETURNS INT
AS
BEGIN
    DECLARE @tongsoluong INT
    
    IF @thang IS NULL OR @thang = 0
    BEGIN
        -- Tính tất cả các tháng
        SELECT @tongsoluong = SUM(SoLuong)
        FROM dbo.ChiTietHoaDon
        WHERE MaHang = @mahang
    END
    ELSE
    BEGIN
        -- Tính theo tháng chỉ định
        SELECT @tongsoluong = SUM(ct.SoLuong)
        FROM dbo.ChiTietHoaDon ct
        JOIN dbo.HoaDon hd ON ct.MaHD = hd.MaHD
        WHERE ct.MaHang = @mahang AND MONTH(hd.NgayLap) = @thang
    END

    RETURN ISNULL(@tongsoluong, 0)
END
GO
