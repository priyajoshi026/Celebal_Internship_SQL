									--TASK1--
USE database [AdventureWorks2019]
GO
--Q1 : List of all Customers--
SELECT 
	P.FirstName
FROM 
	[Person].[Person] P 
	JOIN [Sales].[Customer] C
	ON P.BusinessEntityID=PersonID;

--Q2 List of all the customers where company name ending with 'N"
SELECT 
	PP.FirstName,
	SS.Name
FROM 
	[Person].[Person] PP 
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID
	JOIN [Sales].[Store] SS ON SC.StoreID=SS.BusinessEntityID
WHERE 
	SS.Name LIKE '%n';

--Q3 List of all the customers who live in Berlin or london.
SELECT 
	PP.FirstName,
	PA.City
FROM 
	[Person].[Person] PP 
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID 
	JOIN [Person].[BusinessEntityAddress] BA ON PP.BusinessEntityID=BA.BusinessEntityID
	JOIN  [Person].[Address] PA ON BA.BusinessEntityID=PA.AddressID 
WHERE 
	PA.City IN ('London','Berlin');

--Q4 List of all the customers who live in UK or USA. Country code for UK= GB and USA=US
SELECT 
	PP.FirstName
FROM 
	[Person].[Person] PP 
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID 
	JOIN [Person].[BusinessEntityAddress] PBA ON PP.BusinessEntityID=PBA.BusinessEntityID
	JOIN  [Person].[Address] PA ON PBA.BusinessEntityID=PA.AddressID
	JOIN [Person].[StateProvince] PSP ON PA.StateProvinceID=PSP.StateProvinceID
WHERE 
	PSP.CountryRegionCode IN ('US','GB');

--Q5 List all product ordered by product name
SELECT  
	PrP.ProductID,
	PrP.Name
FROM 
	[Production].[Product] PrP
ORDER BY 
	PrP.Name;

--Q6 List all product ordered by product name starting with 'A'
SELECT  
	PrP.ProductID,
	PrP.Name
FROM 
	[Production].[Product] PrP
WHERE 
	PrP.Name LIKE 'A%';

--Q7 Customers who ever placed an order
SELECT DISTINCT 
	PP.FirstName
FROM  
	[Sales].[Customer] SC 
	JOIN [Person].[Person] PP ON PP.BusinessEntityID=SC.PersonID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID;

--Q8 Customer who live in London and have bought chai
SELECT 
	PP.FirstName
FROM 
	[Person].[Person] PP 
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID 
	JOIN [Person].[BusinessEntityAddress] BA ON PP.BusinessEntityID=BA.BusinessEntityID
	JOIN  [Person].[Address] PA ON BA.BusinessEntityID=PA.AddressID 
	JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
	JOIN [Production].[Product] PrP ON SSOD.ProductID=PrP.ProductID
WHERE 
	PrP.Name='Chai' 
	AND PA.City='London';

--Q9. Customer who never placed an order
SELECT DISTINCT
	PP.FirstName
FROM  
	[Sales].[Customer] SC 
	JOIN [Person].[Person] PP ON PP.BusinessEntityID=SC.PersonID
	LEFT JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID
WHERE 
	SSOH.SalesOrderID IS NULL;

--Q10 Customers who ordered Tofu.
SELECT 
	PP.FirstName
FROM  
	[Sales].[Customer] SC JOIN [Person].[Person] PP ON PP.BusinessEntityID=SC.PersonID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
	JOIN [Production].[Product] PrP ON SSOD.ProductID=PrP.ProductID
WHERE 
	PrP.Name='Tofu';

--Q11 Details of first order of the system
SELECT *
FROM 
	[Sales].[SalesOrderHeader] SSOH
WHERE 
	SSOH.OrderDate=(SELECT MAX(SSOH.OrderDate) 
					FROM [Sales].[SalesOrderHeader] SSOH);

--Q12 Find details of most expensive order date
SELECT *
FROM 
	[Sales].[SalesOrderHeader] SSOH 
WHERE 
	SSOH.OrderDate=(SELECT SSOH.OrderDate 
					FROM [Sales].[SalesOrderHeader] SSOH 
					WHERE SSOH.TotalDue=(SELECT MAX(SSOH.TotalDue) 
										 FROM  [Sales].[SalesOrderHeader] SSOH ));

										
