﻿CREATE DATABASE QLCUOCTHIHAT
USE QLCUOCTHIHAT

--PHẦN 1:TẠO CƠ SỞ DỮ LIỆU TRÊN SQL SERVER
--BẢNG 1
CREATE TABLE NGUOI(
ID CHAR(12) PRIMARY KEY,
CMND CHAR(15) NOT NULL,
TEN NVARCHAR(20) NOT NULL,
GIOITINH INT CHECK(GIOITINH = 1 OR GIOITINH = 0) NOT NULL,
NGAYSINH DATE NOT NULL,
NOISINH NVARCHAR(20) NOT NULL,
CHECK(ID LIKE '[TS|NS][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
GO
-- BẢNG 2
CREATE TABLE THISINH(
MATHISINH CHAR(12) PRIMARY KEY,
DIACHI NVARCHAR(20) NOT NULL,
DIENTHOAI INT NOT NULL,
GIOITHIEU NVARCHAR(MAX),
FOREIGN KEY(MATHISINH) REFERENCES NGUOI(ID) ON UPDATE CASCADE ON DELETE CASCADE,
CHECK(MATHISINH LIKE '[TS][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
GO
--BẢNG 3
CREATE TABLE NGHESI(
MANGHESI CHAR(12) PRIMARY KEY,
NGHEDANH NVARCHAR(20) NOT NULL,
THANHTICH NVARCHAR(MAX) NOT NULL,
MCFlag INT CHECK(MCFlag = 0 OR MCFlag = 1),
CSFlag INT CHECK(CSFlag = 0 OR CSFlag = 1),
NSFlag INT CHECK(NSFlag = 0 OR NSFlag = 1),
FOREIGN KEY(MANGHESI) REFERENCES NGUOI(ID) ON UPDATE CASCADE ON DELETE CASCADE,
CHECK(MANGHESI LIKE '[NS][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
GO
--BẢNG 4
CREATE TABLE CHUONGTRINHMC(
MAMC CHAR(12) NOT NULL,
CHUONGTRINHDADAN NVARCHAR(20),
MAMT CHAR(4) FOREIGN KEY REFERENCES MUATHI(MAMUATHI),
PRIMARY KEY(MAMC, CHUONGTRINHDADAN),
FOREIGN KEY(MAMC) REFERENCES NGHESI(MANGHESI) ON UPDATE CASCADE ON DELETE CASCADE,
)
GO
--BẢNG 5
CREATE TABLE ALBUMCS(
MACS CHAR(12) NOT NULL,
ALBUM NVARCHAR(20) NOT NULL,
PRIMARY KEY(MACS, ALBUM),
FOREIGN KEY(MACS) REFERENCES NGHESI(MANGHESI) ON UPDATE CASCADE ON DELETE CASCADE,
)
GO
--BẢNG 6
CREATE TABLE BAIHAT(
MABAIHAT CHAR(8) PRIMARY KEY,
TUABAIHAT NVARCHAR(20) NOT NULL,
CHECK(MABAIHAT LIKE '[BH][0-9][0-9][0-9][0-9][0-9][0-9]')
)
GO
--BẢNG 7
CREATE TABLE THELOAI(
MATHELOAI CHAR(5) PRIMARY KEY,
TENTHELOAI NVARCHAR(20) NOT NULL UNIQUE,
CHECK(MATHELOAI LIKE '[TL][0-9][0-9][0-9]')
)
GO
--BẢNG 8
CREATE TABLE BAIHATTHELOAI(
MABAIHAT CHAR(8) FOREIGN KEY REFERENCES BAIHAT(MABAIHAT),
MATHELOAI CHAR(5) FOREIGN KEY REFERENCES THELOAI(MATHELOAI),
PRIMARY KEY(MABAIHAT,MATHELOAI)
)
GO
--BẢNG 9
CREATE TABLE NSSANGTAC(
MANS CHAR(12) FOREIGN KEY REFERENCES NGHESI(MANGHESI),
MABAIHAT CHAR(8) FOREIGN KEY REFERENCES BAIHAT(MABAIHAT),
THONGTINSANGTAC INT NOT NULL,
MAMT CHAR(4) FOREIGN KEY REFERENCES MUATHI(MAMUATHI),
CHECK (THONGTINSANGTAC = 1 OR THONGTINSANGTAC = 2 OR THONGTINSANGTAC = 3),
PRIMARY KEY(MANS,MABAIHAT)
)
GO
--BẢNG 10
CREATE TABLE TINHTHANH(
MATINHTHANH CHAR(4) PRIMARY KEY,
TENTINHTHANH NVARCHAR(20) NOT NULL UNIQUE,
CHECK(MATINHTHANH LIKE '[TT][0-9][0-9]')
)
GO
--BẢNG 11
CREATE TABLE NHASANXUAT(
MANSX CHAR(6) PRIMARY KEY,
TENNSX NVARCHAR(20) NOT NULL,
CHECK(MANSX LIKE '[NSX][0-9][0-9][0-9]')
)
GO
--BẢNG 12
CREATE TABLE KENHTRUYENHINH(
MAKTH CHAR(6) PRIMARY KEY,
TENKENH NVARCHAR(20) NOT NULL,
CHECK(MAKTH LIKE '[TH][0-9][0-9][0-9]')
)
GO
------------------HÀM TỰ ĐỘNG TĂNG CHO ID MÙA THI------------------------
CREATE FUNCTION AUTO_IDMT()
RETURNS CHAR(4)
AS
BEGIN
	DECLARE @ID CHAR(4)
	IF (SELECT COUNT(MAMUATHI) FROM MUATHI) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(MAMUATHI, 2)) FROM MUATHI
		SELECT @ID = CASE
			WHEN @ID >= 0 and @ID < 9 THEN 'MT0' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
			WHEN @ID >= 9 THEN 'MT' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
		END
	RETURN @ID
END
----------------------------------------------------------

GO
--BẢNG 13
CREATE TABLE MUATHI (
MAMUATHI CHAR(4) PRIMARY KEY DEFAULT DBO.AUTO_IDMT(),
NGAYBD DATE,
NGAYKT DATE,
GIAITHUONG NVARCHAR(MAX),
DIADIEMNHAHAT NVARCHAR(50),
DIADIEMBANKET NVARCHAR(50),
DIADIEMGALA NVARCHAR(50),
MABAIHAT CHAR(8),
MAGIAMDOC CHAR(12) UNIQUE,
GIAMKHAO1 CHAR(12) UNIQUE,
GIAMKHAO2 CHAR(12) UNIQUE,
GIAMKHAO3 CHAR(12) UNIQUE,
MAMC CHAR(12) UNIQUE,
CHUONGTRINHDADAN NVARCHAR(20),
CHECK(NGAYKT > NGAYBD),
FOREIGN KEY(GIAMKHAO1) REFERENCES NGHESI(MANGHESI),
FOREIGN KEY(GIAMKHAO2) REFERENCES NGHESI(MANGHESI),
FOREIGN KEY(GIAMKHAO3) REFERENCES NGHESI(MANGHESI),
)
GO

ALTER TABLE MUATHI ADD CONSTRAINT FK_MUATHI_MAGIAMDOCBH_SANGTAC FOREIGN KEY(MAGIAMDOC, MABAIHAT) REFERENCES NSSANGTAC(MANS, MABAIHAT)
ALTER TABLE MUATHI ADD CONSTRAINT FK_MUATHI_MC_CTMC FOREIGN KEY(MAMC, CHUONGTRINHDADAN) REFERENCES CHUONGTRINHMC(MAMC, CHUONGTRINHDADAN)


--BẢNG 14
CREATE TABLE BANQUYENMT(
MAMT CHAR(4),
MANSX CHAR(6),
PRIMARY KEY(MAMT, MANSX),
FOREIGN KEY(MAMT) REFERENCES MUATHI(MAMUATHI),
FOREIGN KEY(MANSX) REFERENCES NHASANXUAT(MANSX)
)

-- BẢNG 15
CREATE TABLE PHATSONG(
MAMT CHAR(4),
MAKENH CHAR(6),
THONGTINPHATSONG INT,
PRIMARY KEY(MAMT, MAKENH),
FOREIGN KEY(MAMT) REFERENCES MUATHI(MAMUATHI),
FOREIGN KEY(MAKENH) REFERENCES KENHTRUYENHINH(MAKTH)
)

-- BẢNG 16
CREATE TABLE VONGTHI(
STTVT INT IDENTITY(1,1),
MAMT CHAR(4) FOREIGN KEY REFERENCES MUATHI(MAMUATHI),
TENVT NVARCHAR(20),
THOIGIANBD DATETIME,
THOIGIANKT DATETIME,
--TEST--
LOAIVT NVARCHAR(50) CHECKVONGTHI(LOAIVT),
CHECK (THOIGIANBD < THOIGIANKT),
PRIMARY KEY(STTVT,MAMT)
)
GO
CREATE FUNCTION CHECKKETQUA()

--BẢNG 17
CREATE TABLE THISINHTG(
STTVT INT,
MAMT CHAR(4),
MATHISINH CHAR(12) FOREIGN KEY REFERENCES  THISINH(MATHISINH),
KETQUA INT DEFAULT -1,
PRIMARY KEY(STTVT,MAMT,MATHISINH)
)

ALTER TABLE THISINHTG ADD CONSTRAINT FK_THISINHTG_STTVT_VONGTHI FOREIGN KEY(STTVT,MAMT) REFERENCES VONGTHI(STTVT,MAMT)

--BẢNG 18
