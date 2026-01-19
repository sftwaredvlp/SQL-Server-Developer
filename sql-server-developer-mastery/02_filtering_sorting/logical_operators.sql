/*
================================================================================
    SQL SERVER DEVELOPER MASTERY
    Module 02: Filtering and Sorting
    Lesson 02: Logical Operators
================================================================================

    WHAT YOU'LL LEARN:
    ------------------
    1. AND operator - all conditions must be true
    2. OR operator - any condition can be true
    3. NOT operator - negates a condition
    4. Operator precedence and parentheses
    5. Combining multiple operators
    6. Performance implications

    WHY THIS MATTERS:
    -----------------
    - Complex filters require multiple conditions
    - Wrong precedence causes incorrect results
    - Understanding logic prevents subtle bugs
    - Efficient combinations improve performance

    PREREQUISITES:
    --------------
    - Completed where_clause.sql
    - Understanding of basic WHERE conditions

================================================================================
*/

USE LearningDB;
GO


-- ============================================================================
-- SECTION 1: AND OPERATOR
-- ============================================================================

/*
    AND OPERATOR:
    
    - ALL conditions must be TRUE
    - Returns TRUE only when both sides are TRUE
    - Returns FALSE if any side is FALSE
    - Returns UNKNOWN if any side is UNKNOWN (NULL) and other is not FALSE
    
    TRUTH TABLE:
    ┌─────────┬─────────┬─────────┐
    │    A    │    B    │ A AND B │
    ├─────────┼─────────┼─────────┤
    │  TRUE   │  TRUE   │  TRUE   │
    │  TRUE   │  FALSE  │  FALSE  │
    │  TRUE   │ UNKNOWN │ UNKNOWN │
    │  FALSE  │  TRUE   │  FALSE  │
    │  FALSE  │  FALSE  │  FALSE  │
    │  FALSE  │ UNKNOWN │  FALSE  │
    │ UNKNOWN │  TRUE   │ UNKNOWN │
    │ UNKNOWN │  FALSE  │  FALSE  │
    │ UNKNOWN │ UNKNOWN │ UNKNOWN │
    └─────────┴─────────┴─────────┘
*/

-- Basic AND: Both conditions must be true
SELECT 
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Employee
WHERE DepartmentID = 1  -- Must be in IT department
  AND Salary > 80000;    -- AND earn more than 80k
GO

-- Multiple AND conditions
SELECT 
    FirstName,
    LastName,
    HireDate,
    Salary,
    IsActive
FROM Employee
WHERE IsActive = 1                      -- Must be active
  AND Salary >= 60000                   -- Salary at least 60k
  AND Salary <= 90000                   -- Salary at most 90k
  AND HireDate >= '2019-01-01';         -- Hired since 2019
GO

-- AND with different column types
SELECT 
    ProductName,
    Category,
    UnitPrice,
    IsActive
FROM Product
WHERE Category = 'Electronics'  -- Text comparison
  AND UnitPrice > 100           -- Numeric comparison
  AND IsActive = 1              -- Boolean comparison
  AND DiscountPercent > 0;      -- Has a discount
GO


-- ============================================================================
-- SECTION 2: OR OPERATOR
-- ============================================================================

/*
    OR OPERATOR:
    
    - ANY condition can be TRUE
    - Returns TRUE if at least one side is TRUE
    - Returns FALSE only when both sides are FALSE
    - Returns UNKNOWN when one side is UNKNOWN and other is FALSE
    
    TRUTH TABLE:
    ┌─────────┬─────────┬─────────┐
    │    A    │    B    │ A OR B  │
    ├─────────┼─────────┼─────────┤
    │  TRUE   │  TRUE   │  TRUE   │
    │  TRUE   │  FALSE  │  TRUE   │
    │  TRUE   │ UNKNOWN │  TRUE   │
    │  FALSE  │  TRUE   │  TRUE   │
    │  FALSE  │  FALSE  │  FALSE  │
    │  FALSE  │ UNKNOWN │ UNKNOWN │
    │ UNKNOWN │  TRUE   │  TRUE   │
    │ UNKNOWN │  FALSE  │ UNKNOWN │
    │ UNKNOWN │ UNKNOWN │ UNKNOWN │
    └─────────┴─────────┴─────────┘
*/

-- Basic OR: Either condition can be true
SELECT 
    FirstName,
    LastName,
    DepartmentID
FROM Employee
WHERE DepartmentID = 1  -- IT department
   OR DepartmentID = 2;  -- OR HR department
GO

-- This is equivalent to IN (cleaner syntax)
SELECT 
    FirstName,
    LastName,
    DepartmentID
FROM Employee
WHERE DepartmentID IN (1, 2);  -- IT or HR
GO

-- Multiple OR conditions
SELECT 
    ProductName,
    Category,
    UnitPrice
FROM Product
WHERE Category = 'Electronics'
   OR Category = 'Furniture'
   OR Category = 'Office Supplies';
GO

-- OR with different conditions
SELECT 
    FirstName,
    LastName,
    Salary,
    HireDate
FROM Employee
WHERE Salary > 90000                    -- High earners
   OR HireDate < '2017-01-01';          -- OR long-tenured employees
GO


-- ============================================================================
-- SECTION 3: NOT OPERATOR
-- ============================================================================