--Q13. For each order get the orderid and average quantity of items in that order
SELECT DISTINCT 
	SSOD.SalesOrderID,
	AVG(SSOD.OrderQty)
FROM 
	[Sales].[SalesOrderDetail] SSOD
GROUP BY 
	SSOD.SalesOrderID;

--Q14  For each order get orderid ,minimum and maximum quantity for thet order.
SELECT 
	SSOD.SalesOrderID,
	MAX(SSOD.OrderQty) MaximumQuantity,
	MIN(SSOD.OrderQty) MinimumQuantity
FROM 
	[Sales].[SalesOrderDetail] SSOD 
GROUP BY 
	SSOD.SalesOrderID;

--Q15 Get a list of all managers and total no. of employee who report to them.
SELECT 
	HRE.BusinessEntityID,
	PP.FirstName,
	COUNT(HREM.BusinessEntityID) EmployeeReporting
FROM 
	[HumanResources].[Employee] HRE
	JOIN [HumanResources].[Employee] HREM on hre.BusinessEntityID<>hrem.BusinessEntityID
	JOIN [HumanResources].[EmployeeDepartmentHistory] HREDH ON HRE.BusinessEntityID=HREDH.BusinessEntityID
	JOIN [HumanResources].[EmployeeDepartmentHistory] HREDHM ON HREM.BusinessEntityID=HREDHM.BusinessEntityID
	JOIN [HumanResources].[Department] HRD ON HREDH.DepartmentID=HRD.DepartmentID
	JOIN [HumanResources].[Department] HRDM ON HREDHM.DepartmentID=HRDM.DepartmentID
	JOIN [Person].[Person] PP ON HRE.BusinessEntityID=PP.BusinessEntityID
WHERE 
	HREDH.DepartmentID=HREDHM.DepartmentID
	AND HRE.JobTitle LIKE '%manager' 
	AND HRE.JobTitle!=HREM.JobTitle
GROUP BY 
	HRE.BusinessEntityID,PP.FirstName
ORDER BY 
	COUNT(HREM.BusinessEntityID) DESC;

--Q16 Get the orderid and total quanity for each orfer that has total quantity of greater than 300
SELECT 
	SSOD.SalesOrderID,
	SUM(SSOD.OrderQty) AS TotalQuatity
FROM 
	[Sales].[SalesOrderDetail] SSOD
GROUP BY 
	SSOD.SalesOrderID
HAVING 
	SUM(SSOD.OrderQty)>300;

--Q17. List of all orders placed on or after 1996/12/31.
SELECT 
	SSOH.SalesOrderID,
	SSOH.OrderDate
FROM 
	[Sales].[SalesOrderHeader] SSOH
WHERE 
	SSOH.OrderDate>='1996-12-31' 
ORDER BY 
	SSOH.OrderDate; 

--Q18. List all orders shipped to cannada
SELECT 
	SSOH.SalesOrderID
FROM 
	[Sales].[SalesOrderHeader] SSOH 
	JOIN [Person].[Address] PA ON SSOH.ShipToAddressID=PA.AddressID
	JOIN [Person].[StateProvince] PSP ON PA.StateProvinceID=PSP.StateProvinceID
	JOIN [Person].[CountryRegion] PCR ON PSP.CountryRegionCode=PCR.CountryRegionCode
WHERE 
	PCR.Name='Canada';

--Q19. List of all order with order total>200 
--Assumption totaldue is order total
SELECT *
FROM 
	[Sales].[SalesOrderHeader] SSOH
WHERE 
	SSOH.TotalDue>200;

--Q20 List of countries and sales made in each country
SELECT 
	PCR.Name,
	SUM(SSOH.TotalDue) TotalSales
FROM 
	[Sales].[SalesOrderHeader] SSOH
	JOIN [Sales].[CurrencyRate] SCR ON SSOH.CurrencyRateID=SCR.CurrencyRateID
	JOIN [Sales].[Currency] SCu ON SCR.ToCurrencyCode=SCu.CurrencyCode
	JOIN [Sales].[CountryRegionCurrency] SCRC ON SCu.CurrencyCode=SCRC.CurrencyCode
	JOIN [Person].[CountryRegion] PCR ON SCRC.CountryRegionCode=PCR.CountryRegionCode
GROUP BY 
	PCR.Name;

