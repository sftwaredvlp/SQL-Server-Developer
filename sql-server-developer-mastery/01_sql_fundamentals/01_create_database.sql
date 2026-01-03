/*
================================================================================
    SQL SERVER DEVELOPER MASTERY
    Module 01: SQL Fundamentals
    Lesson 01: Creating Databases
================================================================================

    WHAT YOU'LL LEARN:
    ------------------
    1. Basic database creation syntax
    2. Database configuration options (file paths, sizes, growth)
    3. Collation settings and why they matter
    4. Checking if a database exists before creating
    5. Best practices for production database setup

    WHY THIS MATTERS:
    -----------------
    - Every SQL Server project starts with a database
    - Proper initial configuration prevents performance issues later
    - Understanding file groups helps with maintenance and optimization
    - Collation affects sorting, comparison, and case sensitivity

    PREREQUISITES:
    --------------
    - SQL Server installed (Express, Developer, or Enterprise edition)
    - Sufficient permissions (sysadmin or CREATE DATABASE permission)
    - SSMS (SQL Server Management Studio) or Azure Data Studio

================================================================================
*/

-- ============================================================================
-- SECTION 1: SIMPLEST DATABASE CREATION
-- ============================================================================

/*
    The most basic way to create a database.
    
    WHAT HAPPENS BEHIND THE SCENES:
    - SQL Server creates two files:
      1. Data file (.mdf) - stores your actual data
      2. Log file (.ldf) - stores transaction logs for recovery
    - Uses default file locations from SQL Server configuration
    - Uses default sizes (usually 8MB data, 1MB log)
    - Uses server's default collation
    
    WHEN TO USE:
    - Learning and experimentation
    - Quick prototypes
    - Development environments
    
    ⚠️ WARNING: Never use this in production - always configure explicitly!
*/

--First, let's check if the database already exists and drop it   
--This is  a common pattern for development scripts
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SimpleDB')
BEGIN
    -- Set to single user mode to force disconnect all users
     ALTER DATABASE SimpleDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
     DROP DATABASE SimpleDB;
     PRINT 'Existing SimpleDB dropped successfully.';
END 
GO 

-- Now create the simple database
CREATE DATABASE SimpleDB;
GO 

-- Verify it was created
SELECT 
    name,                           -- Database name
    database_id,                    -- Unique ID for this database
    create_date,                    -- When it was created
    collation_name,                 -- Collation (affects sorting/comparison)
    state_desc                      -- Should be 'ONLINE'
FROM sys.databases
WHERE name = 'SimpleDB';
GO

PRINT 'SimpleDB created successfully!';
GO

/* We are using go because some commands should work seperately
-- Failed without GO
CREATE DATABASE SimpleDB
USE SimpleDB -- Failed! Database has not been created yet.

-- With GO
CREATE DATABASE SimpleDB;
GO -- Wait for the Database to be created.
USE SimpleDB; -- You can use now
GO
*/



-- ============================================================================
-- SECTION 2: DATABASE WITH EXPLICIT CONFIGURATION
-- ============================================================================

/*
    Production-ready database creation with explicit settings.
    
    KEY CONCEPTS:
    
    1. PRIMARY FILE GROUP:
       - Contains the primary data file (.mdf)
       - Stores system tables and objects not assigned to other filegroups
       - Every database must have exactly one primary filegroup
    
    2. DATA FILE SETTINGS:
       - NAME: Logical name used in T-SQL commands
       - FILENAME: Physical path on disk
       - SIZE: Initial size (prevents constant auto-growth during setup)
       - MAXSIZE: Prevents runaway disk usage
       - FILEGROWTH: How much to grow when full
    
    3. LOG FILE:
       - Stores transaction log records
       - Critical for recovery and replication
       - Should be on separate physical disk in production
    
    WHY THESE SETTINGS MATTER:
    - Proper initial size reduces auto-growth events
    - Auto-growth events cause brief blocking
    - MAXSIZE prevents a bug from filling your disk
    - Percentage growth can cause huge single growth events
*/

