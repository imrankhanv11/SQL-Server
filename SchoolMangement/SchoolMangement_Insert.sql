-- Insert into Student
INSERT INTO Student (StudentName, DOB) VALUES
('Arun Kumar', '2003-04-15'),
('Divya Lakshmi', '2002-11-23'),
('Karthik Raj', '2004-01-12'),
('Meena Rani', '2003-07-07');

-- Insert into Course (Shortened names)
INSERT INTO Course (CourseName) VALUES
('B.Sc CS'),
('B.Com'),
('B.A Tamil'),
('B.E Mech');

-- Insert into Subject
INSERT INTO Subject (Name) VALUES
('DS'),
('Accounts'),
('Sangam Lit'),
('Thermo');

-- Insert into Department (Shortened names)
INSERT INTO Department (DepartmentName) VALUES
('CS'),
('Commerce'),
('Tamil'),
('Mech Engg');

-- Insert into Teacher (Assuming DeptIDs 1-4)
INSERT INTO Teacher (Name, DepartmentId) VALUES
('Dr. Ramanujam', 1),
('Ms. Vasanthi', 2),
('Mr. Ilango', 3),
('Dr. Subramani', 4);

-- Insert into CourseEnrollment (Assuming StudentIDs and CourseIDs are 1-4)
INSERT INTO CourseEnrollment (StudentID, CourseID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

-- Insert into SubjectCourse (Assuming SubjectIDs and CourseIDs are 1-4)
INSERT INTO SubjectCourse (SubjectID, CourseID, IsMandatory, Semester) VALUES
(1, 1, 1, 1),
(2, 2, 1, 1),
(3, 3, 1, 1),
(4, 4, 1, 1);

-- Insert into TeacherSubject (Assuming TeacherIDs and SubjectIDs are 1-4)
INSERT INTO TeacherSubject (TeacherID, SubjectID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

INSERT INTO StudentFeeSummary (StudentID, TotalFeeAmount, TotalPaidAmount)
VALUES
(1, 50000.00, 15000.00),
(2, 50000.00, 25000.00), 
(3, 50000.00, 50000.00), 
(4, 50000.00, 10000.00); 

-- Arun Kumar (StudentID = 1)
INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks)
VALUES
(1, '2025-01-15', 10000.00, 'Cash', 'Initial payment'),
(1, '2025-03-10', 5000.00, 'UPI', 'Second installment');

-- Divya Lakshmi (StudentID = 2)
INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks)
VALUES
(2, '2025-01-20', 15000.00, 'Online', '1st payment'),
(2, '2025-04-01', 10000.00, 'Cash', 'Partial fee');

-- Karthik Raj (StudentID = 3)
INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks)
VALUES
(3, '2025-01-25', 50000.00, 'Cash', 'Full payment');

-- Meena Rani (StudentID = 4)
INSERT INTO StudentFeePayment (StudentID, PaymentDate, AmountPaid, PaymentMethod, Remarks)
VALUES
(4, '2025-02-05', 10000.00, 'UPI', 'Initial payment');

-------------------------------------------------
-- Additional subjects
INSERT INTO Subject (Name) VALUES
('Statistics'),  -- SubjectID = 5
('English');     -- SubjectID = 6

-- Additional department for English
INSERT INTO Department (DepartmentName) VALUES ('English');  -- DepartmentID = 5

-- Additional teachers
INSERT INTO Teacher (Name, DepartmentId) VALUES
('Mr. Ravi', 2),     -- TeacherID = 5 (Commerce)
('Ms. Anitha', 5);   -- TeacherID = 6 (English)

-- Assign Statistics to B.Sc CS and B.Com
INSERT INTO SubjectCourse (SubjectID, CourseID, IsMandatory, Semester) VALUES
(5, 1, 1, 1),
(5, 2, 1, 1);

-- Assign English to all courses
INSERT INTO SubjectCourse (SubjectID, CourseID, IsMandatory, Semester) VALUES
(6, 1, 1, 1),
(6, 2, 1, 1),
(6, 3, 1, 1),
(6, 4, 1, 1);

-- Assign new teachers to subjects
INSERT INTO TeacherSubject (TeacherID, SubjectID) VALUES
(5, 5),  -- Mr. Ravi teaches Statistics
(6, 6);  -- Ms. Anitha teaches English

