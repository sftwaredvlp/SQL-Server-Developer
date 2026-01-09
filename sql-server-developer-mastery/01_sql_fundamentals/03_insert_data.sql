/*
================================================================================
    SQL SERVER DEVELOPER MASTERY
    Module 01: SQL Fundamentals
    Lesson 03: Inserting Data
================================================================================

    WHAT YOU'LL LEARN:
    ------------------
    1. Single row INSERT statements
    2. Multi-row INSERT statements
    3. INSERT with SELECT (copying data)
    4. INSERT with DEFAULT values
    5. Handling IDENTITY columns
    6. INSERT with OUTPUT clause
    7. Bulk insert best practices

    WHY THIS MATTERS:
    -----------------
    - Data migration projects require INSERT expertise
    - Application backends constantly insert data
    - Understanding INSERT performance affects app speed
    - OUTPUT clause is critical for getting generated IDs

    PREREQUISITES:
    --------------
    - Completed 02_create_tables.sql
    - LearningDB database exists with tables (or Azure SQL Database)

================================================================================
*/

/*
    🔹 LOCAL SQL SERVER: USE LearningDB;
    🔹 AZURE SQL: Already connected to your database - skip USE statement
*/

-- Verify we have our tables
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO


-- ============================================================================
-- SECTION 1: BASIC SINGLE ROW INSERT
-- ============================================================================

/*
    THE INSERT STATEMENT SYNTAX:
    
    INSERT INTO TableName (Column1, Column2, Column3)
    VALUES (Value1, Value2, Value3);
    
    RULES:
    - Column list is optional but ALWAYS recommended
    - Values must match column order and data types
    - String values use single quotes: 'text'
    - Numbers don't need quotes: 123, 45.67
    - Dates can be strings: '2024-01-15'
    - NULL is a keyword, not a string: NULL not 'NULL'
*/

-- Insert a single department
INSERT INTO Department (DepartmentName)
VALUES ('Information Technology');

-- CreatedDate is set automatically by DEFAULT
SELECT * FROM Department;
GO

-- Insert with all non-identity columns specified
INSERT INTO Department (DepartmentName, CreatedDate)
VALUES ('Human Resources', '2024-01-01 09:00:00');

SELECT * FROM Department;
GO


-- ============================================================================
-- SECTION 2: MULTI-ROW INSERT
-- ============================================================================

/*
    SQL Server allows inserting multiple rows in one statement.
    
    BENEFITS:
    - Faster than multiple single INSERT statements
    - Fewer round trips to database
    - Atomic: all rows succeed or all fail
    
    LIMIT: 
    - SQL Server allows up to 1000 rows per INSERT statement
    - For more rows, use multiple INSERTs or BULK INSERT
*/

-- Insert multiple departments at once
INSERT INTO Department (DepartmentName)
VALUES 
    ('Finance'),
    ('Marketing'),
    ('Sales'),
    ('Operations'),
    ('Customer Support'),
    ('Research & Development'),
    ('Legal'),
    ('Procurement');

SELECT * FROM Department;
GO