-- Clean up if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CompanyDB')
BEGIN
    ALTER DATABASE CompanyDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CompanyDB;
END
GO

-- Create database with explicit configuration
CREATE DATABASE CompanyDB
ON PRIMARY  -- Specifies this is the primary filegroup
(
    -- Logical name: Used in ALTER DATABASE and backup commands
    NAME = CompanyDB_Data,
    
    -- Physical location: Where the file lives on disk
    -- ⚠️ IMPORTANT: Change this path to match your system!
    -- Common paths:
    --   Windows: 'C:\SQLData\CompanyDB.mdf'
    --   Linux: '/var/opt/mssql/data/CompanyDB.mdf'
    FILENAME = '/var/opt/mssql/data/CompanyDB.mdf',
    
    -- Initial size: Start with enough space for your expected data
    -- WHY: Avoids auto-growth events during initial data load
    -- RULE OF THUMB: Estimate 6 months of data + 50% buffer
    SIZE = 100MB,
    
    -- Maximum size: Safety limit
    -- UNLIMITED is okay for primary database files in production
    -- But consider setting a limit for non-critical databases
    MAXSIZE = UNLIMITED,
    
    -- Growth increment: How much to add when file is full
    -- ✅ BEST PRACTICE: Use fixed MB, not percentage
    -- WHY: 10% of 1TB = 100GB growth event = long blocking!
    FILEGROWTH = 100MB
)
LOG ON  -- Configures the transaction log file
(
    NAME = CompanyDB_Log,
    FILENAME = '/var/opt/mssql/data/CompanyDB.ldf',
    
    -- Log file size: Start reasonably sized
    -- WHY: Prevents log growth during heavy operations
    SIZE = 50MB,
    
    -- Log MAXSIZE: Consider limiting to prevent runaway growth
    -- If log fills up, transactions fail!
    MAXSIZE = 2GB,
    
    -- Log growth: Smaller increments than data file
    FILEGROWTH = 50MB
);
GO

PRINT 'CompanyDB created with custom configuration!';
GO


-- ============================================================================
-- SECTION 3: DATABASE WITH COLLATION
-- ============================================================================

/*
    COLLATION: How SQL Server sorts and compares text.
    
    COLLATION NAME BREAKDOWN: Latin1_General_CI_AS
    - Latin1_General: Character set (Western European)
    - CI: Case Insensitive ('A' = 'a')
    - AS: Accent Sensitive ('ä' ≠ 'a')
    
    COMMON COLLATION OPTIONS:
    ┌─────────────────────────────────┬──────────────────────────────────────┐
    │ Collation                       │ Use Case                             │
    ├─────────────────────────────────┼──────────────────────────────────────┤
    │ Latin1_General_CI_AS            │ Most English/Western apps            │
    │ Latin1_General_CS_AS            │ When case matters (passwords)        │
    │ SQL_Latin1_General_CP1_CI_AS    │ Legacy SQL Server apps               │
    │ Turkish_CI_AS                   │ Turkish language (special I rules)   │
    │ Japanese_CI_AS                  │ Japanese applications                │
    └─────────────────────────────────┴──────────────────────────────────────┘
    
    ⚠️ CRITICAL: Collation mismatches between databases cause errors!
    When joining tables from different databases, collations must match.
    
    COMMON ERROR:
    "Cannot resolve the collation conflict between 'SQL_Latin1_General_CP1_CI_AS' 
    and 'Latin1_General_CI_AS' in the equal to operation."
*/

-- Clean up if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'InternationalDB')
BEGIN
    ALTER DATABASE InternationalDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE InternationalDB;
END
GO

-- Create database with specific collation
CREATE DATABASE InternationalDB
COLLATE Latin1_General_CI_AS;  -- Case-Insensitive, Accent-Sensitive
GO

-- Verify collation was set
SELECT 
    name,
    collation_name
FROM sys.databases
WHERE name = 'InternationalDB';
GO

-- Demonstrate case insensitivity
USE InternationalDB;
GO

