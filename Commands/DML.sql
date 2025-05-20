--1. Insert Values (Multiple Rows)
INSERT INTO Employee (EmployeeID, Name, Department, Salary)
VALUES
(1, 'Imran', 'Software', 50000),
(2, 'San', 'Software', 50000),
(3, 'Karthik', 'Finance', 50000),
(4, 'Gokul', 'Testing', 50000),
(5, 'Rishi', 'HR', 50000);

--Insert Values (Single Row)
INSERT INTO Employee (EmployeeID, Name, Department, Salary)
VALUES (6, 'Hari', 'HR', 45000);

--Insert Values (must match column order exactly: EmployeeID, Name, Department, Salary, Age If can't give Coloum name)
--Run only after add the Age coloum
INSERT INTO Employee
VALUES 
(7, 'Anil', 'Finance', 60000,22),
(8, 'Divya', 'Software', 58000,23);

--------------------------------------

--2.Update (Update Single Value)
UPDATE Employee
SET Name = 'Santhosh'
WHERE EmployeeID=7;

--Update (Update Multiple Values)
UPDATE Employee
SET Age = CASE 
    WHEN EmployeeID = 1 THEN 23
    WHEN EmployeeID = 2 THEN 29
	WHEN EmployeeID = 3 THEN 32
	WHEN EmployeeID = 4 THEN 45
	WHEN EmployeeID = 5 THEN 25
	WHEN EmployeeID = 6 THEN 26
    ELSE Age
END;

--------------------------------------

--3.Delete (Delete a Row)
DELETE
FROM Employee
WHERE EmployeeID=8;