-- Insert multiple employees
INSERT INTO Employee (FirstName, LastName, Email, HireDate, Salary, DepartmentID)
VALUES 
    -- IT Department (ID: 1)
    ('John', 'Smith', 'john.smith@company.com', '2020-03-15', 85000.00, 1),
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', '2019-07-01', 95000.00, 1),
    ('Michael', 'Williams', 'michael.williams@company.com', '2021-01-10', 75000.00, 1),
    
    -- HR Department (ID: 2)
    ('Emily', 'Brown', 'emily.brown@company.com', '2018-05-20', 72000.00, 2),
    ('David', 'Jones', 'david.jones@company.com', '2022-02-14', 65000.00, 2),
    
    -- Finance Department (ID: 3)
    ('Jessica', 'Davis', 'jessica.davis@company.com', '2017-11-08', 88000.00, 3),
    ('Christopher', 'Miller', 'chris.miller@company.com', '2020-09-22', 92000.00, 3),
    ('Amanda', 'Wilson', 'amanda.wilson@company.com', '2021-04-05', 70000.00, 3),
    
    -- Marketing Department (ID: 4)
    ('Matthew', 'Moore', 'matt.moore@company.com', '2019-08-12', 68000.00, 4),
    ('Ashley', 'Taylor', 'ashley.taylor@company.com', '2022-06-30', 62000.00, 4),
    
    -- Sales Department (ID: 5)
    ('Daniel', 'Anderson', 'daniel.anderson@company.com', '2018-02-28', 55000.00, 5),
    ('Brittany', 'Thomas', 'brittany.thomas@company.com', '2020-11-15', 58000.00, 5),
    ('Joshua', 'Jackson', 'joshua.jackson@company.com', '2021-07-19', 52000.00, 5),
    ('Stephanie', 'White', 'stephanie.white@company.com', '2019-10-03', 61000.00, 5),
    
    -- Operations Department (ID: 6)
    ('Andrew', 'Harris', 'andrew.harris@company.com', '2016-04-11', 78000.00, 6),
    ('Nicole', 'Martin', 'nicole.martin@company.com', '2020-01-25', 73000.00, 6);

SELECT * FROM Employee;
GO

PRINT 'Multi-row inserts completed!';
GO


-- ============================================================================
-- SECTION 3: INSERT WITH DEFAULT VALUES
-- ============================================================================

/*
    DEFAULT VALUES:
    - Use DEFAULT keyword to explicitly use default
    - Or simply omit the column from INSERT
    - DEFAULT VALUES inserts a row with all defaults (rarely used)
*/

-- Method 1: Omit columns with defaults
INSERT INTO Product (ProductName, UnitPrice)
VALUES ('Basic Widget', 9.99);

-- Method 2: Explicitly use DEFAULT keyword
INSERT INTO Product (ProductName, Description, Category, UnitPrice, DiscountPercent)
VALUES ('Premium Widget', 'High quality widget', DEFAULT, 19.99, DEFAULT);

-- Method 3: DEFAULT VALUES (creates row with all default values)
-- Only works if all non-null columns have defaults - usually fails
-- INSERT INTO Product DEFAULT VALUES;  -- This would fail

-- Verify the inserts
SELECT 
    ProductID,
    ProductName,
    Category,
    UnitPrice,
    DiscountPercent,
    DiscountedPrice,
    FinalPrice,
    CreatedBy
FROM Product;
GO

-- Insert more products for later use
INSERT INTO Product (ProductName, Description, Category, UnitPrice, DiscountPercent, TaxRate)
VALUES 
    ('Laptop Pro 15', 'Professional laptop with 15-inch display', 'Electronics', 1299.99, 10, 0.0825),
    ('Wireless Mouse', 'Ergonomic wireless mouse', 'Electronics', 49.99, 0, 0.0825),
    ('USB-C Hub', '7-port USB-C hub with HDMI', 'Electronics', 79.99, 15, 0.0825),
    ('Office Chair', 'Ergonomic office chair with lumbar support', 'Furniture', 349.99, 20, 0.0825),
    ('Standing Desk', 'Adjustable height standing desk', 'Furniture', 599.99, 5, 0.0825),
    ('Notebook Set', 'Pack of 5 premium notebooks', 'Office Supplies', 24.99, 0, 0.0825),
    ('Pen Collection', 'Assorted professional pens', 'Office Supplies', 15.99, 10, 0.0825),
    ('Monitor 27"', '4K IPS monitor', 'Electronics', 449.99, 12, 0.0825),
    ('Keyboard Mechanical', 'RGB mechanical keyboard', 'Electronics', 129.99, 0, 0.0825),
    ('Webcam HD', '1080p HD webcam with microphone', 'Electronics', 89.99, 5, 0.0825);