CREATE TABLE CollationTest (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO CollationTest VALUES (1, 'John');
GO

-- Both queries return the same result due to CI (Case Insensitive)
SELECT * FROM CollationTest WHERE Name = 'John';  -- Finds it
SELECT * FROM CollationTest WHERE Name = 'JOHN';  -- Also finds it!
SELECT * FROM CollationTest WHERE Name = 'john';  -- Also finds it!
GO

PRINT 'Case insensitive comparison demonstrated!';
GO

USE master;
GO


-- ============================================================================
-- SECTION 4: SAFE DATABASE CREATION PATTERN
-- ============================================================================

/*
    THE PATTERN YOU'LL USE IN REAL PROJECTS:
    
    This is the "defensive" pattern that:
    1. Checks if database exists
    2. Creates only if it doesn't exist
    3. Prints helpful status messages
    4. Can be run multiple times safely (idempotent)
    
    WHY THIS PATTERN:
    - Safe to include in deployment scripts
    - Won't accidentally drop existing data
    - Provides feedback on what happened
    - Standard practice in CI/CD pipelines
*/

DECLARE @DatabaseName NVARCHAR(128) = 'SafeDB';

-- Check if database already exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = @DatabaseName)
BEGIN
    -- Database doesn't exist, create it
    PRINT 'Creating database: ' + @DatabaseName;
    
    -- Note: CREATE DATABASE doesn't support variables directly
    -- We need to use dynamic SQL
    DECLARE @SQL NVARCHAR(MAX) = N'
        CREATE DATABASE ' + QUOTENAME(@DatabaseName) + N'
        ON PRIMARY 
        (
            NAME = ' + QUOTENAME(@DatabaseName + N'_Data', '''') + N',
            FILENAME = ' + QUOTENAME('/var/opt/mssql/data/' + @DatabaseName + N'.mdf', '''') + N',
            SIZE = 50MB,
            MAXSIZE = UNLIMITED,
            FILEGROWTH = 50MB
        )
        LOG ON 
        (
            NAME = ' + QUOTENAME(@DatabaseName + N'_Log', '''') + N',
            FILENAME = ' + QUOTENAME('/var/opt/mssql/data/' + @DatabaseName + N'.ldf', '''') + N',
            SIZE = 25MB,
            MAXSIZE = 1GB,
            FILEGROWTH = 25MB
        )';
    
    EXEC sp_executesql @SQL;
    
    PRINT 'Database ' + @DatabaseName + ' created successfully!';
END
ELSE
BEGIN
    PRINT 'Database ' + @DatabaseName + ' already exists. No action taken.';
END
GO


-- ============================================================================
-- SECTION 5: VIEWING DATABASE INFORMATION
-- ============================================================================

/*
    IMPORTANT SYSTEM VIEWS FOR DATABASE INFORMATION:
    
    1. sys.databases - All databases on the server
    2. sys.database_files - Files for current database
    3. sys.master_files - All database files (from master)
    
    USE THESE TO:
    - Verify database creation
    - Check file sizes and growth settings
    - Monitor space usage
    - Troubleshoot issues
*/

-- List all user databases (excluding system databases)
SELECT 
    database_id,
    name AS DatabaseName,
    create_date AS CreatedOn,
    collation_name AS Collation,
    state_desc AS [Status],
    recovery_model_desc AS RecoveryModel
FROM sys.databases
WHERE database_id > 4  -- System databases have IDs 1-4
ORDER BY name;
GO

-- View file details for all databases we created
SELECT 
    DB_NAME(database_id) AS DatabaseName,
    name AS LogicalName,
    type_desc AS FileType,
    physical_name AS PhysicalPath,
    size * 8 / 1024 AS SizeMB,  -- Size is in 8KB pages
    CASE max_size
        WHEN -1 THEN 'UNLIMITED'
        WHEN 0 THEN 'No Growth'
        ELSE CAST(max_size * 8 / 1024 AS VARCHAR(20)) + ' MB'
    END AS MaxSize,
    CASE is_percent_growth
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '%'
        ELSE CAST(growth * 8 / 1024 AS VARCHAR(10)) + ' MB'
    END AS GrowthIncrement
