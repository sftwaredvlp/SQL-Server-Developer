/*
================================================================================
    SQL SERVER DEVELOPER MASTERY
    Module 01: SQL Fundamentals
    Lesson 02: Creating Tables
================================================================================

    WHAT YOU'LL LEARN:
    ------------------
    1. Basic table creation syntax
    2. Choosing appropriate data types
    3. Primary keys and identity columns
    4. NOT NULL and DEFAULT constraints
    5. Foreign key relationships
    6. CHECK constraints for data validation
    7. Table design best practices

    WHY THIS MATTERS:
    -----------------
    - Tables are the foundation of your database
    - Proper design prevents data quality issues
    - Good data types improve performance
    - Constraints enforce business rules at the database level

    PREREQUISITES:
    --------------
    - Completed 01_create_database.sql
    - Understanding of basic database concepts

================================================================================
*/

-- ============================================================================
-- DATABASE SETUP
-- ============================================================================

/*
    🔹 LOCAL SQL SERVER USERS:
    Uncomment and run the following block to create a fresh database:
    
    USE master;
    GO
    IF EXISTS (SELECT name FROM sys.databases WHERE name = 'LearningDB')
    BEGIN
        ALTER DATABASE LearningDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE LearningDB;
    END
    GO
    CREATE DATABASE LearningDB;
    GO
    USE LearningDB;
    GO
    
    🔹 AZURE SQL USERS:
    - Database is already created via Azure Portal
    - Just make sure you're connected to your database
    - Run the table creation scripts below directly
*/

-- Verify which database you're connected to
SELECT DB_NAME() AS CurrentDatabase;
GO


-- ============================================================================
-- SECTION 1: BASIC TABLE CREATION
-- ============================================================================

/*
    THE ANATOMY OF CREATE TABLE:
    
    CREATE TABLE TableName (
        ColumnName DataType [NULL | NOT NULL] [CONSTRAINT],
        ColumnName DataType [NULL | NOT NULL] [CONSTRAINT],
        ...
        [TABLE CONSTRAINTS]
    );
    
    RULES:
    - Table names should be singular (Customer, not Customers)
    - Use PascalCase for names
    - Every table should have a primary key
    - Be explicit about NULL/NOT NULL
*/