-- Enroll Arun Kumar (StudentID=1) in B.Com (CourseID=2) as well
INSERT INTO CourseEnrollment (StudentID, CourseID) VALUES
(1, 2);
--------
INSERT INTO StudentContact (StudentID, Phone, Email, Address, GuardianName, GuardianPhone) VALUES
(1, '9876543210', 'arun.kumar@example.com', '123 Main St, Cityville', 'Ravi Kumar', '9876500000'),
(2, '8765432109', 'divya.lakshmi@example.com', '456 Oak Ave, Townsville', 'Lakshmi Devi', '8765400000'),
(3, '7654321098', 'karthik.raj@example.com', '789 Pine Rd, Villagetown', 'Rajesh Kumar', '7654300000'),
(4, '6543210987', 'meena.rani@example.com', '321 Maple St, Hamlet', 'Rani Devi', '6543200000');

--insert
DECLARE @result varchar(40)

EXEC insert_depatment 'AI & DS',@result OUTPUT
PRINT @result;

UPDATE Student
SET Gender = 'Male'
WHERE StudentID = 1;

UPDATE Student
SET Gender = 'Female'
WHERE StudentID = 2;

UPDATE Student
SET Gender = 'Male'
WHERE StudentID = 3;

UPDATE Student
SET Gender = 'Female'
WHERE StudentID = 4;

UPDATE Course SET CourseCode = 'BSC101' WHERE CourseID = 1;
UPDATE Course SET CourseCode = 'BCM102' WHERE CourseID = 2;
UPDATE Course SET CourseCode = 'BAT103' WHERE CourseID = 3;
UPDATE Course SET CourseCode = 'BEM104' WHERE CourseID = 4;

UPDATE Subject SET SubjectCode = 'DS101' WHERE SubjectID = 1;
UPDATE Subject SET SubjectCode = 'ACC102' WHERE SubjectID = 2;
UPDATE Subject SET SubjectCode = 'LIT103' WHERE SubjectID = 3;
UPDATE Subject SET SubjectCode = 'THM104' WHERE SubjectID = 4;
UPDATE Subject SET SubjectCode = 'STA105' WHERE SubjectID = 5;
UPDATE Subject SET SubjectCode = 'ENG106' WHERE SubjectID = 6;

UPDATE Department SET DepartmentHead = 'Dr. Ramanujam' WHERE DepartmentID = 1;
UPDATE Department SET DepartmentHead = 'Ms. Vasanthi' WHERE DepartmentID = 2;
UPDATE Department SET DepartmentHead = 'Mr. Ilango' WHERE DepartmentID = 3;
UPDATE Department SET DepartmentHead = 'Dr. Subramani' WHERE DepartmentID = 4;
UPDATE Department SET DepartmentHead = 'Ms. Anitha' WHERE DepartmentID = 5;

INSERT INTO StudentMarks (SubjectCourseID, EnrollemntID, Marks) VALUES
(1, 1, 87), 
(5, 1, 75), 
(6, 1, 90), 

(2, 2, 81),  
(5, 2, 77),
(7, 2, 85), 

(3, 3, 79),  
(8, 3, 88),  

(4, 4, 83),  
(9, 4, 91),  

(2, 5, 80),  
(5, 5, 78), 
(7, 5, 89);



-- Insert Department
INSERT INTO Department (DepartmentName, DepartmentHead) VALUES ('Computer Science', 'Dr. Smith');

-- Insert Teacher
INSERT INTO Teacher (Name, DepartmentId) VALUES ('Mr. John', 1);

-- Insert Course
INSERT INTO Course (CourseName, CourseCode) VALUES ('BSc CS', 'BSC101');

-- Insert Subject
INSERT INTO Subject (Name, SubjectCode) VALUES ('Data Structures', 'CS201');

-- Insert Student
INSERT INTO Student (StudentName, DOB, Gender) VALUES ('Alice', '2003-05-10', 'Female');

-- Enroll student in course
INSERT INTO CourseEnrollment (StudentID, CourseID) VALUES (1, 1);

-- Link subject to course
INSERT INTO SubjectCourse (SubjectID, CourseID, IsMandatory) VALUES (1, 1, 1);

-- Assign teacher to subject
INSERT INTO TeacherSubject (TeacherID, SubjectID) VALUES (1, 1);


---for test 


----------------------------------------------------------------------------------------------------------
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM Subject;
SELECT * FROM Department;
SELECT * FROM Teacher;
SELECT * FROM CourseEnrollment;
SELECT * FROM SubjectCourse;
SELECT * FROM TeacherSubject;
SELECT * FROM StudentFeeSummary;
SELECT * FROM StudentFeePayment;
SELECT * FROM StudentContact;
SELECT * FROM StudentMarks;












