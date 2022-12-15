use [WW1_DW] -- Här ser vi till så att vi är inne på rätt databas
go

-- Den här filen används för att uppdatera våra tabeller. För att skapa ett schema så går vi in på "SQL Server Agent".
-- Vi höger-klickar på "Jobs" och klickar sedan på "New job", på "General" ger vi ett namn till vår nya schedule.
-- På "Steps" klickar vi på "New" och lägger till får query-fil: "Uppdatera data"
-- Sist men inte minst väljer vi "Schedule" och väljer intervallet datan ska uppdateras med, dagvis, månadsvis, veckovis osv.
-- Grattis! Nu kommer vår database ta in ny data från WideWorldImporters.

--DimProduct --
UPDATE DimProduct -- Uppdaterar tabellen och jämför med data från WideWorldImporters, lägger till data om ny data har tillkommit
	SET	
	SKUNumber = WSI.StockItemID,
	ProductName = WSI.StockItemName
	
FROM WideWorldImporters.[Warehouse].[StockItems] WSI
	inner join dbo.DimProduct DP
	on WSI.StockItemID = DP.SKUNumber
WHERE
	SKUNumber != WSI.StockItemID -- Här använder vi != "inte lika med" för att endast få fram ny data från WideWorldImporters.
	or ProductName != WSI.StockItemName

--DimSalesPerson--

UPDATE DimSalesPerson -- Uppdaterar tabellen och jämför med data från WideWorldImporters, lägger till data om ny data har tillkommit
	SET	
	SalesPersonPersonID = AP.PersonID,
	Lastname = SUBSTRING(AP.FullName, CHARINDEX(' ', AP.FullName) +1, 20),
	Fullname = AP.FullName
	
FROM[WideWorldImporters].[Application].[People] AP
	inner join dbo.DimSalesPerson DSP
	on AP.PersonID = DSP.SalesPersonPersonID
WHERE
	SalesPersonPersonID != AP.PersonID
	or DSP.LastName != SUBSTRING(AP.FullName, CHARINDEX(' ', AP.FullName) +1, 20) -- Här använder vi != "inte lika med" för att endast få fram ny data från WideWorldImporters.
	or DSP.FullName != AP.FullName

--DimCustomer--

UPDATE DimCustomer -- Uppdaterar tabellen och jämför med data från WideWorldImporters, lägger till data om ny data har tillkommit
	SET	
	CustomerID = SC.CustomerID,
	CustomerName = SC.CustomerName,
	CustomerCategoryName = SCC.CustomerCategoryName
	
FROM WideWorldImporters.[Sales].[Customers] SC
	inner join dbo.DimCustomer DC
	on SC.CustomerID = DC.CustomerID
	inner join WideWorldImporters.Sales.[CustomerCategories]  SCC
	on SC.CustomerCategoryID = SCC.CustomerCategoryID
WHERE
	DC.CustomerID != SC.CustomerID -- Här använder vi != "inte lika me" för att endast få fram ny data från WideWorldImporters.
	or DC.CustomerName != SC.CustomerName 
	or DC.CustomerCategoryName != SCC.CustomerCategoryName