FROM sys.master_files
WHERE DB_NAME(database_id) IN ('SimpleDB', 'CompanyDB', 'InternationalDB', 'SafeDB')
ORDER BY database_id, type_desc;
GO


-- ============================================================================
-- SECTION 6: COMMON MISTAKES AND HOW TO AVOID THEM
-- ============================================================================

/*
    ❌ MISTAKE 1: Using percentage growth on large databases
    
    Problem: 10% of 1TB = 100GB auto-growth event
    Impact: Database may be unresponsive for minutes
    
    -- Bad:
    FILEGROWTH = 10%
    
    -- Good:
    FILEGROWTH = 256MB
*/

/*
    ❌ MISTAKE 2: Not checking if database exists before creating
    
    Problem: Script fails if database exists
    Impact: Deployment scripts break
    
    -- Bad:
    CREATE DATABASE MyDB;
    
    -- Good:
    IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'MyDB')
        CREATE DATABASE MyDB;
*/

/*
    ❌ MISTAKE 3: Using default file locations in production
    
    Problem: Data and log files on same drive as OS
    Impact: Poor performance, risk of disk full stopping OS
    
    Best Practice:
    - OS on C:\
    - Data files (.mdf) on D:\ (fast storage)
    - Log files (.ldf) on E:\ (separate fast storage)
    - Backup files on F:\ (different physical storage)
*/

/*
    ❌ MISTAKE 4: Forgetting to drop test databases
    
    Problem: Accumulation of test databases
    Impact: Wasted disk space, confusing environment
    
    Best Practice:
    - Use consistent naming: TestDB_YYYYMMDD_YourName
    - Document in a wiki which databases are permanent
    - Regular cleanup scripts
*/

/*
    ❌ MISTAKE 5: Mismatched collations
    
    Problem: Different collations cause comparison errors
    Impact: JOINs between tables fail
    
    Best Practice:
    - Use same collation for all databases in an application
    - Document your standard collation
    - Use COLLATE keyword to handle legacy mismatches
*/


-- ============================================================================
-- SECTION 7: CLEANUP (OPTIONAL)
-- ============================================================================

/*
    Uncomment the following to clean up all databases created in this lesson.
    
    ⚠️ WARNING: Only run this if you want to remove the practice databases!
*/

/*
-- Clean up all practice databases
USE master;
GO

DECLARE @databases TABLE (name NVARCHAR(128));
INSERT INTO @databases VALUES ('SimpleDB'), ('CompanyDB'), ('InternationalDB'), ('SafeDB');

DECLARE @dbName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR 
SELECT name FROM @databases;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF EXISTS (SELECT name FROM sys.databases WHERE name = @dbName)
    BEGIN
        SET @sql = 'ALTER DATABASE ' + QUOTENAME(@dbName) + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
        EXEC sp_executesql @sql;
        
        SET @sql = 'DROP DATABASE ' + QUOTENAME(@dbName) + ';';
        EXEC sp_executesql @sql;
        
        PRINT 'Dropped: ' + @dbName;
    END
    FETCH NEXT FROM db_cursor INTO @dbName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT 'Cleanup complete!';
GO
*/


-- ============================================================================
-- SUMMARY
-- ============================================================================

/*
    KEY TAKEAWAYS:
    
    1. CREATE DATABASE creates both .mdf (data) and .ldf (log) files
    
    2. Always configure explicitly in production:
       - File locations
       - Initial sizes
       - Growth settings (use MB, not %)
       - Collation
    
    3. Use defensive patterns:
       - Check IF NOT EXISTS before creating
       - Scripts should be re-runnable (idempotent)
    
    4. Important system views:
       - sys.databases
       - sys.master_files
    
    5. Naming conventions:
       - Logical names: DatabaseName_Data, DatabaseName_Log
       - Physical files: DatabaseName.mdf, DatabaseName.ldf
    
    NEXT LESSON: 02_create_tables.sql - Designing tables with proper data types
*/