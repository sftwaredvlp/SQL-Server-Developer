/*
================================================================================
    SQL SERVER DEVELOPER MASTERY
    Module 01: SQL Fundamentals
    Lesson 04: SELECT Basics
================================================================================

    WHAT YOU'LL LEARN:
    ------------------
    1. Basic SELECT syntax
    2. Selecting specific columns vs SELECT *
    3. Column aliases
    4. Calculated columns
    5. DISTINCT for unique values
    6. TOP for limiting results
    7. String concatenation
    8. NULL handling in SELECT

    WHY THIS MATTERS:
    -----------------
    - SELECT is the most used SQL command
    - Every report, API, and dashboard uses SELECT
    - Efficient SELECT queries = fast applications
    - Column selection impacts network and memory

    PREREQUISITES:
    --------------
    - Completed 03_insert_data.sql
    - LearningDB (or Azure SQL Database) has populated tables

================================================================================
*/

/*
    🔹 LOCAL SQL SERVER: USE LearningDB;
    🔹 AZURE SQL: Already connected to your database - skip USE statement
*/


-- ============================================================================
-- SECTION 1: BASIC SELECT SYNTAX
-- ============================================================================

/*
    THE SELECT STATEMENT:
    
    SELECT column1, column2, ...
    FROM table_name;
    
    ORDER OF EXECUTION (important for understanding):
    1. FROM - Which table(s)
    2. WHERE - Filter rows (covered in Module 02)
    3. GROUP BY - Group rows (covered in Module 04)
    4. HAVING - Filter groups (covered in Module 04)
    5. SELECT - Choose columns
    6. ORDER BY - Sort results (covered in Module 02)
*/

-- Select all columns (development/debugging only!)
SELECT * FROM Employee;
GO

-- Select specific columns (production best practice)
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email
FROM Employee;
GO


-- ============================================================================
-- SECTION 2: WHY NOT TO USE SELECT *
-- ============================================================================

/*
    ❌ PROBLEMS WITH SELECT *:
    
    1. PERFORMANCE:
       - Transfers unnecessary data over network
       - Uses more memory on client and server
       - Can't use covering indexes effectively
    
    2. MAINTENANCE:
       - Code breaks if columns are added/removed/renamed
       - Unclear what data the query actually needs
       - Security risk: might expose sensitive columns
    
    3. READABILITY:
       - Hard to know what data is being used
       - Makes code review difficult
    
    ✅ WHEN SELECT * IS OKAY:
    - Quick ad-hoc queries during development
    - EXISTS subqueries: WHERE EXISTS (SELECT * FROM ...)
    - Temporary debugging
*/

-- ❌ BAD: Using SELECT * in production code
-- SELECT * FROM Employee;  

-- ✅ GOOD: Explicit column list
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email,
    HireDate,
    Salary,
    DepartmentID
FROM Employee;
GO


-- ============================================================================
-- SECTION 3: COLUMN ALIASES
-- ============================================================================

/*
    ALIASES: Give columns or tables temporary names.
    
    SYNTAX OPTIONS:
    - column AS AliasName
    - column AliasName
    - column AS 'Alias Name'  (with spaces)
    - column AS [Alias Name]  (SQL Server preferred for spaces)
    
    USE CASES:
    - Make column names more readable
    - Rename calculated columns
    - Required for some expressions
*/

-- Basic aliases
SELECT 
    EmployeeID AS ID,
    FirstName AS [First Name],     -- Brackets for spaces
    LastName AS 'Last Name',        -- Quotes also work
    Email AS EmailAddress,
    Salary AS AnnualSalary
FROM Employee;
GO

-- Aliases without AS keyword (works but less clear)
SELECT 
    EmployeeID ID,
    FirstName [First Name],
    LastName [Last Name]
FROM Employee;
GO

-- Aliases are especially important for expressions
SELECT 
    FirstName + ' ' + LastName AS FullName,  -- Without alias: (No column name)
    Salary * 12 AS AnnualCompensation,
    YEAR(HireDate) AS HireYear
