CREATE SCHEMA DataWarehouse;

CREATE OR ALTER VIEW DataWarehouse.fct_sales
AS
SELECT Customer_ID, Product_ID, Ship_To_Address_ID as Address_ID, Ship_Method, Order_Qty, Order_Date, Total_Due as Total 
FROM dbo.salesorderdetail d
INNER JOIN dbo.salesorderheader h
ON d.Sales_Order_ID = h.Sales_Order_ID

CREATE OR ALTER VIEW DataWarehouse.dim_address
AS
SELECT Address_ID, Address_Line_1, City, Country_Region As Country, State_Province As State
FROM dbo.address

CREATE OR ALTER VIEW DataWarehouse.dim_customer
AS
SELECT (DISTINCT ca.Customer_ID), Email_Address, First_Name, Last_Name, Middle_Name, Phone, Title, Address_Line_1, City, Country_Region As Country, State_Province As State
FROM dbo.customer c
INNER JOIN dbo.customeraddress ca
ON c.Customer_ID = ca.Customer_ID
INNER JOIN dbo.address ad
ON ad.Address_ID = ca.Address_ID

CREATE OR ALTER VIEW DataWarehouse.dim_product
AS
SELECT pro.Product_ID, pro.Name as Product_Name, List_Price, cat.Name as Category, descr.Description
FROM dbo.product pro
INNER JOIN dbo.productcategory cat
ON pro.Product_Category_ID = cat.Product_Category_ID
INNER JOIN dbo.productmodelproductdescription model
ON model.Product_Model_ID = pro.Product_Model_ID
INNER JOIN dbo.productdescription descr
ON descr.Product_Description_ID = model.Product_Description_ID

-- CREATE OR REPLACE VIEW 