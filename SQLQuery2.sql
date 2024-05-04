-- Tạo cơ sở dữ liệu
CREATE DATABASE  baitapvenha;
GO


-- Tạo bảng Môn Học
CREATE TABLE Môn_Học (
    id INT PRIMARY KEY,
    name NVARCHAR(100),
    số_tín_chỉ INT
);
GO

-- Tạo bảng Sinh viên
CREATE TABLE Sv (
    masv VARCHAR(13) PRIMARY KEY,
    name NVARCHAR(100),
    giới_tính BIT,
    lopsv VARCHAR(10)
);
GO

-- Tạo bảng Giáo viên
CREATE TABLE Gv (
    id INT PRIMARY KEY,
    name NVARCHAR(100),
    bộ_môn NVARCHAR(100)
);
GO

-- Tạo bảng Lớp Học Phần
CREATE TABLE LopHP (
    id INT PRIMARY KEY,
    idMon INT,
    họcky INT,
    name NVARCHAR(100),
    idGv INT,
    FOREIGN KEY (idMon) REFERENCES Môn_Học(id),
    FOREIGN KEY (idGv) REFERENCES Gv(id)
);
GO

-- Tạo bảng Đăng ký môn học
CREATE TABLE Dkmh (
    id INT PRIMARY KEY,
    idLopHP INT,
    masv VARCHAR(13),
    điểmKt FLOAT,
    điểmThi FLOAT,
    FOREIGN KEY (idLopHP) REFERENCES LopHP(id),
    FOREIGN KEY (masv) REFERENCES Sv(masv)
);
GO

-- Bài tập 1: Tính điểm trung bình 1 học kỳ của 1 sinh viên
CREATE FUNCTION fn_diem (@hk INT, @masv VARCHAR(13))
RETURNS FLOAT
AS
BEGIN
    DECLARE @diem FLOAT
    
    SELECT @diem = ((điểmKt * 0.4) + (điểmThi * 0.6))
    FROM Dkmh d
    JOIN LopHP l ON d.idLopHP = l.id
    WHERE l.họcky = @hk AND d.masv = @masv

    RETURN @diem
END;
GO


-- Bài tập 2: Tính điểm trung bình học kỳ của 1 lớp sinh viên
CREATE FUNCTION fn_diem_lopsv (@hk INT, @lopsv VARCHAR(10))
RETURNS @kq TABLE (masv VARCHAR(13), name NVARCHAR(50), giới_tính BIT, điểm_tb FLOAT)
AS
BEGIN
    INSERT INTO @kq (masv, name, giới_tính, điểm_tb)
    SELECT sv.masv, sv.name, sv.giới_tính, AVG((dkmh.điểmKt * 0.4) + (dkmh.điểmThi * 0.6)) AS điểm_tb
    FROM Sv sv
    JOIN Dkmh dkmh ON sv.masv = dkmh.masv
    JOIN LopHP lop ON dkmh.idLopHP = lop.id
    WHERE lop.họcky = @hk AND sv.lopsv = @lopsv
    GROUP BY sv.masv, sv.name, sv.giới_tính

    RETURN
END;
GO

-- Bài tập 3: Lấy danh mục môn học, lớp học phần và giáo viên dưới dạng JSON
CREATE PROCEDURE sp_danh_muc(@hk INT)
AS
BEGIN
    SELECT (
        SELECT id, name, số_tín_chỉ
        FROM Môn_Học
        FOR JSON PATH
    ) AS Mon_Hoc,
    (
        SELECT id, idMon, họcky, name, idGv
        FROM LopHP
        WHERE họcky = @hk
        FOR JSON PATH
    ) AS lophp,
    (
        SELECT id, name, bộ_môn
        FROM Gv
        WHERE id IN (SELECT DISTINCT idGv FROM LopHP WHERE họcky = @hk)
        FOR JSON PATH
    ) AS Giáo_viên
    FOR JSON PATH;
END;
GO

-- Bài tập 4: Lấy danh sách đăng ký lớp học phần dưới dạng JSON
CREATE PROCEDURE sp_danh_sach_dk @idLopHP INT
AS
BEGIN
    SELECT *
    FROM Dkmh
    WHERE idLopHP = @idLopHP
    FOR JSON PATH;
END;
GO

-- Bài tập 5: Lấy danh sách môn học của một giáo viên trong một học kỳ dưới dạng JSON
CREATE PROCEDURE sp_monhoc_giaovien @idgv INT, @hk INT
AS
BEGIN
SELECT DISTINCT mh.id, mh.name, mh.số_tín_chỉ
    FROM Môn_Học mh
    JOIN LopHP l ON mh.id = l.idMon
    WHERE l.idGv = @idgv AND l.họcky = @hk
    FOR JSON PATH;
END;
GO
INSERT INTO Môn_Học (id, name, số_tín_chỉ) VALUES
(1, 'Lap trinh huong doi tuong', 3),
(2, 'Co so du lieu', 4),
(3, 'Lap trinh trong moi truong windown', 3);


-- Nhập dữ liệu cho bảng Sinh viên
INSERT INTO Sv (masv, name, giới_tính, lopsv) VALUES
('SV001', 'Bac', 1, 'A1'),
('SV002', 'Nam', 1, 'A1'),
('SV003', 'Thanh', 1, 'A2'),
('SV004', 'Thuan', 1, 'A2'),
('SV005', 'An', 1, 'A3'),
('SV006', 'Binh', 1, 'A2');

-- Nhập dữ liệu cho bảng Giáo viên
INSERT INTO Gv (id, name, bộ_môn) VALUES
(1, 'N.T. Linh', 'CNTT'),
(2, 'N.D Cop', 'CNTT'),
(3, 'N.V. Tinh', 'CNTT');

-- Nhập dữ liệu cho bảng Lớp Học Phần
INSERT INTO LopHP (id, idMon, họcky, name, idGv) VALUES
(101, 1, 1, 'Lap trinh huong doi tuong', 1),
(102, 2, 1, 'Co so du lieu', 2),
(103, 3, 1, 'Lap trinh trong moi truong windown', 3);

-- Nhập dữ liệu cho bảng Đăng ký môn học
INSERT INTO Dkmh (id, idLopHP, masv, điểmKt, điểmThi) VALUES
(1, 101, 'SV001', 1.0, 2.0),
(2, 101, 'SV002', 7.0, 8.0),
(3, 102, 'SV003', 6.5, 8.5),
(4, 103, 'SV004', 9.0, 9.5),
(5, 101, 'SV005', 8.0, 9.0),
(6, 102, 'SV006', 7.5, 8.5);
GO

-- Bài tập 1: Tính điểm trung bình 1 học kỳ của 1 sinh viên
DECLARE @diem_sv1 FLOAT
EXEC @diem_sv1 = fn_diem 1, 'SV001'
PRINT 'Diem trung binh cua Bac trong hoc ki 1: ' + CAST(@diem_sv1 AS VARCHAR(10));

-- Bài tập 2: Tính điểm trung bình học kỳ của 1 lớp sinh viên
SELECT * FROM fn_diem_lopsv(1, 'A1');

-- Bài tập 3: Lấy danh mục môn học, lớp học phần và giáo viên dưới dạng JSON
EXEC sp_danh_muc 1;

-- Bài tập 4: Lấy danh sách đăng ký lớp học phần dưới dạng JSON
EXEC sp_danh_sach_dk 101;

-- Bài tập 5: Lấy danh sách môn học của một giáo viên trong một học kỳ dưới dạng JSON
EXEC sp_monhoc_giaovien 1, 1;