SELECT * FROM Product;
GO


-- ============================================================================
-- SECTION 4: INSERT WITH SELECT (Copying Data)
-- ============================================================================

/*
    INSERT INTO ... SELECT:
    - Copies data from one table to another
    - Can transform data during copy
    - Useful for data migration and archiving
    
    SYNTAX:
    INSERT INTO TargetTable (Column1, Column2)
    SELECT Column1, Column2
    FROM SourceTable
    WHERE condition;
*/

-- Create an archive table for products
CREATE TABLE ProductArchive (
    ArchiveID INT IDENTITY(1,1) PRIMARY KEY,
    OriginalProductID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    ArchivedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ArchivedBy NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER
);
GO

-- Copy electronics products to archive
INSERT INTO ProductArchive (OriginalProductID, ProductName, Category, UnitPrice)
SELECT 
    ProductID,
    ProductName,
    Category,
    UnitPrice
FROM Product
WHERE Category = 'Electronics';

SELECT * FROM ProductArchive;
GO

-- Copy with transformation
CREATE TABLE ProductSummary (
    SummaryID INT IDENTITY(1,1) PRIMARY KEY,
    ProductInfo NVARCHAR(500) NOT NULL,
    PriceCategory NVARCHAR(20) NOT NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- Transform data during copy
INSERT INTO ProductSummary (ProductInfo, PriceCategory)
SELECT 
    -- Concatenate product info
    ProductName + ' (' + Category + ') - $' + CAST(UnitPrice AS VARCHAR(20)),
    -- Categorize by price
    CASE 
        WHEN UnitPrice < 50 THEN 'Budget'
        WHEN UnitPrice < 200 THEN 'Mid-Range'
        WHEN UnitPrice < 500 THEN 'Premium'
        ELSE 'Luxury'
    END
FROM Product
WHERE IsActive = 1;

SELECT * FROM ProductSummary;
GO


-- ============================================================================
-- SECTION 5: INSERT WITH OUTPUT CLAUSE
-- ============================================================================

/*
    OUTPUT CLAUSE:
    - Returns information about inserted rows
    - Critical for getting auto-generated IDs
    - Can output to table variable or temp table
    
    INSERTED and DELETED:
    - INSERTED: New values (after INSERT or UPDATE)
    - DELETED: Old values (before UPDATE or DELETE)
    - For INSERT, only INSERTED is available
*/

-- Simple OUTPUT: Get the inserted ID
DECLARE @InsertedID TABLE (ID INT);

INSERT INTO Department (DepartmentName)
OUTPUT INSERTED.DepartmentID INTO @InsertedID
VALUES ('New Projects');

-- Show the generated ID
SELECT ID AS NewDepartmentID FROM @InsertedID;
GO

-- OUTPUT multiple columns
DECLARE @NewEmployees TABLE (
    EmployeeID INT,
    FullName NVARCHAR(100),
    Email NVARCHAR(255)
);

INSERT INTO Employee (FirstName, LastName, Email, HireDate, DepartmentID)
OUTPUT 
    INSERTED.EmployeeID,
    INSERTED.FirstName + ' ' + INSERTED.LastName,
    INSERTED.Email
INTO @NewEmployees
VALUES 
    ('James', 'Clark', 'james.clark@company.com', GETDATE(), 1),
    ('Linda', 'Lewis', 'linda.lewis@company.com', GETDATE(), 2);

-- Show all new employee details
SELECT * FROM @NewEmployees;
GO

-- OUTPUT directly to result set (without INTO)
INSERT INTO Department (DepartmentName)
OUTPUT 
    INSERTED.DepartmentID AS ID,
    INSERTED.DepartmentName AS Name,
    INSERTED.CreatedDate AS Created
VALUES ('Quality Assurance');
GO


-- ============================================================================
-- SECTION 6: HANDLING IDENTITY COLUMNS
-- ============================================================================

/*
    IDENTITY_INSERT:
    - Allows manual insert into identity column
    - Use for data migration or fixing gaps
    - Must be OFF for normal operations
    - Only one table can have it ON at a time per session
    
    SCOPE_IDENTITY():
    - Returns last identity value in current scope
    - Safer than @@IDENTITY (which crosses scopes)
    
    IDENT_CURRENT('table'):
    - Returns last identity for specific table
    - Crosses sessions (be careful!)
*/

-- Normal insert: Identity is auto-generated
INSERT INTO Department (DepartmentName)
VALUES ('Training');

SELECT SCOPE_IDENTITY() AS LastID;  -- Shows the generated ID
GO

-- Manual identity insert (for data migration)
SET IDENTITY_INSERT Department ON;  -- Enable manual insert

-- Now we can specify the ID
INSERT INTO Department (DepartmentID, DepartmentName)
VALUES (100, 'Special Projects');  -- Manual ID = 100

SET IDENTITY_INSERT Department OFF;  -- ALWAYS turn it off!

-- Verify
SELECT * FROM Department WHERE DepartmentID = 100;
GO

-- Best practice: Using OUTPUT instead of SCOPE_IDENTITY
-- More reliable in complex scenarios
DECLARE @NewID INT;
DECLARE @OutputTable TABLE (ID INT);

INSERT INTO Department (DepartmentName)
OUTPUT INSERTED.DepartmentID INTO @OutputTable
VALUES ('Innovation Lab');

SELECT @NewID = ID FROM @OutputTable;

PRINT 'New Department ID: ' + CAST(@NewID AS VARCHAR(10));
GO


-- ============================================================================
-- SECTION 7: INSERT WITH TRANSACTIONS
-- ============================================================================

/*
    TRANSACTIONS:
    - Group multiple INSERTs as atomic operation
    - All succeed or all fail (rollback)
    - Critical for data integrity
*/

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Insert a project
    DECLARE @ProjectOutput TABLE (ProjectID INT);
    
    INSERT INTO Project (ProjectName, Budget, StartDate, Status)
    OUTPUT INSERTED.ProjectID INTO @ProjectOutput
    VALUES ('Website Redesign', 150000.00, '2024-02-01', 'Active');
    
    DECLARE @ProjectID INT = (SELECT ProjectID FROM @ProjectOutput);
    
    -- Insert tasks for the project
    INSERT INTO Task (TaskName, ProjectID, DueDate, Priority, Status)
    VALUES 
        ('Design Mockups', @ProjectID, '2024-02-15', 1, 'In Progress'),
        ('Frontend Development', @ProjectID, '2024-03-01', 2, 'Not Started'),
        ('Backend API', @ProjectID, '2024-03-15', 2, 'Not Started'),
        ('Testing', @ProjectID, '2024-03-25', 2, 'Not Started'),
        ('Deployment', @ProjectID, '2024-04-01', 3, 'Not Started');
    
    COMMIT TRANSACTION;
    PRINT 'Project and tasks created successfully!';
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
GO

-- Verify the inserts
SELECT * FROM Project;
SELECT * FROM Task;
GO


-- ============================================================================
-- SECTION 8: INSERT WITH SELECT INTO (Creating New Table)
-- ============================================================================

/*
    SELECT INTO:
    - Creates a NEW table from query results
    - Copies structure and data
    - Does NOT copy constraints or indexes
    
    USE CASES:
    - Quick backup before modifications
    - Creating temp tables for analysis
    - Data snapshots
*/

-- Create a new table from query
SELECT 
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Email,
    Salary,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsEmployed
INTO EmployeeReport  -- Creates new table!
FROM Employee
WHERE Salary > 60000;

SELECT * FROM EmployeeReport;
GO

-- Create empty table with same structure (WHERE 1=0 returns no rows)
SELECT * 
INTO EmployeeBackup
FROM Employee
WHERE 1 = 0;  -- No data copied, just structure

-- View structure
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EmployeeBackup';
GO


-- ============================================================================
-- SECTION 9: BULK INSERT TECHNIQUES
-- ============================================================================

/*
    FOR LARGE DATA SETS:
    
    1. Multi-row VALUES (up to 1000 rows)
    2. INSERT ... SELECT (millions of rows)
    3. BULK INSERT (from files - fastest)
    4. bcp utility (command line)
    5. SSIS packages (enterprise ETL)
    
    PERFORMANCE TIPS:
    - Disable indexes before bulk insert, rebuild after
    - Use minimal logging (BULK_LOGGED recovery model)
    - Batch large inserts (10000 rows at a time)
    - Consider TABLOCK hint
*/

-- Batch insert example with iteration
-- This simulates inserting many records in batches

CREATE TABLE LogEntry (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    LogLevel VARCHAR(20) NOT NULL,
    Message NVARCHAR(500) NOT NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- Insert in batches
DECLARE @BatchSize INT = 100;
DECLARE @TotalRows INT = 500;
DECLARE @CurrentBatch INT = 1;
DECLARE @RowsInserted INT = 0;

WHILE @RowsInserted < @TotalRows
BEGIN
    -- Insert a batch
    INSERT INTO LogEntry (LogLevel, Message)
    SELECT TOP (@BatchSize)
        CASE (ABS(CHECKSUM(NEWID())) % 4)
            WHEN 0 THEN 'INFO'
            WHEN 1 THEN 'WARNING'
            WHEN 2 THEN 'ERROR'
            ELSE 'DEBUG'
        END,
        'Log message number ' + CAST(@RowsInserted + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))
    FROM sys.all_columns;  -- Just using as a row source
    
    SET @RowsInserted = @RowsInserted + @BatchSize;
    SET @CurrentBatch = @CurrentBatch + 1;
    
    -- Optional: Add delay between batches for large operations
    -- WAITFOR DELAY '00:00:00.1';
END

SELECT COUNT(*) AS TotalLogEntries FROM LogEntry;
SELECT TOP 10 * FROM LogEntry ORDER BY LogID DESC;
GO


-- ============================================================================
-- SECTION 10: INSERTING DATA FOR RELATIONSHIPS
-- ============================================================================

/*
    When inserting related data:
    1. Insert parent records first
    2. Get the generated IDs
    3. Insert child records with FK values
*/

-- Insert customers for our Order table
INSERT INTO Customer (FirstName, LastName, Email, Age, Status, CreditLimit)
VALUES 
    ('Robert', 'Johnson', 'robert.j@email.com', 35, 'Active', 5000.00),
    ('Maria', 'Garcia', 'maria.g@email.com', 28, 'Active', 7500.00),
    ('William', 'Brown', 'william.b@email.com', 45, 'Active', 10000.00),
    ('Jennifer', 'Martinez', 'jennifer.m@email.com', 32, 'Active', 3000.00),
    ('Charles', 'Davis', 'charles.d@email.com', 52, 'Active', 15000.00);

-- Insert orders with proper foreign keys
INSERT INTO [Order] (
    CustomerID, StatusID, OrderDate, RequiredDate,
    SubTotal, TaxAmount, ShippingAmount, DiscountAmount,
    ShippingAddress, ShippingCity, ShippingState, ShippingPostalCode
)
VALUES 
    (1, 1, GETDATE(), DATEADD(DAY, 7, GETDATE()),
     299.99, 24.75, 9.99, 0,
     '123 Main St', 'New York', 'NY', '10001'),
    
    (2, 2, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, 5, GETDATE()),
     549.50, 45.34, 0, 25.00,
     '456 Oak Ave', 'Los Angeles', 'CA', '90001'),
    
    (3, 3, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -1, GETDATE()),
     1299.99, 107.25, 15.00, 100.00,
     '789 Pine Rd', 'Chicago', 'IL', '60601'),
    
    (1, 4, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -5, GETDATE()),
     89.99, 7.42, 5.99, 0,
     '123 Main St', 'New York', 'NY', '10001');

