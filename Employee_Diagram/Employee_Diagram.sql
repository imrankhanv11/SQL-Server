--CREATE DATABASE
CREATE DATABASE Employee_Diagram;

--USE DATABASE
USE Employee_Diagram;

-- Department Table
CREATE TABLE Department (
    Department_ID INT IDENTITY(1,1) PRIMARY KEY,
    Department_Name NVARCHAR(100) NOT NULL,
    Block_No INT
);

-- Role Table
CREATE TABLE Role (
    Role_ID INT IDENTITY(1,1) PRIMARY KEY,
    Role_Name NVARCHAR(100) NOT NULL
);

-- Employee Table
CREATE TABLE Employee (
    Employee_ID INT IDENTITY(1,1) PRIMARY KEY,
    First_Name NVARCHAR(50) NOT NULL,
    Last_Name NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(15),
    Date_of_Joining DATE,
    Salary DECIMAL(12, 2),
    Department_ID INT,
    Role_ID INT,
    Manager_ID INT,
    CONSTRAINT FK_Employee_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
    CONSTRAINT FK_Employee_Role FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID),
    CONSTRAINT FK_Employee_Manager FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID)
);

-- Project Table
CREATE TABLE Project (
    Project_ID INT IDENTITY(1,1) PRIMARY KEY,
    Project_Name NVARCHAR(100) NOT NULL,
    Start_Date DATE,
    End_Date DATE,
    Budget DECIMAL(14, 2)
);

-- Employee_Project Join Table
CREATE TABLE Employee_Project (
    Employee_ID INT,
    Project_ID INT,
    Assigned_Date DATE,
    Role_in_Project NVARCHAR(100),
    CONSTRAINT PK_Employee_Project PRIMARY KEY (Employee_ID, Project_ID),
    CONSTRAINT FK_Employee_Project_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT FK_Employee_Project_Project FOREIGN KEY (Project_ID) REFERENCES Project(Project_ID)
);


-- Leave_Record Table
CREATE TABLE Leave_Record (
    Leave_ID INT IDENTITY(1,1) PRIMARY KEY,
    Employee_ID INT,
    Start_Date DATE,
    End_Date DATE,
    Type NVARCHAR(50),
    CONSTRAINT FK_Leave_Record_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);


-- Performance_Review Table
CREATE TABLE Performance_Review (
    Review_ID INT IDENTITY(1,1) PRIMARY KEY,
    Employee_ID INT,
    Reviewer_ID INT,
    Review_Date DATE,
    Score INT,
    Comments NVARCHAR(MAX),
    CONSTRAINT FK_Performance_Review_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT FK_Performance_Review_Reviewer FOREIGN KEY (Reviewer_ID) REFERENCES Employee(Employee_ID)
);

--Training Table
CREATE TABLE Training (
    Training_ID INT IDENTITY(1,1) PRIMARY KEY,
    Training_Name NVARCHAR(100) NOT NULL,
    Start_Date DATE,
    End_Date DATE
);

-- Employee_Training Table
CREATE TABLE Employee_Training (
    Employee_ID INT,
    Training_ID INT,
    Completion_Status NVARCHAR(50),
    Completion_Date DATE,
    CONSTRAINT PK_Employee_Training PRIMARY KEY (Employee_ID, Training_ID),
    CONSTRAINT FK_Employee_Training_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT FK_Employee_Training_Training FOREIGN KEY (Training_ID) REFERENCES Training(Training_ID)
);

-- Benefits table
CREATE TABLE Benefits (
    Benefit_ID INT IDENTITY(1,1) PRIMARY KEY,
    Benefit_Name NVARCHAR(100),
    Description NVARCHAR(MAX)
);

-- Benefits for employee table
CREATE TABLE Employee_Benefits (
    Employee_ID INT,
    Benefit_ID INT,
    Enrollment_Date DATE,
    Status NVARCHAR(50), -- e.g., Active, Cancelled
    CONSTRAINT PK_Employee_Benefits PRIMARY KEY (Employee_ID, Benefit_ID),
    CONSTRAINT FK_EB_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT FK_EB_Benefit FOREIGN KEY (Benefit_ID) REFERENCES Benefits(Benefit_ID)
);
