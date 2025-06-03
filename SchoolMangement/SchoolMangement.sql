CREATE TABLE Student (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL
);

ALTER TABLE Student
ADD Gender VARCHAR(10);

CREATE TABLE Course (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseName NVARCHAR(100) NOT NULL
);

ALTER TABLE Course
ADD CourseCode NVARCHAR(20);

CREATE TABLE Subject (
    SubjectID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

ALTER TABLE Subject
ADD SubjectCode NVARCHAR(20);


CREATE TABLE Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
);
ALTER TABLE Department
ADD DepartmentHead NVARCHAR(100);


CREATE TABLE Teacher (
    TeacherID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    DepartmentId INT NOT NULL,
    CONSTRAINT FK_Teacher_Department_DepartmentId FOREIGN KEY (DepartmentId)
        REFERENCES Department(DepartmentID)
);

CREATE TABLE CourseEnrollment (
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    CONSTRAINT FK_CourseEnrollment_Student_StudentID FOREIGN KEY (StudentID)
        REFERENCES Student(StudentID),
    CONSTRAINT FK_CourseEnrollment_Course_CourseID FOREIGN KEY (CourseID)
        REFERENCES Course(CourseID)
);

ALTER TABLE CourseEnrollment
ADD EnrollmentDate DATE NOT NULL DEFAULT GETDATE();


CREATE TABLE SubjectCourse (
    SubjectCourseID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectID INT NOT NULL,
    CourseID INT NOT NULL,
    IsMandatory BIT NOT NULL,
    Semester INT NOT NULL,
    CONSTRAINT FK_SubjectCourse_Subject_SubjectID FOREIGN KEY (SubjectID)
        REFERENCES Subject(SubjectID),
    CONSTRAINT FK_SubjectCourse_Course_CourseID FOREIGN KEY (CourseID)
        REFERENCES Course(CourseID)
);

CREATE TABLE TeacherSubject (
    TeacherSubjectID INT IDENTITY(1,1) PRIMARY KEY,
    TeacherID INT NOT NULL,
    SubjectID INT NOT NULL,
    CONSTRAINT FK_TeacherSubject_Teacher_TeacherID FOREIGN KEY (TeacherID)
        REFERENCES Teacher(TeacherID),
    CONSTRAINT FK_TeacherSubject_Subject_SubjectID FOREIGN KEY (SubjectID)
        REFERENCES Subject(SubjectID)
);

CREATE TABLE StudentFeeSummary (
    StudentID INT PRIMARY KEY,
    TotalFeeAmount DECIMAL(10,2) NOT NULL,
    TotalPaidAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    OutstandingAmount AS (TotalFeeAmount - TotalPaidAmount) PERSISTED,--computed coloumn
    LastUpdated DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_StudentFeeSummary_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

CREATE TABLE StudentFeePayment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod = 'Cash' OR PaymentMethod='Online' OR PaymentMethod = 'UPI'),
    Remarks NVARCHAR(255),
    CONSTRAINT FK_StudentFeePayment_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

CREATE TABLE StudentContact (
    ContactID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    GuardianName NVARCHAR(100),
    GuardianPhone NVARCHAR(20),
    CONSTRAINT FK_StudentContact_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

SELECT 
    name AS ConstraintName
FROM 
    sys.key_constraints
WHERE 
    type = 'PK' AND
    OBJECT_NAME(parent_object_id) = 'StudentContact';

ALTER TABLE StudentContact
DROP CONSTRAINT PK__StudentC__5C6625BB12DEB753;

ALTER TABLE StudentContact
DROP COLUMN ContactID;

ALTER Table StudentContact
ADD CONSTRAINT PK_StudentContact PRIMARY KEY (StudentID);


ALTER TABLE SubjectCourse
DROP COLUMN Semester;

EXEC sp_rename 'StudentMarks.EnrollemntID', 'EnrollemntID', 'COLUMN';


--log table
CREATE TABLE StudentContactLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    OldPhone NVARCHAR(20),
    NewPhone NVARCHAR(20),
    OldEmail NVARCHAR(100),
    NewEmail NVARCHAR(100),
    OldAddress NVARCHAR(255),
    NewAddress NVARCHAR(255),
    ChangeDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_StudentContactLog_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

ALTER TABLE CourseEnrollment
ADD CONSTRAINT UQ_CourseEnrollment_Student_Course UNIQUE (StudentID, CourseID);

ALTER TABLE SubjectCourse
ADD CONSTRAINT UQ_SubjectCourse_Subject_Course UNIQUE (SubjectID, CourseID);

ALTER TABLE TeacherSubject
ADD CONSTRAINT UQ_TeacherSubject_Teacher_Subject UNIQUE (TeacherID, SubjectID);

CREATE TABLE TeacherContact (
    TeacherID INT PRIMARY KEY,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(255),
    EmergencyContact VARCHAR(100),
    CONSTRAINT FK_TeacherContact_Teacher 
        FOREIGN KEY (TeacherID) REFERENCES Teacher(TeacherID)
);

CREATE TABLE TeacherSalaryPayment (
    SalaryID INT IDENTITY(1,1) PRIMARY KEY,
    TeacherID INT,
    SalaryMonth VARCHAR(7), -- Format: 'YYYY-MM' (e.g., '2025-06')
    PaymentDate DATE,
    AmountPaid DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    Remarks VARCHAR(255),
    CONSTRAINT FK_TeacherSalaryPayment_Teacher
        FOREIGN KEY (TeacherID) REFERENCES Teacher(TeacherID)
);

-- Benefit master table
CREATE TABLE Benefit (
    BenefitID INT IDENTITY(1,1) PRIMARY KEY,
    BenefitName VARCHAR(100) NOT NULL,
    Description VARCHAR(255)
);

-- Junction table for many-to-many: Teacher <-> Benefit
CREATE TABLE TeacherBenefit (
    TeacherID INT,
    BenefitID INT,
    GrantedDate DATE,
    Remarks VARCHAR(255),
    PRIMARY KEY (TeacherID, BenefitID),
    CONSTRAINT FK_TeacherBenefit_Teacher FOREIGN KEY (TeacherID) REFERENCES Teacher(TeacherID),
    CONSTRAINT FK_TeacherBenefit_Benefit FOREIGN KEY (BenefitID) REFERENCES Benefit(BenefitID)
);