FROM Employee;
GO


-- ============================================================================
-- SECTION 4: CALCULATED COLUMNS
-- ============================================================================

/*
    You can perform calculations in SELECT:
    - Arithmetic: +, -, *, /, %
    - String operations
    - Date calculations
    - CASE expressions
*/

-- Arithmetic calculations
SELECT 
    ProductName,
    UnitPrice,
    UnitPrice * 0.9 AS DiscountedPrice10Percent,
    UnitPrice * 1.0825 AS PriceWithTax,
    UnitPrice * 12 AS YearlySubscriptionPrice
FROM Product
WHERE Category = 'Electronics';
GO

-- Employee salary calculations
SELECT 
    FirstName + ' ' + LastName AS FullName,
    Salary AS AnnualSalary,
    Salary / 12 AS MonthlySalary,
    Salary / 52 AS WeeklySalary,
    Salary / 2080 AS HourlyRate,  -- 52 weeks * 40 hours
    Salary * 0.062 AS SocialSecurityTax,  -- 6.2%
    Salary * 0.0145 AS MedicareTax,       -- 1.45%
    Salary - (Salary * 0.062) - (Salary * 0.0145) AS NetAfterFICA
FROM Employee
WHERE Salary IS NOT NULL;
GO

-- Date calculations
SELECT 
    FirstName,
    LastName,
    HireDate,
    GETDATE() AS Today,
    DATEDIFF(DAY, HireDate, GETDATE()) AS DaysEmployed,
    DATEDIFF(MONTH, HireDate, GETDATE()) AS MonthsEmployed,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsEmployed,
    DATEADD(YEAR, 1, HireDate) AS FirstAnniversary
FROM Employee;
GO

-- CASE expressions (conditional logic)
SELECT 
    FirstName,
    LastName,
    Salary,
    CASE 
        WHEN Salary >= 90000 THEN 'Senior'
        WHEN Salary >= 70000 THEN 'Mid-Level'
        WHEN Salary >= 50000 THEN 'Junior'
        ELSE 'Entry Level'
    END AS SalaryBand,
    CASE 
        WHEN Salary >= 90000 THEN Salary * 0.15
        WHEN Salary >= 70000 THEN Salary * 0.10
        ELSE Salary * 0.05
    END AS BonusAmount
FROM Employee;
GO


-- ============================================================================
-- SECTION 5: DISTINCT - Unique Values
-- ============================================================================

/*
    DISTINCT:
    - Removes duplicate rows from results
    - Applied to entire row, not single column
    - Useful for finding unique values
    - Has performance cost (requires sorting)
*/

-- Find unique departments
SELECT DISTINCT DepartmentID
FROM Employee
WHERE DepartmentID IS NOT NULL
ORDER BY DepartmentID;
GO

-- Find unique categories
SELECT DISTINCT Category
FROM Product
ORDER BY Category;
GO

-- DISTINCT on multiple columns (unique combinations)
SELECT DISTINCT 
    Category,
    CASE 
        WHEN UnitPrice < 50 THEN 'Budget'
        WHEN UnitPrice < 200 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS PriceCategory
FROM Product
ORDER BY Category, PriceCategory;
GO

-- Count distinct values
SELECT 
    COUNT(*) AS TotalProducts,
    COUNT(DISTINCT Category) AS UniqueCategories
FROM Product;
GO


-- ============================================================================
-- SECTION 6: TOP - Limiting Results
-- ============================================================================

/*
    TOP:
    - Limits number of rows returned
    - Can specify count or percentage
    - Often used with ORDER BY
    - WITH TIES includes rows with same values
*/

-- Get first 5 employees
SELECT TOP 5
    EmployeeID,
    FirstName,
    LastName
FROM Employee;
GO

-- Get top 5 highest paid employees
SELECT TOP 5
    FirstName,
    LastName,
    Salary
FROM Employee
WHERE Salary IS NOT NULL
ORDER BY Salary DESC;
GO

-- Get top 10 percent of products by price
SELECT TOP 10 PERCENT
    ProductName,
    UnitPrice
