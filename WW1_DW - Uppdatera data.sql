use [WW1_DW] -- H�r ser vi till s� att vi �r inne p� r�tt databas
go

-- Den h�r filen anv�nds f�r att uppdatera v�ra tabeller. F�r att skapa ett schema s� g�r vi in p� "SQL Server Agent".
-- Vi h�ger-klickar p� "Jobs" och klickar sedan p� "New job", p� "General" ger vi ett namn till v�r nya schedule.
-- P� "Steps" klickar vi p� "New" och l�gger till f�r query-fil: "Uppdatera data"
-- Sist men inte minst v�ljer vi "Schedule" och v�ljer intervallet datan ska uppdateras med, dagvis, m�nadsvis, veckovis osv.
-- Grattis! Nu kommer v�r database ta in ny data fr�n WideWorldImporters.

--DimProduct --
UPDATE DimProduct -- Uppdaterar tabellen och j�mf�r med data fr�n WideWorldImporters, l�gger till data om ny data har tillkommit
	SET	
	SKUNumber = WSI.StockItemID,
	ProductName = WSI.StockItemName
	
FROM WideWorldImporters.[Warehouse].[StockItems] WSI
	inner join dbo.DimProduct DP
	on WSI.StockItemID = DP.SKUNumber
WHERE
	SKUNumber != WSI.StockItemID -- H�r anv�nder vi != "inte lika med" f�r att endast f� fram ny data fr�n WideWorldImporters.
	or ProductName != WSI.StockItemName

--DimSalesPerson--

UPDATE DimSalesPerson -- Uppdaterar tabellen och j�mf�r med data fr�n WideWorldImporters, l�gger till data om ny data har tillkommit
	SET	
	SalesPersonPersonID = AP.PersonID,
	Lastname = SUBSTRING(AP.FullName, CHARINDEX(' ', AP.FullName) +1, 20),
	Fullname = AP.FullName
	
FROM[WideWorldImporters].[Application].[People] AP
	inner join dbo.DimSalesPerson DSP
	on AP.PersonID = DSP.SalesPersonPersonID
WHERE
	SalesPersonPersonID != AP.PersonID
	or DSP.LastName != SUBSTRING(AP.FullName, CHARINDEX(' ', AP.FullName) +1, 20) -- H�r anv�nder vi != "inte lika med" f�r att endast f� fram ny data fr�n WideWorldImporters.
	or DSP.FullName != AP.FullName

--DimCustomer--

UPDATE DimCustomer -- Uppdaterar tabellen och j�mf�r med data fr�n WideWorldImporters, l�gger till data om ny data har tillkommit
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
	DC.CustomerID != SC.CustomerID -- H�r anv�nder vi != "inte lika me" f�r att endast f� fram ny data fr�n WideWorldImporters.
	or DC.CustomerName != SC.CustomerName 
	or DC.CustomerCategoryName != SCC.CustomerCategoryName

