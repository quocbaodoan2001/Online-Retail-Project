<<<<<<< HEAD
# Project Overview: Cohort Analysis

1. Introduction

Welcome to the overview of my cohort analysis project, where I leverage Python, SQL, and Power BI to gain insights into user behavior 
and business performance. This project focuses on understanding user cohorts, tracking their behaviors over time, and extracting 
actionable insights to drive strategic decisions.
Tools used: Python, SQL, Power BI

2. Tools Utilized

- Python:
+ Data type checking and assessment of total null values.
+ Initial data exploration and preprocessing.

- SQL:
+ Data querying and cleaning.
+ Extracting relevant information for cohort analysis.

- Power BI:
+ Data visualization and creation of interactive dashboards.
+ Communicating insights derived from cohort analysis.

3. Data have 8 columns (InvoiceNO, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country)

4. Expolre Data Analysis

4.1 Cleaned by extracting negative Unitprice and Quantity, Null CustomerID, and Description

4.2 After cleaning, data had:

- Total records: 541909 
- 135080 rows have no CustomerID
- 406829 have CustomerID
- Negative UnitPrice: 2 rows
- 1454 (rows) have no Description information and Null values of CustomerID
- 397884 rows have Quantity > 0 AND UnitPrice > 0
- 5195 rows duplicate
- 392669 rows have been cleaned.

5. Analyze Data

  It is presented in the Analyze folder as a PowerPoint file.