FROM Product
ORDER BY UnitPrice DESC;
GO

-- WITH TIES: Include all rows with same value as last row
SELECT TOP 3 WITH TIES
    FirstName,
    LastName,
    Salary
FROM Employee
WHERE Salary IS NOT NULL
ORDER BY Salary DESC;
-- If 3rd and 4th employees have same salary, both are included
GO

-- Using TOP with variable (useful in stored procedures)
DECLARE @TopCount INT = 3;

SELECT TOP (@TopCount)
    ProductName,
    UnitPrice
FROM Product
ORDER BY UnitPrice DESC;
GO


-- ============================================================================
-- SECTION 7: STRING OPERATIONS
-- ============================================================================

/*
    COMMON STRING FUNCTIONS:
    - Concatenation: +, CONCAT()
    - UPPER(), LOWER()
    - LEN(), DATALENGTH()
    - LEFT(), RIGHT(), SUBSTRING()
    - TRIM(), LTRIM(), RTRIM()
    - REPLACE(), STUFF()
    - CHARINDEX(), PATINDEX()
    - FORMAT()
*/

-- String concatenation
SELECT 
    -- Method 1: + operator (NULL results in NULL)
    FirstName + ' ' + LastName AS FullName1,
    
    -- Method 2: CONCAT (handles NULL gracefully)
    CONCAT(FirstName, ' ', LastName) AS FullName2,
    
    -- Method 3: CONCAT_WS (with separator) - SQL Server 2017+
    CONCAT_WS(' ', FirstName, LastName) AS FullName3,
    
    -- Building formatted strings
    CONCAT(LastName, ', ', FirstName) AS LastFirst,
    CONCAT(FirstName, ' ', LastName, ' (', Email, ')') AS NameWithEmail
FROM Employee;
GO

-- String functions
SELECT 
    FirstName,
    UPPER(FirstName) AS UpperName,
    LOWER(FirstName) AS LowerName,
    LEN(FirstName) AS NameLength,
    LEFT(FirstName, 3) AS First3Chars,
    RIGHT(Email, 15) AS EmailEnd,
    SUBSTRING(Email, 1, CHARINDEX('@', Email) - 1) AS EmailUsername,
    REPLACE(Email, '@company.com', '@newcompany.com') AS UpdatedEmail
FROM Employee;
GO

-- FORMAT function for numbers and dates
SELECT 
    FirstName,
    Salary,
    FORMAT(Salary, 'C', 'en-US') AS SalaryFormatted,  -- Currency
    FORMAT(Salary, 'N2') AS SalaryWithCommas,         -- Number
    HireDate,
    FORMAT(HireDate, 'MMMM dd, yyyy') AS HireDateFormatted,
    FORMAT(HireDate, 'MM/dd/yyyy') AS HireDateShort
FROM Employee
WHERE Salary IS NOT NULL;
GO


-- ============================================================================
-- SECTION 8: NULL HANDLING
-- ============================================================================

/*
    NULL REPRESENTS:
    - Unknown value
    - Missing data
    - Not applicable
    
    NULL RULES:
    - NULL is not equal to anything (including NULL)
    - Any operation with NULL results in NULL
    - Use IS NULL / IS NOT NULL for comparisons
    
    NULL HANDLING FUNCTIONS:
    - ISNULL(value, replacement)
    - COALESCE(value1, value2, ...)
    - NULLIF(value1, value2)
*/

-- Basic NULL checks
SELECT 
    FirstName,
    LastName,
    Salary,
    CASE 
        WHEN Salary IS NULL THEN 'Not Set'
        ELSE CAST(Salary AS VARCHAR(20))
    END AS SalaryStatus
FROM Employee;
GO

-- ISNULL: Replace NULL with default value
SELECT 
    FirstName,
    LastName,
    Salary,
    ISNULL(Salary, 0) AS SalaryOrZero,
    ISNULL(CAST(Salary AS VARCHAR(20)), 'Not Specified') AS SalaryDisplay
FROM Employee;
GO