/*
    NOT OPERATOR:
    
    - Negates (reverses) a condition
    - TRUE becomes FALSE
    - FALSE becomes TRUE
    - UNKNOWN stays UNKNOWN (!important)
    
    TRUTH TABLE:
    ┌─────────┬─────────┐
    │    A    │  NOT A  │
    ├─────────┼─────────┤
    │  TRUE   │  FALSE  │
    │  FALSE  │  TRUE   │
    │ UNKNOWN │ UNKNOWN │
    └─────────┴─────────┘
*/

-- NOT with comparison
SELECT FirstName, LastName, DepartmentID
FROM Employee
WHERE NOT DepartmentID = 1;  -- Not in IT
-- Equivalent to: WHERE DepartmentID <> 1
GO

-- NOT with IN
SELECT FirstName, LastName, DepartmentID
FROM Employee
WHERE DepartmentID NOT IN (1, 2, 3);  -- Not IT, HR, or Finance
GO

-- NOT with LIKE
SELECT FirstName, LastName, Email
FROM Employee
WHERE Email NOT LIKE '%@company.com';  -- External email
GO

-- NOT with BETWEEN
SELECT ProductName, UnitPrice
FROM Product
WHERE UnitPrice NOT BETWEEN 50 AND 200;  -- Budget or premium
GO

-- NOT with NULL (⚠️ Important!)
-- NOT UNKNOWN = UNKNOWN (not TRUE!)
SELECT FirstName, LastName, Salary
FROM Employee
WHERE NOT (Salary IS NULL);  -- Same as IS NOT NULL

-- This is different from NOT Salary = NULL (which always returns empty)
SELECT FirstName, LastName, Salary
FROM Employee
WHERE Salary IS NOT NULL;  -- Preferred syntax
GO

-- NOT with EXISTS (preview - covered in Module 05)
/*
SELECT * FROM Department d
WHERE NOT EXISTS (
    SELECT 1 FROM Employee e WHERE e.DepartmentID = d.DepartmentID
);
*/


-- ============================================================================
-- SECTION 4: OPERATOR PRECEDENCE
-- ============================================================================

/*
    OPERATOR PRECEDENCE (highest to lowest):
    
    1. () Parentheses - evaluated first
    2. NOT
    3. AND
    4. OR - evaluated last
    
    ⚠️ CRITICAL: AND is evaluated BEFORE OR!
    
    This causes many bugs when developers assume left-to-right evaluation.
*/

-- Example: Precedence problem
-- Find products that are: (Electronics OR Furniture) AND (Price > 100)

-- ❌ WRONG: Without parentheses, AND binds first
SELECT ProductName, Category, UnitPrice
FROM Product
WHERE Category = 'Electronics' OR Category = 'Furniture' AND UnitPrice > 100;
-- This is evaluated as: Electronics OR (Furniture AND Price > 100)
-- Returns: ALL Electronics, plus Furniture over $100
GO

-- ✅ CORRECT: With parentheses for intended logic
SELECT ProductName, Category, UnitPrice
FROM Product
WHERE (Category = 'Electronics' OR Category = 'Furniture') AND UnitPrice > 100;
-- Returns: Electronics or Furniture, but only those over $100
GO

-- Another example of precedence issue
-- Find employees: In IT with high salary, OR in HR (any salary)

-- This works as intended (AND before OR)
SELECT FirstName, LastName, DepartmentID, Salary
FROM Employee
WHERE DepartmentID = 1 AND Salary > 80000  -- IT with high salary
   OR DepartmentID = 2;                     -- OR any HR
GO

-- But if we wanted: In IT or HR, with high salary
-- We need parentheses:
SELECT FirstName, LastName, DepartmentID, Salary
FROM Employee
WHERE (DepartmentID = 1 OR DepartmentID = 2)  -- IT or HR
  AND Salary > 70000;                          -- AND high salary
GO


-- ============================================================================
-- SECTION 5: COMBINING OPERATORS (Complex Conditions)
-- ============================================================================

/*
    BEST PRACTICES FOR COMPLEX CONDITIONS:
    
    1. Always use parentheses for clarity
    2. Break complex conditions into multiple lines
    3. Add comments explaining business logic
    4. Consider using CTEs for very complex filters
*/

-- Complex business rule:
-- Find employees who are:
--   (Senior developers in IT with salary > 80k)
--   OR
--   (Any employee in HR or Finance with 5+ years tenure)

SELECT 
    FirstName,
    LastName,
    DepartmentID,
    Salary,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsEmployed
FROM Employee
WHERE 
    -- Condition 1: Senior IT developers
    (DepartmentID = 1 AND Salary > 80000)
    OR
    -- Condition 2: Long-tenured HR/Finance employees
    (DepartmentID IN (2, 3) AND DATEDIFF(YEAR, HireDate, GETDATE()) >= 5);
GO

-- Another complex example:
-- Active products that are either:
--   1. Electronics with price between 100-500 and has discount
--   2. Furniture with price > 300
--   3. Any category with price < 25 (budget items)

SELECT 
    ProductName,
    Category,
    UnitPrice,
    DiscountPercent,
    IsActive
FROM Product
WHERE IsActive = 1  -- Must be active
  AND (
      -- Electronics with discount
      (Category = 'Electronics' AND UnitPrice BETWEEN 100 AND 500 AND DiscountPercent > 0)
      OR
      -- Premium furniture
      (Category = 'Furniture' AND UnitPrice > 300)
      OR
      -- Budget items (any category)
      (UnitPrice < 25)
  );
GO

-- NOT with complex conditions
SELECT 
    FirstName,
    LastName,
    DepartmentID,
    Salary
FROM Employee
WHERE NOT (
    -- Exclude: IT employees earning less than 70k
    DepartmentID = 1 AND Salary < 70000
);
GO
