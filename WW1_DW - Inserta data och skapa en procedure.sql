use [WW1_DW] -- Här ser vi till så att vi är inne på rätt databas
go

-- DimDate-- 
---- Här skapas en loop för att fylla på tabellen från 2016-01-01 till dagens datum.

DECLARE @StartDate Date = '2012-12-31' -- Datumet DimDate ska starta ifrån, har manuellt kollat när den första ordern är lagd i WideWorldImporters.
DECLARE @CurrentDate DateTime = Getdate() -- Datumet DimDate ska fylla på till.

WHILE (@StartDate < @CurrentDate) -- Skapar en loop, fyller på tabellen när startdate är mindre än @CurrentDate
BEGIN
	IF @StartDate != @CurrentDate -- Om startdatumet inte är lika med dagens datum så fyller vi på en dag i taget.
		BEGIN
			SET @StartDate = DATEADD(DAY,1,@StartDate)
		END
	IF @StartDate = @CurrentDate -- Om startdatumet är lika med dagens datum så stannar vi loopen.
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
INSERT INTO DimProduct -- Insertar dom kolumnerna vi behöver från WideWorldImporters.Warehouse.StockItems
SELECT 
	StockItemID, 
	StockItemName 
	

FROM WideWorldImporters.[Warehouse].[StockItems]

WHERE StockItemID not in -- Här använder vi en sub-query för att slippa dubbletter
	(
	SELECT StockItemID from DimProduct
	)
GO 
---DimSalespersonPersonID
INSERT INTO DimSalesPerson -- Insertar dom kolumnerna vi behöver från WideWorldImporters.Application.People

	SELECT 
		PersonID, 
		SUBSTRING(FullName, CHARINDEX(' ', FullName) +1, 20), -- Tar endast fram efternamnet från FullName
		FullName

	

	FROM [WideWorldImporters].[Application].[People]

WHERE issalesperson = 1 and PersonID not in -- Här tar vi endast fram personer som är säljare och använder "not in" för att skippa dubbletter.
	(
	SELECT PersonID from DimSalesPerson
	)
GO
--DimCustomer--
INSERT INTO DimCustomer -- Insertar dom kolumnerna vi behöver från WideWorldImporters.Sales.Customer & WideWorldImporters.Sales.CustomerCategories
	SELECT
		CustomerID, 
		CustomerName, 
		CustomerCategoryName

	FROM WideWorldImporters.[Sales].[Customers] SC

	inner join WideWorldImporters.Sales.CustomerCategories SCC -- Använder en join för att kunna ta data från båda tabeller
	on SC.CustomerCategoryID = SCC.CustomerCategoryID 
	
WHERE CustomerID not in
	(
	SELECT CustomerID from DimCustomer
	)
GO

--FactSales--
INSERT INTO FactSales -- Insertar dom kolumnerna vi behöver från WideWorldImporters.Sales.OrderLines & WideWorldImporters.Sales.Orders
SELECT 

	SO.CustomerID,
	SO.SalespersonPersonID,
	SOL.StockItemID,
	replace(convert(char(8),SO.OrderDate,112),'-', ' ') as Date,
	SOL.Quantity,
	SOL.UnitPrice,
	cast(SOL.UnitPrice * Quantity  as decimal (10,2)) as 'Sales'

FROM WideWorldImporters.Sales.OrderLines SOL -- Använder en join för att kunna ta data från båda tabeller
	inner join WideWorldImporters.Sales.Orders SO
	on SOL.OrderID = SO.OrderID

	
WHERE CustomerID not in  -- Här använder vi en sub-query för att slippa dubbletter
	(
	SELECT CustomerID from FactSales
	)
ORDER BY OrderDate
GO

-------------------------------------------------------------------------
-- Här är en procedure för att manuellt fylla på DimDate tabellen. Tar endast in ny data, så inga dubletter vilket är toppen!

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



-- För att testa så kan du använda: SP_FillDate '2022-12-10', '2022-12-15'