-- COALESCE: Return first non-NULL value (more flexible)
SELECT 
    FirstName,
    Salary,
    -- Returns first non-null: Salary, 50000, or 0
    COALESCE(Salary, 50000, 0) AS EffectiveSalary
FROM Employee;
GO

-- NULLIF: Returns NULL if two values are equal
-- Useful for avoiding division by zero
SELECT 
    ProductName,
    UnitPrice,
    DiscountPercent,
    -- Without NULLIF, division by zero if DiscountPercent = 100
    -- NULLIF returns NULL if DiscountPercent = 100
    UnitPrice / NULLIF(1 - DiscountPercent/100, 0) AS OriginalPrice
FROM Product
WHERE DiscountPercent > 0;
GO

-- String concatenation with NULL
SELECT 
    FirstName,
    LastName,
    -- + returns NULL if any part is NULL
    FirstName + ' ' + NULL + ' ' + LastName AS WithNull1,
    
    -- CONCAT ignores NULLs
    CONCAT(FirstName, ' ', NULL, ' ', LastName) AS WithNull2
FROM Employee;
GO


-- ============================================================================
-- SECTION 9: TABLE ALIASES
-- ============================================================================

/*
    TABLE ALIASES:
    - Shorten table references
    - Required for self-joins
    - Make queries more readable
*/

-- Without alias (verbose)
SELECT 
    Employee.FirstName,
    Employee.LastName,
    Employee.Email
FROM Employee;

-- With alias (cleaner)
SELECT 
    e.FirstName,
    e.LastName,
    e.Email
FROM Employee e;  -- 'e' is the alias

-- With AS keyword (more explicit)
SELECT 
    emp.FirstName,
    emp.LastName,
    emp.Email
FROM Employee AS emp;
GO


-- ============================================================================
-- SECTION 10: COMBINING TECHNIQUES
-- ============================================================================

/*
    Real-world queries combine multiple techniques.
    Let's build some practical examples.
*/

-- Employee report with calculations, formatting, and NULL handling
SELECT TOP 10
    e.EmployeeID AS [ID],
    CONCAT(e.FirstName, ' ', e.LastName) AS [Full Name],
    e.Email AS [Email Address],
    d.DepartmentName AS [Department],
    FORMAT(e.HireDate, 'MMM dd, yyyy') AS [Hire Date],
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS [Years of Service],
    ISNULL(FORMAT(e.Salary, 'C', 'en-US'), 'TBD') AS [Annual Salary],
    CASE e.IsActive
        WHEN 1 THEN 'Active'
        WHEN 0 THEN 'Inactive'
        ELSE 'Unknown'
    END AS [Status],
    CASE 
        WHEN ISNULL(e.Salary, 0) >= 90000 THEN 'Senior'
        WHEN ISNULL(e.Salary, 0) >= 70000 THEN 'Mid-Level'
        WHEN ISNULL(e.Salary, 0) >= 50000 THEN 'Junior'
        ELSE 'Entry Level'
    END AS [Level]
FROM Employee e
LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
ORDER BY e.Salary DESC;
GO

-- Product catalog with pricing tiers
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    FORMAT(p.UnitPrice, 'C') AS [List Price],
    FORMAT(p.DiscountedPrice, 'C') AS [Sale Price],
    FORMAT(p.FinalPrice, 'C') AS [Price with Tax],
    CONCAT(FORMAT(p.DiscountPercent, 'N0'), '%') AS [Discount],
    CASE 
        WHEN p.UnitPrice >= 500 THEN '⭐⭐⭐ Premium'
        WHEN p.UnitPrice >= 100 THEN '⭐⭐ Standard'
        ELSE '⭐ Budget'
    END AS [Tier],
    CASE p.IsActive
        WHEN 1 THEN '✓ Available'
        ELSE '✗ Discontinued'
    END AS [Availability]
FROM Product p
WHERE p.IsDeleted = 0
ORDER BY p.Category, p.UnitPrice DESC;
GO