--Q21 List of customer contact name and no. of orders they placed
SELECT 
	PPP.PhoneNumber,
	COUNT(SSOH.SalesOrderID) Orders
FROM 
	[Person].[Person] PP
	JOIN [Person].[PersonPhone] PPP ON PP.BusinessEntityID=PPP.BusinessEntityID
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID
GROUP BY 
	PPP.PhoneNumber;

--Q22 List of customer contact names who have placed mmore than 3 orders.
SELECT 
	PPP.PhoneNumber,
	COUNT(SSOH.SalesOrderID) Orders
FROM 
	[Person].[Person] PP
	JOIN [Person].[PersonPhone] PPP ON PP.BusinessEntityID=PPP.BusinessEntityID
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID
GROUP BY 
	PPP.PhoneNumber
HAVING 
	COUNT(SSOH.SalesOrderID)>3;

--Q23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998
SELECT *
FROM 
	[Sales].[SalesOrderHeader] SSOH
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
	JOIN [Production].[Product] PrP ON SSOD.ProductID=PrP.ProductID
WHERE 
	SSOH.OrderDate BETWEEN '01-01-1997' AND '01-01-1998'
	AND PrP.DiscontinuedDate IS NOT NULL;

--Q24 List of employee firstname,lastname,supervisor first name,last name
SELECT 
	PPS.FirstName+' '+PPS.LastName EmployeeName,
	PP.FirstName+' '+PP.LastName SupervisorName
FROM 
	[HumanResources].[Employee] HRE
	JOIN [HumanResources].[EmployeeDepartmentHistory] HREDH ON HRE.BusinessEntityID=HREDH.BusinessEntityID
	JOIN [HumanResources].[Employee] HRES on HRE.BusinessEntityID<>HRES.BusinessEntityID
	JOIN [HumanResources].[EmployeeDepartmentHistory] HREDHS ON HRES.BusinessEntityID=HREDHS.BusinessEntityID
	JOIN [HumanResources].[Department] HRD ON HREDH.DepartmentID=HRD.DepartmentID
	JOIN [HumanResources].[Department] HRDS ON HREDHS.DepartmentID=HRDS.DepartmentID
	JOIN [Person].[Person] PP ON HRE.BusinessEntityID=PP.BusinessEntityID
	JOIN [Person].[Person] PPS ON HRES.BusinessEntityID=PPS.BusinessEntityID
WHERE 
	HREDH.DepartmentID=HREDHS.DepartmentID;

--Q25 List of employee and id and total sales conducted by an employee
SELECT DISTINCT 
	SSOH.SalesPersonID,
	SUM(SSOH.TotalDue) Sales
FROM 
	[Sales].[SalesOrderHeader] SSOH
GROUP BY 
	SSOH.SalesPersonID;

--Q26. List of all employess whose first name contains character a
SELECT 
	PP.FirstName,
	HRE.JobTitle
FROM 
	[Person].[Person] PP 
	JOIN [HumanResources].[Employee] HRE ON PP.BusinessEntityID=HRE.BusinessEntityID
WHERE 
	PP.FirstName LIKE '%a%';

--Q27 List of managers who have more than 4 people reporting to them
SELECT 
	HRE.BusinessEntityID,
	PP.FirstName,
	COUNT(HREM.BusinessEntityID) EmployeeReporting
FROM 
	[HumanResources].[Employee] HRE
	JOIN [HumanResources].[Employee] HREM on hre.BusinessEntityID<>hrem.BusinessEntityID
	JOIN [HumanResources].[EmployeeDepartmentHistory] HREDH ON HRE.BusinessEntityID=HREDH.BusinessEntityID
	JOIN [HumanResources].[EmployeeDepartmentHistory] HREDHM ON HREM.BusinessEntityID=HREDHM.BusinessEntityID
	JOIN [HumanResources].[Department] HRD ON HREDH.DepartmentID=HRD.DepartmentID
	JOIN [HumanResources].[Department] HRDM ON HREDHM.DepartmentID=HRDM.DepartmentID
	JOIN [Person].[Person] PP ON HRE.BusinessEntityID=PP.BusinessEntityID
WHERE 
	HREDH.DepartmentID=HREDHM.DepartmentID
	AND HRE.JobTitle LIKE '%manager' 
	AND HRE.JobTitle!=HREM.JobTitle
