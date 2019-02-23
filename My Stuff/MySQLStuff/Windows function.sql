-- old version

SET STATISTICS IO ON; GO
--Query with a self join WITH InternetSalesGender AS
(
SELECT ISA.CustomerKey, C.Gender,
ISA.SalesOrderNumber + CAST(ISA.SalesOrderLineNumber AS CHAR(1)) AS OrderLineNumber,
ISA.SalesAmount
FROM dbo.FactInternetSales AS ISA INNER JOIN dbo.DimCustomer AS C
ON ISA.CustomerKey = C.CustomerKey WHERE ISA.CustomerKey <= 12000
)

SELECT ISG1.Gender, ISG1.OrderLineNumber, MIN(ISG1.SalesAmount), SUM(ISG2.SalesAmount) AS RunningTotal FROM InternetSalesGender AS ISG1
INNER JOIN InternetSalesGender AS ISG2 ON ISG1.Gender = ISG2.Gender
AND ISG1.OrderLineNumber >= ISG2.OrderLineNumber GROUP BY ISG1.Gender, ISG1.OrderLineNumber
ORDER BY ISG1.Gender, ISG1.OrderLineNumber;

-- new version

WITH InternetSalesGender AS
(
SELECT ISA.CustomerKey, C.Gender,
ISA.SalesOrderNumber + CAST(ISA.SalesOrderLineNumber AS CHAR(1)) AS OrderLineNumber,
ISA.SalesAmount
FROM dbo.FactInternetSales AS ISA INNER JOIN dbo.DimCustomer AS C
ON ISA.CustomerKey = C.CustomerKey WHERE ISA.CustomerKey <= 12000
)

SELECT ISG.Gender, ISG.OrderLineNumber, ISG.SalesAmount, SUM(ISG.SalesAmount)
OVER(PARTITION BY ISG.Gender ORDER BY ISG.OrderLineNumber
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW) AS RunningTotal FROM InternetSalesGender AS ISG
ORDER BY ISG.Gender, ISG.OrderLineNumber