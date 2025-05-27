--Write a SQL query to display all doctor names and their specializations.
SELECT DoctorName, Specialization
FROM Doctor;

--Write a SQL query to show the names of all patients and their phone numbers.
SELECT PatientName, Phone
FROM Patient;

--Write a SQL query to list all diseases along with their associated category names.
SELECT DN.DiseaseName, DC.CategoryName
FROM Disease DN 
JOIN DiseaseCategory DC ON DN.CategoryID=DC.CategoryID;

--Write a SQL query to show the room numbers of all currently available rooms.
SELECT RoomNumber 
FROM Room
WHERE Availability=1;

--Write a SQL query to display all appointments that occurred after May 1st, 2025.
SELECT AppointmentID
FROM Appointment
WHERE AppointmentDate > '2025-05-01';

--Write a query to display a list of appointments with DoctorName, PatientName, and AppointmentDate.
SELECT D.DoctorName, P.PatientName, A.AppointmentDate
FROM Doctor D 
JOIN Appointment A ON D.DoctorID=A.DoctorID
JOIN Patient P ON P.PatientID=A.PatientID;

--Write a query to list all patients along with any diseases they have (show PatientName and DiseaseName).
SELECT P.PatientName, D.DiseaseName
FROM Patient P 
JOIN PatientDisease PD ON P.PatientID=PD.PatientID
JOIN Disease D ON D.DiseaseID=PD.DiseaseID;

--Write a query to show the total number of patients admitted by each doctor (DoctorName and number of admissions).
SELECT D.DoctorName, Count(*) AS [Number of admissions]
FROM Doctor D
JOIN Admission A ON A.DoctorID=D.DoctorID
GROUP BY D.DoctorName;

--Write a query to display admission details including PatientName, DoctorName, RoomNumber, AdmissionDate, and DischargeDate.
SELECT P.PatientName, D.DoctorName, R.RoomNumber, A.AdmissionDate, A.DischargeDate
FROM Admission A
JOIN Patient P ON A.PatientID=P.PatientID
JOIN Doctor D ON A.DoctorID=D.DoctorID
JOIN Room R ON A.RoomID=R.RoomID;

--Write a query to find all patients who have not yet been discharged.
SELECT P.PatientName 
FROM Patient P 
JOIN Admission A ON P.PatientID=A.PatientID
WHERE A.DischargeDate IS NULL;

--Write a query to list all doctors who have had at least one appointment with a patient diagnosed with “Diabetes”.
SELECT D.DoctorName 
FROM Doctor D 
JOIN Appointment A ON D.DoctorID=A.DoctorID
JOIN PatientDisease DS ON DS.PatientID=A.PatientID
JOIN Disease DSS ON DSS.DiseaseID=DS.DiseaseID
WHERE DSS.DiseaseName='Diabetes';