-- Order summary
SELECT 
    o.OrderNumber AS [Order #],
    CONCAT(c.FirstName, ' ', c.LastName) AS [Customer],
    os.StatusName AS [Status],
    FORMAT(o.OrderDate, 'MM/dd/yyyy') AS [Order Date],
    ISNULL(FORMAT(o.ShippedDate, 'MM/dd/yyyy'), 'Not Shipped') AS [Ship Date],
    FORMAT(o.SubTotal, 'C') AS [Subtotal],
    FORMAT(o.TotalAmount, 'C') AS [Total],
    COALESCE(
        o.ShippingAddress + ', ' + o.ShippingCity + ', ' + o.ShippingState,
        'No Address'
    ) AS [Ship To]
FROM [Order] o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN OrderStatus os ON o.StatusID = os.StatusID
WHERE o.IsDeleted = 0
ORDER BY o.OrderDate DESC;
GO


-- ============================================================================
-- SECTION 11: COMMON MISTAKES AND HOW TO AVOID THEM
-- ============================================================================

/*
    ❌ MISTAKE 1: Using SELECT * in production
    
    -- Bad:
    SELECT * FROM Employee;
    
    -- Good:
    SELECT EmployeeID, FirstName, LastName FROM Employee;
*/

/*
    ❌ MISTAKE 2: Not handling NULL in concatenation
    
    -- Bad: Returns NULL if any part is NULL
    SELECT FirstName + ' ' + MiddleName + ' ' + LastName FROM Person;
    
    -- Good: CONCAT handles NULL
    SELECT CONCAT(FirstName, ' ', MiddleName, ' ', LastName) FROM Person;
    
    -- Or with ISNULL:
    SELECT FirstName + ISNULL(' ' + MiddleName, '') + ' ' + LastName FROM Person;
*/

/*
    ❌ MISTAKE 3: Division without NULL check
    
    -- Bad: Division by zero error
    SELECT Total / Quantity FROM OrderItem;
    
    -- Good: Use NULLIF
    SELECT Total / NULLIF(Quantity, 0) FROM OrderItem;
*/

/*
    ❌ MISTAKE 4: Comparing with NULL using =
    
    -- Bad: Never returns rows (NULL = NULL is not true)
    SELECT * FROM Employee WHERE ManagerID = NULL;
    
    -- Good: Use IS NULL
    SELECT * FROM Employee WHERE ManagerID IS NULL;
*/

/*
    ❌ MISTAKE 5: Using aliases in wrong places
    
    -- Bad: Can't use alias in WHERE of same query level
    SELECT Salary * 12 AS AnnualPay
    FROM Employee
    WHERE AnnualPay > 100000;  -- Error!
    
    -- Good: Repeat the expression or use subquery
    SELECT Salary * 12 AS AnnualPay
    FROM Employee
    WHERE Salary * 12 > 100000;
    
    -- Or use CTE (covered in Module 05)
*/


-- ============================================================================
-- SUMMARY
-- ============================================================================

/*
    KEY TAKEAWAYS:
    
    1. SELECT BASICS:
       - Always specify columns explicitly
       - Use aliases for readability
       - Table aliases shorten queries
    
    2. CALCULATIONS:
       - Arithmetic: +, -, *, /, %
       - CASE for conditional logic
       - Date functions: DATEDIFF, DATEADD
       - FORMAT for display formatting
    
    3. DISTINCT AND TOP:
       - DISTINCT removes duplicate rows
       - TOP limits result count
       - TOP PERCENT for percentage
       - WITH TIES includes matching values
    
    4. NULL HANDLING:
       - NULL is unknown, not zero or empty
       - Use IS NULL / IS NOT NULL
       - ISNULL(value, default)
       - COALESCE(v1, v2, v3...)
       - NULLIF to avoid division by zero
    
    5. STRING OPERATIONS:
       - CONCAT handles NULL gracefully
       - LEFT, RIGHT, SUBSTRING for extraction
       - UPPER, LOWER for case
       - FORMAT for display
    
    NEXT MODULE: 02_filtering_sorting - WHERE clause and ORDER BY
*/