-- Simple table example
CREATE TABLE Department (
    --IDENTITY(1,1) means: start at 1, increment by 1
    --This auto-generates unique IDs
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,

    --VARCHAR(100): Variable-length string, max 100 characters
    --NOT NULL: This field is required
    DepartmentName VARCHAR(100) NOT NULL,

    --DATETIME2: Modern datetime type (more precise than DATETIME)
    --DEFAULT: Automatically sets value if not provided
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

PRINT 'Department table created!';
GO

-- ============================================================================
-- SECTION 2: DATA TYPES IN DEPTH
-- ============================================================================

/*
    SQL SERVER DATA TYPES - COMPLETE GUIDE:
    
    ┌─────────────────────────────────────────────────────────────────────────┐
    │ NUMERIC TYPES                                                           │
    ├──────────────┬──────────────┬─────────────────────────────────────────┤
    │ Type         │ Storage      │ Range / Use Case                        │
    ├──────────────┼──────────────┼─────────────────────────────────────────┤
    │ TINYINT      │ 1 byte       │ 0 to 255 (age, rating 1-5)              │
    │ SMALLINT     │ 2 bytes      │ -32,768 to 32,767                       │
    │ INT          │ 4 bytes      │ -2.1B to 2.1B (most IDs)                │
    │ BIGINT       │ 8 bytes      │ Very large numbers (billions of rows)   │
    │ DECIMAL(p,s) │ 5-17 bytes   │ Exact decimals (money, measurements)    │
    │ FLOAT        │ 4-8 bytes    │ Scientific data (approximate)           │
    │ MONEY        │ 8 bytes      │ Currency (-922T to 922T)                │
    └──────────────┴──────────────┴─────────────────────────────────────────┘
    
    ┌─────────────────────────────────────────────────────────────────────────┐
    │ STRING TYPES                                                            │
    ├──────────────┬──────────────┬─────────────────────────────────────────┤
    │ Type         │ Storage      │ Use Case                                │
    ├──────────────┼──────────────┼─────────────────────────────────────────┤
    │ CHAR(n)      │ n bytes      │ Fixed-length (state codes, country)     │
    │ VARCHAR(n)   │ n + 2 bytes  │ Variable text (names, descriptions)     │
    │ VARCHAR(MAX) │ Up to 2GB    │ Large text (articles, JSON)             │
    │ NCHAR(n)     │ 2n bytes     │ Fixed Unicode (international)           │
    │ NVARCHAR(n)  │ 2n + 2 bytes │ Variable Unicode (most apps today)      │
    │ TEXT         │ Up to 2GB    │ DEPRECATED - use VARCHAR(MAX)           │
    └──────────────┴──────────────┴─────────────────────────────────────────┘
    
    ┌─────────────────────────────────────────────────────────────────────────┐
    │ DATE/TIME TYPES                                                         │
    ├──────────────┬──────────────┬─────────────────────────────────────────┤
    │ Type         │ Storage      │ Use Case                                │
    ├──────────────┼──────────────┼─────────────────────────────────────────┤
    │ DATE         │ 3 bytes      │ Date only (birthdate, hire date)        │
    │ TIME         │ 3-5 bytes    │ Time only (opening hours)               │
    │ DATETIME     │ 8 bytes      │ Legacy - use DATETIME2 instead          │
    │ DATETIME2    │ 6-8 bytes    │ Date + time (recommended)               │
    │ DATETIMEOFFSET│9-10 bytes   │ With timezone (global apps)             │
    └──────────────┴──────────────┴─────────────────────────────────────────┘
    
    ┌─────────────────────────────────────────────────────────────────────────┐
    │ OTHER TYPES                                                             │
    ├──────────────┬──────────────┬─────────────────────────────────────────┤
    │ Type         │ Storage      │ Use Case                                │
    ├──────────────┼──────────────┼─────────────────────────────────────────┤
    │ BIT          │ 1 bit        │ Boolean (IsActive, HasAccess)           │
    │ UNIQUEIDENTIFIER│16 bytes   │ GUIDs (distributed systems)             │
    │ VARBINARY(n) │ n + 2 bytes  │ Binary data (files, images)             │
    │ XML          │ Up to 2GB    │ XML documents                           │
    │ JSON         │ VARCHAR/NVARCHAR │ JSON data (use NVARCHAR(MAX))       │
    └──────────────┴──────────────┴─────────────────────────────────────────┘
*/

-- Table demonstrating various data types
CREATE TABLE DataTypeDemo (
    -- Integer types
    TinyIntCol TINYINT,          -- 0 to 255
    SmallIntCol SMALLINT,        -- -32,768 to 32,767
    IntCol INT,                  -- Most common for IDs
    BigIntCol BIGINT,            -- For very large numbers
    
    -- Decimal types
    DecimalCol DECIMAL(10, 2),   -- 10 digits total, 2 after decimal
    MoneyCol MONEY,              -- Built-in currency type
    FloatCol FLOAT,              -- Approximate (scientific)
    
    -- String types
    CharCol CHAR(10),            -- Fixed 10 characters (pads with spaces)
    VarCharCol VARCHAR(100),     -- Up to 100 characters
    NVarCharCol NVARCHAR(100),   -- Unicode, up to 100 characters
    MaxVarCharCol VARCHAR(MAX),  -- Up to 2GB text
    
    -- Date/Time types
    DateCol DATE,                -- Just the date
    TimeCol TIME,                -- Just the time
    DateTime2Col DATETIME2,      -- Date and time (recommended)
    DateTimeOffsetCol DATETIMEOFFSET, -- With timezone
    
    -- Other types
    BitCol BIT,                  -- 0, 1, or NULL
    GuidCol UNIQUEIDENTIFIER,    -- GUID
    BinaryCol VARBINARY(100)     -- Binary data
);
GO

PRINT 'DataTypeDemo table created!';
GO


-- ============================================================================
-- SECTION 3: PRIMARY KEYS AND IDENTITY
-- ============================================================================

/*
    PRIMARY KEY:
    - Uniquely identifies each row
    - Cannot contain NULL values
    - Only one per table
    - Creates a clustered index by default
    
    IDENTITY:
    - Auto-generates sequential numbers
    - IDENTITY(seed, increment)
    - Cannot be updated after insert
    - Does NOT guarantee no gaps
    
    WHEN TO USE IDENTITY vs GUID:
    ┌────────────────────┬──────────────────────────────────────────────┐
    │ Use IDENTITY (INT) │ Use UNIQUEIDENTIFIER (GUID)                  │
    ├────────────────────┼──────────────────────────────────────────────┤
    │ Single database    │ Distributed systems                          │
    │ Simple apps        │ Merge replication                            │
    │ Better performance │ Generate IDs in app code                     │
    │ Smaller storage    │ Privacy (can't guess next ID)                │
    └────────────────────┴──────────────────────────────────────────────┘
*/

-- Table with INT Identity Primary Key (most common)
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    HireDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Salary DECIMAL(10, 2) NULL,  -- NULL because salary might not be set immediately
    IsActive BIT NOT NULL DEFAULT 1,
    DepartmentID INT NULL  -- Will become FK later
);
GO

