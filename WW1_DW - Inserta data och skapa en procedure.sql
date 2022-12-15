use [WW1_DW] -- H�r ser vi till s� att vi �r inne p� r�tt databas
go

-- DimDate-- 
---- H�r skapas en loop f�r att fylla p� tabellen fr�n 2016-01-01 till dagens datum.

DECLARE @StartDate Date = '2012-12-31' -- Datumet DimDate ska starta ifr�n, har manuellt kollat n�r den f�rsta ordern �r lagd i WideWorldImporters.
DECLARE @CurrentDate DateTime = Getdate() -- Datumet DimDate ska fylla p� till.

WHILE (@StartDate < @CurrentDate) -- Skapar en loop, fyller p� tabellen n�r startdate �r mindre �n @CurrentDate
BEGIN
	IF @StartDate != @CurrentDate -- Om startdatumet inte �r lika med dagens datum s� fyller vi p� en dag i taget.
		BEGIN
			SET @StartDate = DATEADD(DAY,1,@StartDate)
		END
	IF @StartDate = @CurrentDate -- Om startdatumet �r lika med dagens datum s� stannar vi loopen.
		BREAK

INSERT INTO [dbo].[DimDate]
(
[DateID],
[Date],
[DayOfWeekName],
[DayOfWeekNumber], 
[DayOfNumberInMonth], 
[Week],
[MonthName],
[MonthNumber],
[QuarterName],
[QuarterNumber],
[Year]
)




SELECT

	CONVERT(CHAR(8),  @StartDate, 112), -- DateID
	@Startdate, -- Date
	DATENAME(Weekday,  @StartDate), -- DayOfWeekName
	DATEPART (DW,  @StartDate), -- DayOfWeekNumber
	DATEPART (day,  @StartDate), -- DayOfNumberInMonth
	DATEPART (Week,  @StartDate), -- Week
	DATENAME (MONTH,  @StartDate), -- MonthName
	DATEPART(MONTH,  @StartDate), -- MonthNumber
	'Q' + DATENAME(Q,  @StartDate), --QuarterName
	DATENAME(QQ,  @StartDate), --QuarterNumber
	DATEPART(Year, @StartDate) -- Year
	

END
GO

------DimProduct ---- 
INSERT INTO DimProduct -- Insertar dom kolumnerna vi beh�ver fr�n WideWorldImporters.Warehouse.StockItems
SELECT 
	StockItemID, 
	StockItemName 
	

FROM WideWorldImporters.[Warehouse].[StockItems]

WHERE StockItemID not in -- H�r anv�nder vi en sub-query f�r att slippa dubbletter
	(
	SELECT StockItemID from DimProduct
	)
GO 
---DimSalespersonPersonID
INSERT INTO DimSalesPerson -- Insertar dom kolumnerna vi beh�ver fr�n WideWorldImporters.Application.People

	SELECT 
		PersonID, 
		SUBSTRING(FullName, CHARINDEX(' ', FullName) +1, 20), -- Tar endast fram efternamnet fr�n FullName
		FullName

	

	FROM [WideWorldImporters].[Application].[People]

WHERE issalesperson = 1 and PersonID not in -- H�r tar vi endast fram personer som �r s�ljare och anv�nder "not in" f�r att skippa dubbletter.
	(
	SELECT PersonID from DimSalesPerson
	)
GO
--DimCustomer--
INSERT INTO DimCustomer -- Insertar dom kolumnerna vi beh�ver fr�n WideWorldImporters.Sales.Customer & WideWorldImporters.Sales.CustomerCategories
	SELECT
		CustomerID, 
		CustomerName, 
		CustomerCategoryName

	FROM WideWorldImporters.[Sales].[Customers] SC

	inner join WideWorldImporters.Sales.CustomerCategories SCC -- Anv�nder en join f�r att kunna ta data fr�n b�da tabeller
	on SC.CustomerCategoryID = SCC.CustomerCategoryID 
	
WHERE CustomerID not in
	(
	SELECT CustomerID from DimCustomer
	)
GO

--FactSales--
INSERT INTO FactSales -- Insertar dom kolumnerna vi beh�ver fr�n WideWorldImporters.Sales.OrderLines & WideWorldImporters.Sales.Orders
SELECT 

	SO.CustomerID,
	SO.SalespersonPersonID,
	SOL.StockItemID,
	replace(convert(char(8),SO.OrderDate,112),'-', ' ') as Date,
	SOL.Quantity,
	SOL.UnitPrice,
	cast(SOL.UnitPrice * Quantity  as decimal (10,2)) as 'Sales'

FROM WideWorldImporters.Sales.OrderLines SOL -- Anv�nder en join f�r att kunna ta data fr�n b�da tabeller
	inner join WideWorldImporters.Sales.Orders SO
	on SOL.OrderID = SO.OrderID

	
WHERE CustomerID not in  -- H�r anv�nder vi en sub-query f�r att slippa dubbletter
	(
	SELECT CustomerID from FactSales
	)
ORDER BY OrderDate
GO

-------------------------------------------------------------------------
-- H�r �r en procedure f�r att manuellt fylla p� DimDate tabellen. Tar endast in ny data, s� inga dubletter vilket �r toppen!

CREATE PROCEDURE SP_FillDate (@StartDate date, @Currentdate date)
AS
BEGIN

WHILE (@StartDate < @CurrentDate)
BEGIN
	IF @StartDate != @CurrentDate
		BEGIN
			SET @StartDate = DATEADD(DAY,1,@StartDate)
		END
	IF @StartDate = @CurrentDate
		BREAK

INSERT INTO [dbo].[DimDate]
(
[DateID],
[Date],
[DayOfWeekName],
[DayOfWeekNumber], 
[DayOfNumberInMonth], 
[Week],
[MonthName],
[MonthNumber],
[QuarterName],
[QuarterNumber],
[Year]
)




SELECT

	CONVERT(CHAR(8),  @StartDate, 112), -- DateID
	@Startdate, -- Date
	DATENAME(Weekday,  @StartDate), -- DayOfWeekName
	DATEPART (DW,  @StartDate), -- DayOfWeekNumber
	DATEPART (day,  @StartDate), -- DayOfNumberInMonth
	DATEPART (Week,  @StartDate), -- Week
	DATENAME (MONTH,  @StartDate), -- MonthName
	DATEPART(MONTH,  @StartDate), -- MonthNumber
	'Q' + DATENAME(Q,  @StartDate), --QuarterName
	DATENAME(QQ,  @StartDate), --QuarterNumber
	DATEPART(Year, @StartDate) -- Year
WHERE @CurrentDate not in
	(
	SELECT Date FROM DimDate
	)
	

END
END
GO



-- F�r att testa s� kan du anv�nda: SP_FillDate '2022-12-10', '2022-12-15'


