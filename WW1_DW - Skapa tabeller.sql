CREATE DATABASE WW1_DW -- Här skapar vi vår databas (default)
COLLATE Latin1_General_100_CI_AS -- Det visade sig lite senare att WideWorldImporters använder: Latin1_General_100_CI_AS
								 -- Vi använder samma collation så det inte uppstår problem med updates i ett senare skede
								 -- Foolproof!
go

use [WW1_DW] -- Här ser vi till så att vi är inne på rätt databas
go

SET DATEFIRST 1 -- Här ändrar vi så att veckan startar enligt svensk standard (från och med måndag)
SET LANGUAGE Svenska -- Ändrar språket till svenska

CREATE TABLE DimDate  -- Här skapar vi DimDate tabellen
( 
DateID int primary key, 
Date varchar(25), 
DayOfWeekName varchar(10), 
DayOfWeekNumber int, 
DayOfNumberInMonth int, 
Week int, -- 7
MonthName varchar(10), 
MonthNumber int, 
QuarterName varchar(5),
QuarterNumber int, 
Year int, 
)
GO
           
CREATE TABLE DimProduct  -- Här skapar vi DimProduct tabellen
( 
ProductID int identity(1,1) primary key,
SKUNumber int,
ProductName varchar (200),
)
GO

CREATE TABLE DimSalesPerson -- Här skapar vi DimSalesPerson tabellen
(
SalesPersonPersonID int primary key,
Lastname varchar(100),
Fullname varchar(200)
)
GO


CREATE TABLE DimCustomer -- Här skapar vi DimCustomer tabellen
(
CustomerID int primary key,
CustomerName varchar(200),
CustomerCategoryName varchar(200),
)
GO

CREATE TABLE FactSales -- Här skapar vi FactSales tabellen, FK = Foreign Key
(
SalesID int identity(1,1) primary key,
CustomerID int, -- fk
SalesPersonPersonID int, -- fk
ProductID int, -- fk
OrderDateID int, -- fk
Quantity int,
UnitPrice int,
Sales int,
Constraint FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID), -- CustomerID
Constraint FK_SalesPersonPersonID FOREIGN KEY (SalesPersonPersonID) REFERENCES DimSalesPerson(SalesPersonPersonID), --SalesPersonPersonID
Constraint FK_ProductID FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID), --ProductID
Constraint FK_OrderDateID FOREIGN KEY (OrderDateID) REFERENCES DimDate(DateID) --OrderDateID
)
GO

-- Här skapar vi index för att snabba på sökningar på kolumner som används flitigt (enligt mig)
CREATE INDEX DimProduct_Index
ON DimProduct (ProductName)
GO

CREATE INDEX DimSalesPerson_Index -- Något onödig index då det endast finns 10 rows i DimSalesPerson, men man ska alltid framtidssäkra!
ON DimSalesPerson (LastName)

CREATE INDEX DimCustomer_Index
ON DimCustomer (CustomerName)