GROUP BY 
	HRE.BusinessEntityID,PP.FirstName
HAVING 
	COUNT(HREM.BusinessEntityID)>4
ORDER BY 
	COUNT(HREM.BusinessEntityID) DESC;

--Q28 List of orders and product names
SELECT 
	SSOH.SalesOrderID,
	PrP.Name
FROM 
	[Sales].[SalesOrderHeader] SSOH
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
	JOIN [Production].[Product] PrP ON SSOD.ProductID=PrP.ProductID;

--29 List of orders placed by best cutomer
SELECT 
	SSOH.SalesOrderID
FROM 
	[Sales].[SalesOrderHeader] SSOH
WHERE 
	SSOH.CustomerID=(SELECT SSOH.CustomerID 
					 FROM [Sales].[SalesOrderHeader] SSOH
					 WHERE SSOH.TotalDue=(SELECT MAX(SSOH.TotalDue) 
										  FROM [Sales].[SalesOrderHeader] SSOH));

--Q30 List  of orders placed by customers who dont have a fax number
SELECT 
	SSOH.SalesOrderID
FROM 
	[Sales].[Customer] SC
	JOIN [Sales].[SalesOrderHeader] SSOH ON SSOH.CustomerID=SC.CustomerID
	RIGHT JOIN [Person].[Person] PP ON PP.BusinessEntityID=SC.PersonID
	JOIN [Person].[PersonPhone] PPH ON PP.BusinessEntityID=PPH.BusinessEntityID
	JOIN [Person].[PhoneNumberType] PPNT ON PPH.PhoneNumberTypeID=PPNT.PhoneNumberTypeID
WHERE 
	PPNT.Name NOT LIKE 'Work';

--Q31 List Postal code where product tofu was shipped
SELECT 
	PA.PostalCode
FROM 
	[Person].[Address] PA 
	JOIN [Sales].[SalesOrderHeader] SSOH ON PA.AddressID=SSOH.ShipToAddressID
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
	JOIN [Production].[Product] PrP ON SSOD.ProductID=PrP.ProductID
WHERE 
	PrP.Name='Tofu';

--Q32. List Products which are shiped to France
SELECT 
	SSOD.ProductID
FROM 
	[Sales].[SalesOrderDetail] SSOD JOIN [Sales].[SalesOrderHeader] SSOH ON SSOD.SalesOrderID=SSOH.SalesOrderID
	JOIN [Sales].[Customer] SC ON SSOH.CustomerID=SC.CustomerID
	JOIN [Sales].[SalesTerritory] SST ON SC.TerritoryID=SST.TerritoryID
	JOIN [Person].[StateProvince] PSP ON SST.CountryRegionCode=PSP.CountryRegionCode
	JOIN [Person].[Address] PA ON PSP.StateProvinceID=PA.StateProvinceID
WHERE 
	PA.City='France';

--Q33 List of Product names and categories for the supplier 'Speciality Biscuits,Ltd.'
SELECT 
	PrP.Name,
	PrPC.Name
FROM 
	[Production].[Product] PrP
	JOIN [Production].[ProductSubcategory] PrPS ON PrP.ProductSubcategoryID=PrPS.ProductSubcategoryID
	JOIN [Production].[ProductCategory] PrPC ON PrPS.ProductCategoryID=PrPC.ProductCategoryID
	JOIN [Purchasing].[ProductVendor] PuPV ON PrP.ProductID=PuPV.ProductID
	JOIN [Purchasing].[Vendor] PuV ON PuPV.BusinessEntityID=PuV.BusinessEntityID
WHERE 
	PuV.Name LIKE 'Speciality Biscuits,Ltd.';

--Q34 List of products that were never ordered
--METHOD 1:
SELECT 
	PrP.ProductID
FROM 
	[Production].[Product] PrP
	LEFT JOIN [Sales].[SalesOrderDetail] SSOD ON PrP.ProductID=SSOD.ProductID--JOIN [Sales].[SalesOrderHeader] SSOH ON SSOH.SalesOrderID=SSOD.SalesOrderID
WHERE 
	SSOD.SalesOrderID IS NULL;

--METHOD 2:
SELECT 
	PrP.ProductID
