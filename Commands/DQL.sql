--Select (Select all Coloum)
SELECT *
FROM Employee;

--Select (Select Particular Coloum)
SELECT EmployeeID, Department, Salary
FROM Employee;

--Select (Select With Where Condition)
SELECT *
FROM Employee
WHERE Salary < 50000;

--select (select with OrderBy)
--Run only after adding Age Coloum
SELECT *
FROM Employee
ORDER BY Age DESC;
