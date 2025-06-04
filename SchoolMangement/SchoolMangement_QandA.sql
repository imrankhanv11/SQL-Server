--show the each student enroled course and the subject they have with who take the subject and which the deparment the teacher represent
SELECT
    s.StudentName,
    c.CourseName,
    subj.Name AS SubjectName,
    t.Name AS TeacherName,
    d.DepartmentName
FROM Student s
JOIN CourseEnrollment ce ON s.StudentID = ce.StudentID
JOIN Course c ON ce.CourseID = c.CourseID
JOIN SubjectCourse sc ON c.CourseID = sc.CourseID
JOIN Subject subj ON sc.SubjectID = subj.SubjectID
JOIN TeacherSubject ts ON subj.SubjectID = ts.SubjectID
JOIN Teacher t ON ts.TeacherID = t.TeacherID
JOIN Department d ON t.DepartmentId = d.DepartmentID
ORDER BY s.StudentName, subj.Name;

--with marks
SELECT 
    s.StudentName,
    c.CourseName,
    subj.Name AS SubjectName,
    sm.Marks
FROM 
    Student s
JOIN 
    CourseEnrollment ce ON s.StudentID = ce.StudentID
JOIN 
    Course c ON ce.CourseID = c.CourseID
JOIN 
    StudentMarks sm ON ce.EnrollmentID = sm.EnrollemntID
JOIN 
    SubjectCourse sc ON sm.SubjectCourseID = sc.SubjectCourseID
JOIN 
    Subject subj ON sc.SubjectID = subj.SubjectID;

--------------------------------------------------------------------------------------

SELECT 
    st.StudentName,
    c.CourseName,
    s.Name AS SubjectName,
    t.Name AS TeacherName,
    d.DepartmentName
FROM SubjectCourse sc
JOIN Subject s ON sc.SubjectID = s.SubjectID
JOIN Course c ON sc.CourseID = c.CourseID
JOIN Teacher t ON sc.TeacherID = t.TeacherID
JOIN Department d ON t.DepartmentID = d.DepartmentID
JOIN CourseEnrollment ce ON c.CourseID = ce.CourseID
JOIN Student st ON ce.StudentID = st.StudentID
ORDER BY c.CourseName, st.StudentName;