FROM 
	[Production].[Product] PrP
	LEFT JOIN [Sales].[SalesOrderDetail] SSOD ON PrP.ProductID=SSOD.ProductID--JOIN [Sales].[SalesOrderHeader] SSOH ON SSOH.SalesOrderID=SSOD.SalesOrderID
GROUP BY 
	PrP.ProductID
HAVING 
	COUNT(SSOD.SalesOrderID)=0;

--Q35. List of product were units in stock is less than 10 and units on order are 0.
SELECT 
	PWO.ProductID
FROM 
	[Production].[WorkOrder] PWO
WHERE 
	PWO.OrderQty=0 
	AND PWO.StockedQty<10;

--Q36 List of top 10 countries by sales
SELECT TOP 10 
	PCR.Name,
		SUM(SSOH.TotalDue) Sales
FROM 
	[Sales].[SalesOrderHeader] SSOH
	JOIN [Sales].[CurrencyRate] SCR ON SSOH.CurrencyRateID=SCR.CurrencyRateID
	JOIN [Sales].[Currency] SCu ON SCR.ToCurrencyCode=SCu.CurrencyCode
	JOIN [Sales].[CountryRegionCurrency] SCRC ON SCu.CurrencyCode=SCRC.CurrencyCode
	JOIN [Person].[CountryRegion] PCR ON SCRC.CountryRegionCode=PCR.CountryRegionCode
GROUP BY 
	PCR.Name
ORDER BY 
	COUNT(SSOH.SalesOrderID) DESC;

--Q37 Number of orders each employee had taken for customers with CustomerIds between A and AO.
SELECT 
	SSOH.SalesPersonID ,
	COUNT(SSOH.SalesOrderID)
FROM 
	[Sales].[SalesOrderHeader] SSOH 
GROUP BY 
	SSOH.SalesPersonID ;

--Q38. Orderdate of most expensive order.
SELECT 
	SSOH.OrderDate 
FROM 
	[Sales].[SalesOrderHeader] SSOH 
WHERE 
	SSOH.TotalDue=(SELECT MAX(SSOH.TotalDue) 
				   FROM  [Sales].[SalesOrderHeader] SSOH );

--Q39. Product name and total revenue from that product
SELECT 
	PrP.Name,
	SUM(SSOD.OrderQty*SSOD.UnitPrice) TotalRevenue
FROM 
	[Production].[Product] PrP
	JOIN [Sales].[SalesOrderDetail] SSOD ON PrP.ProductID=SSOD.ProductID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SSOD.SalesOrderID=SSOH.SalesOrderID
GROUP BY 
	PrP.Name;

--Q40. Supplierid and no. of products offered
SELECT 
	SS.BusinessEntityID,
	COUNT(PrP.ProductID)
FROM 
	[Production].[Product] PrP
	JOIN [Sales].[SalesOrderDetail] SSOD ON PrP.ProductID=SSOD.ProductID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SSOD.SalesOrderID=SSOH.SalesOrderID
	JOIN [Sales].[Customer] SC ON SSOH.CustomerID=SC.CustomerID
	JOIN [Sales].[Store] SS ON SC.PersonID=SS.BusinessEntityID
GROUP BY 
	SS.BusinessEntityID;

--Q41. Top 10 customers based on their business.
SELECT TOP 10 
	PP.BusinessEntityID,
	SUM(SSOD.OrderQty*SSOD.UnitPrice) Sales
FROM 
	[Person].[Person] PP
	JOIN [Sales].[Customer] SC ON PP.BusinessEntityID=SC.PersonID
	JOIN [Sales].[SalesOrderHeader] SSOH ON SC.CustomerID=SSOH.CustomerID
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
GROUP BY
	PP.BusinessEntityID 
ORDER BY 
	SUM(SSOD.OrderQty*SSOD.UnitPrice) DESC;

--Q42. What is total revenue of the company.
SELECT 
	SS.Name,
	SUM(SSOD.OrderQty*SSOD.UnitPrice)
FROM 
	[Sales].[SalesOrderHeader] SSOH
	JOIN [Sales].[SalesOrderDetail] SSOD ON SSOH.SalesOrderID=SSOD.SalesOrderID
	JOIN [Sales].[Customer] SC ON SSOH.CustomerID=SC.CustomerID
	JOIN [Sales].[Store] SS ON SC.PersonID=SS.BusinessEntityID
GROUP BY 
	SS.Name;