-- Table with GUID Primary Key
CREATE TABLE ExternalOrder (
    -- NEWID() generates a random GUID
    -- NEWSEQUENTIALID() generates sequential GUIDs (better for indexes)
    OrderID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ExternalSystemID VARCHAR(50) NOT NULL,
    OrderData NVARCHAR(MAX) NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- Table with composite primary key (multiple columns)
CREATE TABLE EmployeeProject (
    EmployeeID INT NOT NULL,
    ProjectID INT NOT NULL,
    AssignedDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Role NVARCHAR(50) NOT NULL,
    
    -- Composite primary key: combination must be unique
    PRIMARY KEY (EmployeeID, ProjectID)
);
GO

PRINT 'Primary key example tables created!';
GO


-- ============================================================================
-- SECTION 4: NOT NULL, DEFAULT, AND COMPUTED COLUMNS
-- ============================================================================

/*
    NOT NULL:
    - Column must have a value
    - Best practice: be explicit about NULL/NOT NULL
    - Rule: if column should always have a value, make it NOT NULL
    
    DEFAULT:
    - Automatic value when none provided
    - Can be: constants, functions, expressions
    - Common: GETDATE(), NEWID(), 0, '', specific strings
    
    COMPUTED COLUMNS:
    - Calculated from other columns
    - Can be PERSISTED (stored) or virtual (calculated on query)
    - PERSISTED can be indexed
*/

CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- NOT NULL: Product must have a name
    ProductName NVARCHAR(200) NOT NULL,
    
    -- NULL allowed: Description is optional
    Description NVARCHAR(MAX) NULL,
    
    -- NOT NULL with DEFAULT: Category defaults to 'General'
    Category NVARCHAR(50) NOT NULL DEFAULT 'General',
    
    -- Pricing columns
    UnitPrice DECIMAL(10, 2) NOT NULL,
    DiscountPercent DECIMAL(5, 2) NOT NULL DEFAULT 0,
    TaxRate DECIMAL(5, 4) NOT NULL DEFAULT 0.0825,  -- 8.25% default tax
    
    -- COMPUTED COLUMN: DiscountedPrice = UnitPrice * (1 - DiscountPercent/100)
    -- Not persisted - calculated on every query
    DiscountedPrice AS (UnitPrice * (1 - DiscountPercent / 100)),
    
    -- PERSISTED COMPUTED: Stored on disk, can be indexed
    -- FinalPrice = DiscountedPrice * (1 + TaxRate)
    FinalPrice AS (UnitPrice * (1 - DiscountPercent / 100) * (1 + TaxRate)) PERSISTED,
    
    -- Audit columns with defaults
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    ModifiedDate DATETIME2 NULL,
    ModifiedBy NVARCHAR(100) NULL,
    
    -- Status with default
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0  -- Soft delete pattern
);
GO

PRINT 'Product table with defaults and computed columns created!';
GO


-- ============================================================================
-- SECTION 5: FOREIGN KEYS AND RELATIONSHIPS
-- ============================================================================