-- View orders with computed total
SELECT 
    OrderID,
    OrderNumber,
    CustomerID,
    StatusID,
    SubTotal,
    TaxAmount,
    ShippingAmount,
    DiscountAmount,
    TotalAmount  -- Computed column
FROM [Order];
GO


-- ============================================================================
-- SECTION 11: COMMON MISTAKES AND HOW TO AVOID THEM
-- ============================================================================

/*
    ❌ MISTAKE 1: Not specifying column list
    
    -- Bad: Relies on column order (fragile)
    INSERT INTO Employee VALUES ('John', 'Doe', 'john@email.com', ...);
    
    -- Good: Explicit columns (safe)
    INSERT INTO Employee (FirstName, LastName, Email) 
    VALUES ('John', 'Doe', 'john@email.com');
*/

/*
    ❌ MISTAKE 2: Using @@IDENTITY instead of SCOPE_IDENTITY()
    
    -- Bad: Can return wrong ID if trigger exists
    INSERT INTO Table1 (Name) VALUES ('Test');
    SELECT @@IDENTITY;  -- Might return ID from trigger's insert!
    
    -- Good: Returns ID from current scope only
    INSERT INTO Table1 (Name) VALUES ('Test');
    SELECT SCOPE_IDENTITY();  -- Correct ID
    
    -- Best: Use OUTPUT clause
    INSERT INTO Table1 (Name)
    OUTPUT INSERTED.ID
    VALUES ('Test');
*/