/*
    FOREIGN KEY (FK):
    - Links two tables together
    - Enforces referential integrity
    - Child table references parent table
    
    RELATIONSHIP TYPES:
    ┌─────────────────┬────────────────────────────────────────────────────┐
    │ Type            │ Implementation                                      │
    ├─────────────────┼────────────────────────────────────────────────────┤
    │ One-to-Many     │ FK in "many" table pointing to "one" table         │
    │ One-to-One      │ FK with UNIQUE constraint                          │
    │ Many-to-Many    │ Junction table with two FKs                        │
    └─────────────────┴────────────────────────────────────────────────────┘
    
    ON DELETE/UPDATE OPTIONS:
    - NO ACTION: Prevent delete/update if referenced (default)
    - CASCADE: Delete/update child rows automatically
    - SET NULL: Set FK column to NULL
    - SET DEFAULT: Set FK column to default value
*/

-- Parent table: Project
CREATE TABLE Project (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName NVARCHAR(100) NOT NULL,
    Budget DECIMAL(15, 2) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Planning'
);
GO

-- Child table: Task (Many Tasks belong to One Project)
CREATE TABLE Task (
    TaskID INT IDENTITY(1,1) PRIMARY KEY,
    TaskName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    
    -- Foreign Key column
    ProjectID INT NOT NULL,
    
    AssignedTo INT NULL,  -- Will be FK to Employee
    DueDate DATE NULL,
    Priority TINYINT NOT NULL DEFAULT 3,  -- 1=High, 2=Medium, 3=Low
    Status NVARCHAR(20) NOT NULL DEFAULT 'Not Started',
    
    -- FOREIGN KEY CONSTRAINT with name
    -- ON DELETE CASCADE: If project deleted, delete its tasks
    CONSTRAINT FK_Task_Project FOREIGN KEY (ProjectID)
        REFERENCES Project(ProjectID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- FK to Employee with different behavior
    -- ON DELETE SET NULL: If employee deleted, set AssignedTo to NULL
    CONSTRAINT FK_Task_Employee FOREIGN KEY (AssignedTo)
        REFERENCES Employee(EmployeeID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
GO

-- Junction table for Many-to-Many: Employee <-> Project
-- This table already exists as EmployeeProject, let's add FKs
ALTER TABLE EmployeeProject
ADD CONSTRAINT FK_EmployeeProject_Employee 
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
    ON DELETE CASCADE;

ALTER TABLE EmployeeProject
ADD CONSTRAINT FK_EmployeeProject_Project 
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
    ON DELETE CASCADE;
GO

-- One-to-One relationship: Employee to EmployeeDetails
CREATE TABLE EmployeeDetails (
    EmployeeID INT PRIMARY KEY,  -- Same as Employee.EmployeeID
    
    -- Personal information (sensitive, stored separately)
    DateOfBirth DATE NULL,
    SSN CHAR(11) NULL,  -- Format: XXX-XX-XXXX
    PersonalEmail NVARCHAR(255) NULL,
    EmergencyContact NVARCHAR(100) NULL,
    EmergencyPhone VARCHAR(20) NULL,
    
    -- Foreign Key that's also Primary Key = One-to-One
    CONSTRAINT FK_EmployeeDetails_Employee 
        FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
        ON DELETE CASCADE
);
GO

PRINT 'Foreign key relationship tables created!';
GO


-- ============================================================================
-- SECTION 6: CHECK CONSTRAINTS
-- ============================================================================

/*
    CHECK CONSTRAINTS:
    - Validate data before insert/update
    - Enforce business rules at database level
    - More reliable than application-only validation
    
    WHEN TO USE CHECK CONSTRAINTS:
    - Valid ranges (age > 0, price >= 0)
    - Valid formats (email pattern, phone format)
    - Valid values (status IN ('Active', 'Inactive'))
    - Column comparisons (EndDate >= StartDate)
*/

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Name constraints
    FirstName NVARCHAR(50) NOT NULL
        CONSTRAINT CK_Customer_FirstName CHECK (LEN(FirstName) >= 2),
    LastName NVARCHAR(50) NOT NULL
        CONSTRAINT CK_Customer_LastName CHECK (LEN(LastName) >= 2),
    
    -- Email constraint (basic pattern check)
    Email NVARCHAR(255) NOT NULL
        CONSTRAINT CK_Customer_Email CHECK (Email LIKE '%_@_%.__%'),
    
    -- Age constraint
    Age TINYINT NULL
        CONSTRAINT CK_Customer_Age CHECK (Age >= 18 AND Age <= 120),
    
    -- Status must be one of specific values
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active'
        CONSTRAINT CK_Customer_Status CHECK (Status IN ('Active', 'Inactive', 'Pending', 'Suspended')),
    
    -- Credit limit must be positive or zero
    CreditLimit DECIMAL(10, 2) NOT NULL DEFAULT 0
        CONSTRAINT CK_Customer_CreditLimit CHECK (CreditLimit >= 0),
    
    -- Phone format (simple check)
    Phone VARCHAR(20) NULL
        CONSTRAINT CK_Customer_Phone CHECK (
            Phone IS NULL OR LEN(Phone) >= 10
        ),
    
    -- Dates
    RegistrationDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    LastPurchaseDate DATE NULL
);
GO

-- Table-level CHECK constraint (comparing multiple columns)
CREATE TABLE Contract (
    ContractID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ContractName NVARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Value DECIMAL(15, 2) NOT NULL,
    
    -- Table-level constraint: EndDate must be after StartDate
    CONSTRAINT CK_Contract_Dates CHECK (EndDate > StartDate),
    
    -- Contract value must be positive
    CONSTRAINT CK_Contract_Value CHECK (Value > 0),
    
    -- Foreign key
    CONSTRAINT FK_Contract_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
);
GO

PRINT 'Check constraint tables created!';
GO


-- ============================================================================
-- SECTION 7: UNIQUE CONSTRAINTS
-- ============================================================================

/*
    UNIQUE CONSTRAINTS:
    - Ensures column(s) have unique values
    - Unlike PRIMARY KEY, allows ONE NULL value
    - Can have multiple UNIQUE constraints per table
    
    UNIQUE vs PRIMARY KEY:
    ┌────────────────┬───────────────────────────────────────────────────┐
    │ PRIMARY KEY    │ UNIQUE CONSTRAINT                                 │
    ├────────────────┼───────────────────────────────────────────────────┤
    │ Only one       │ Multiple allowed                                  │
    │ No NULLs       │ One NULL allowed                                  │
    │ Creates CI*    │ Creates NCI**                                     │
    │ Row identifier │ Business rule enforcement                         │
    └────────────────┴───────────────────────────────────────────────────┘
    * CI = Clustered Index
    ** NCI = Non-Clustered Index
*/

CREATE TABLE Account (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Email must be unique across all accounts
    Email NVARCHAR(255) NOT NULL,
    CONSTRAINT UQ_Account_Email UNIQUE (Email),
    
    -- Username must be unique
    Username NVARCHAR(50) NOT NULL,
    CONSTRAINT UQ_Account_Username UNIQUE (Username),
    
    -- Phone is optional but must be unique if provided
    Phone VARCHAR(20) NULL,
    CONSTRAINT UQ_Account_Phone UNIQUE (Phone),
    
    -- External ID from another system (unique identifier)
    ExternalID VARCHAR(50) NULL,
    CONSTRAINT UQ_Account_ExternalID UNIQUE (ExternalID),
    
    PasswordHash VARBINARY(256) NOT NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- Composite unique constraint
CREATE TABLE InventoryLocation (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    Warehouse VARCHAR(50) NOT NULL,
    Aisle VARCHAR(10) NOT NULL,
    Shelf VARCHAR(10) NOT NULL,
    Bin VARCHAR(10) NOT NULL,
    
    -- Combination of Warehouse + Aisle + Shelf + Bin must be unique
    -- You can't have two locations with the same address
    CONSTRAINT UQ_InventoryLocation_Address UNIQUE (Warehouse, Aisle, Shelf, Bin),
    
    Description NVARCHAR(200) NULL,
    MaxCapacity INT NOT NULL DEFAULT 100
);
GO

PRINT 'Unique constraint tables created!';
GO


-- ============================================================================
-- SECTION 8: BEST PRACTICES TABLE DESIGN
-- ============================================================================

/*
    COMPLETE TABLE WITH ALL BEST PRACTICES:
    
    This example shows a production-ready table design with:
    ✅ Proper naming conventions
    ✅ Appropriate data types
    ✅ Primary key with identity
    ✅ NOT NULL where required
    ✅ Default values
    ✅ Check constraints
    ✅ Foreign keys
    ✅ Unique constraints
    ✅ Audit columns
*/

-- Status lookup table (for normalization)
CREATE TABLE OrderStatus (
    StatusID TINYINT PRIMARY KEY,  -- Manual ID for lookup tables
    StatusName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    SortOrder TINYINT NOT NULL DEFAULT 0
);
GO

-- Insert lookup values
INSERT INTO OrderStatus (StatusID, StatusName, Description, SortOrder) VALUES
(1, 'Pending', 'Order received, awaiting processing', 1),
(2, 'Processing', 'Order is being prepared', 2),
(3, 'Shipped', 'Order has been shipped', 3),
(4, 'Delivered', 'Order delivered to customer', 4),
(5, 'Cancelled', 'Order was cancelled', 5),
(6, 'Refunded', 'Order was refunded', 6);
GO

-- The Order table (production-ready design)
CREATE TABLE [Order] (  -- Note: "Order" is a reserved word, so we use brackets
    -- Primary Key
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Business key (human-readable order number)
    OrderNumber AS ('ORD-' + RIGHT('000000' + CAST(OrderID AS VARCHAR(6)), 6)) PERSISTED,
    
    -- Foreign Keys
    CustomerID INT NOT NULL
        CONSTRAINT FK_Order_Customer FOREIGN KEY REFERENCES Customer(CustomerID),
    StatusID TINYINT NOT NULL DEFAULT 1
        CONSTRAINT FK_Order_Status FOREIGN KEY REFERENCES OrderStatus(StatusID),
    
    -- Order details
    OrderDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    RequiredDate DATE NULL
        CONSTRAINT CK_Order_RequiredDate CHECK (RequiredDate IS NULL OR RequiredDate >= CAST(GETDATE() AS DATE)),
    ShippedDate DATETIME2 NULL,
    
    -- Pricing
    SubTotal DECIMAL(12, 2) NOT NULL DEFAULT 0
        CONSTRAINT CK_Order_SubTotal CHECK (SubTotal >= 0),
    TaxAmount DECIMAL(10, 2) NOT NULL DEFAULT 0
        CONSTRAINT CK_Order_TaxAmount CHECK (TaxAmount >= 0),
    ShippingAmount DECIMAL(10, 2) NOT NULL DEFAULT 0
        CONSTRAINT CK_Order_ShippingAmount CHECK (ShippingAmount >= 0),
    DiscountAmount DECIMAL(10, 2) NOT NULL DEFAULT 0
        CONSTRAINT CK_Order_DiscountAmount CHECK (DiscountAmount >= 0),
    
    -- Computed total
    TotalAmount AS (SubTotal + TaxAmount + ShippingAmount - DiscountAmount) PERSISTED,
    
    -- Shipping information
    ShippingAddress NVARCHAR(500) NULL,
    ShippingCity NVARCHAR(100) NULL,
    ShippingState NVARCHAR(50) NULL,
    ShippingPostalCode VARCHAR(20) NULL,
    ShippingCountry NVARCHAR(100) NULL DEFAULT 'United States',
    
    -- Notes
    CustomerNotes NVARCHAR(MAX) NULL,
    InternalNotes NVARCHAR(MAX) NULL,
    
    -- Audit columns (every table should have these)
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    ModifiedDate DATETIME2 NULL,
    ModifiedBy NVARCHAR(100) NULL,
    
    -- Soft delete
    IsDeleted BIT NOT NULL DEFAULT 0,
    DeletedDate DATETIME2 NULL,
    DeletedBy NVARCHAR(100) NULL,
    
    -- Table-level constraint: ShippedDate must be after OrderDate
    CONSTRAINT CK_Order_ShippedDate CHECK (
        ShippedDate IS NULL OR ShippedDate >= OrderDate
    )
);
GO

-- Add unique constraint on OrderNumber
ALTER TABLE [Order]
ADD CONSTRAINT UQ_Order_OrderNumber UNIQUE (OrderNumber);
GO

PRINT 'Best practices Order table created!';
GO


-- ============================================================================
-- SECTION 9: VIEWING TABLE INFORMATION
-- ============================================================================

/*
    USEFUL QUERIES TO INSPECT YOUR TABLES:
*/

-- List all tables in the database
SELECT 
    TABLE_SCHEMA AS [Schema],
    TABLE_NAME AS TableName,
    TABLE_TYPE AS TableType
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

-- View columns for a specific table
SELECT 
    COLUMN_NAME AS ColumnName,
    DATA_TYPE AS DataType,
    CHARACTER_MAXIMUM_LENGTH AS MaxLength,
    IS_NULLABLE AS IsNullable,
    COLUMN_DEFAULT AS DefaultValue
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Order'
ORDER BY ORDINAL_POSITION;
GO

-- View all constraints
SELECT 
    tc.TABLE_NAME AS TableName,
    tc.CONSTRAINT_NAME AS ConstraintName,
    tc.CONSTRAINT_TYPE AS ConstraintType
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
WHERE tc.TABLE_SCHEMA = 'dbo'
ORDER BY tc.TABLE_NAME, tc.CONSTRAINT_TYPE;
GO

-- View foreign key relationships
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
ORDER BY ChildTable, ForeignKeyName;
GO


-- ============================================================================
-- SECTION 10: COMMON MISTAKES AND HOW TO AVOID THEM
-- ============================================================================

/*
    ❌ MISTAKE 1: Using incorrect data types for dates
    
    -- Bad: 
    CREATE TABLE BadDates (
        OrderDate VARCHAR(50)  -- Can store '13/45/2099' - invalid!
    );
    
    -- Good:
    CREATE TABLE GoodDates (
        OrderDate DATE NOT NULL  -- Only valid dates allowed
    );
*/

/*
    ❌ MISTAKE 2: Not being explicit about NULL
    
    -- Bad: Relying on defaults
    CREATE TABLE Unclear (
        Name VARCHAR(50),  -- Is NULL okay? Unclear!
        Status INT         -- What does NULL mean here?
    );
    
    -- Good: Explicit intention
    CREATE TABLE Clear (
        Name VARCHAR(50) NOT NULL,     -- Required field
        Status INT NULL                -- Optional, NULL has meaning
    );
*/

/*
    ❌ MISTAKE 3: Using FLOAT for money
    
    -- Bad: FLOAT has precision issues
    CREATE TABLE BadMoney (
        Price FLOAT  -- 0.1 + 0.2 might = 0.30000000000000004
    );
    
    -- Good: DECIMAL for exact precision
    CREATE TABLE GoodMoney (
        Price DECIMAL(10, 2)  -- Exact: $12345678.99
    );
*/

/*
    ❌ MISTAKE 4: Missing foreign keys
    
    -- Bad: No referential integrity
    CREATE TABLE BadOrder (
        OrderID INT PRIMARY KEY,
        CustomerID INT  -- No FK - can reference non-existent customer!
    );
    
    -- Good: Foreign key enforces integrity
    CREATE TABLE GoodOrder (
        OrderID INT PRIMARY KEY,
        CustomerID INT NOT NULL
            FOREIGN KEY REFERENCES Customer(CustomerID)
    );
*/

/*
    ❌ MISTAKE 5: Forgetting indexes on foreign keys
    
    -- Foreign key columns should usually have indexes
    -- We'll cover this in Module 07: Views and Indexes
*/


-- ============================================================================
-- SUMMARY
-- ============================================================================

/*
    KEY TAKEAWAYS:
    
    1. DATA TYPES:
       - Use INT for most IDs
       - Use DECIMAL for money (not FLOAT)
       - Use NVARCHAR for international text
       - Use DATETIME2 for timestamps (not DATETIME)
    
    2. CONSTRAINTS:
       - Every table needs a PRIMARY KEY
       - Use NOT NULL + DEFAULT for required fields
       - Use FOREIGN KEYS to enforce relationships
       - Use CHECK constraints for business rules
       - Use UNIQUE for natural keys
    
    3. BEST PRACTICES:
       - Be explicit about NULL/NOT NULL
       - Add audit columns (CreatedDate, ModifiedDate)
       - Consider soft delete (IsDeleted) vs hard delete
       - Use lookup tables for status/type values
    
    4. NAMING CONVENTIONS:
       - Tables: PascalCase, singular (Customer, not Customers)
       - Columns: PascalCase (FirstName, CustomerID)
       - Constraints: PREFIX_Table_Column (FK_Order_Customer)
    
    NEXT LESSON: 03_insert_data.sql - Populating tables with data
*/