/*
    ❌ MISTAKE 3: Forgetting to turn off IDENTITY_INSERT
    
    -- Always use try/finally pattern
    SET IDENTITY_INSERT MyTable ON;
    BEGIN TRY
        INSERT INTO MyTable (ID, Name) VALUES (100, 'Test');
    END TRY
    BEGIN CATCH
        -- Handle error
    END CATCH
    SET IDENTITY_INSERT MyTable OFF;  -- ALWAYS!
*/

/*
    ❌ MISTAKE 4: Not using transactions for related inserts
    
    -- Bad: Partial data if second insert fails
    INSERT INTO Order (CustomerID) VALUES (1);
    INSERT INTO OrderItem (OrderID, ProductID) VALUES (???, 1);  -- What if this fails?
    
    -- Good: Atomic operation
    BEGIN TRANSACTION;
    INSERT INTO Order...;
    INSERT INTO OrderItem...;
    COMMIT;
*/

/*
    ❌ MISTAKE 5: String vs Date confusion
    
    -- Bad: Ambiguous date format
    INSERT INTO Table (DateCol) VALUES ('01/02/2024');  -- Jan 2 or Feb 1?
    
    -- Good: ISO format (unambiguous)
    INSERT INTO Table (DateCol) VALUES ('2024-01-02');  -- Always Jan 2
*/


-- ============================================================================
-- SUMMARY
-- ============================================================================

/*
    KEY TAKEAWAYS:
    
    1. INSERT SYNTAX:
       - Always specify column names explicitly
       - Multi-row VALUES for up to 1000 rows
       - INSERT...SELECT for copying data
    
    2. GETTING GENERATED IDs:
       - Use OUTPUT clause (most reliable)
       - Or SCOPE_IDENTITY() (simpler cases)
       - Avoid @@IDENTITY
    
    3. IDENTITY COLUMNS:
       - Use IDENTITY_INSERT for manual IDs
       - Always turn it OFF when done
    
    4. BEST PRACTICES:
       - Use transactions for related inserts
       - Use ISO date format: 'YYYY-MM-DD'
       - Batch large inserts for performance
       - Use OUTPUT to capture inserted values
    
    NEXT LESSON: 04_select_basics.sql - Querying data from tables
*/
