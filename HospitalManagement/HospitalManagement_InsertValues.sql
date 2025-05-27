--Use Database
USE HospitalManagement;

-- Insert into Doctor
INSERT INTO Doctor (DoctorName, Specialization, Phone, Email, ExperienceYears, Gender)
VALUES 
('Dr. Alice Smith', 'Cardiology', '1234567890', 'alice.smith@hospital.com', 10, 'F'),
('Dr. John Doe', 'Neurology', '0987654321', 'john.doe@hospital.com', 8, 'M'),
('Dr. Emma Watson', 'Orthopedics', '1112223333', 'emma.watson@hospital.com', 5, 'F'),
('Dr. Mike Brown', 'Pediatrics', '4445556666', 'mike.brown@hospital.com', 12, 'M');

-- Insert into Patient
INSERT INTO Patient (PatientName, DateOfBirth, Gender, Phone)
VALUES
('Tom Hardy', '1990-05-21', 'M', '9998887777'),
('Jane Foster', '1985-03-15', 'F', '8887776666'),
('Robert Miles', '1978-11-30', 'M', '7776665555'),
('Lucy Gray', '2002-07-18', 'F', '6665554444');

-- Insert into DiseaseCategory
INSERT INTO DiseaseCategory (CategoryName)
VALUES 
('Infectious Diseases'),
('Chronic Diseases'),
('Genetic Disorders'),
('Mental Health');

-- Insert into Disease
INSERT INTO Disease (DiseaseName, CategoryID)
VALUES
('Flu', 1),
('Diabetes', 2),
('Down Syndrome', 3),
('Depression', 4);

-- Insert into Appointment
INSERT INTO Appointment (DoctorID, PatientID, AppointmentDate)
VALUES
(100, 1, '2025-05-01 10:00:00'),
(101, 2, '2025-05-02 11:00:00'),
(102, 3, '2025-05-03 12:00:00'),
(103, 4, '2025-05-04 09:30:00');

-- Insert into PatientDisease
INSERT INTO PatientDisease (PatientID, DiseaseID)
VALUES
(1, 1000),
(2, 1001),
(3, 1002),
(4, 1003);

-- Insert into Room
INSERT INTO Room (RoomNumber, RoomType, Availability)
VALUES
('101A', 'General', 1),
('102B', 'Private', 0),
('103C', 'ICU', 1),
('104D', 'Semi-Private', 1);

-- Insert into Admission
INSERT INTO Admission (PatientID, RoomID, DoctorID, AdmissionDate, DischargeDate)
VALUES
(1, 1, 100, '2025-04-20 14:00:00', '2025-04-25 11:00:00'),
(2, 2, 101, '2025-04-22 10:00:00', '2025-04-28 09:00:00'),
(3, 3, 102, '2025-04-24 16:00:00', NULL),
(4, 4, 103, '2025-04-26 08:00:00', NULL);

-- View all Doctors
SELECT * FROM Doctor;

-- View all Patients
SELECT * FROM Patient;

-- View all Disease Categories
SELECT * FROM DiseaseCategory;

-- View all Diseases
SELECT * FROM Disease;

-- View all Appointments
SELECT * FROM Appointment;

-- View all Patient-Disease mappings
SELECT * FROM PatientDisease;

-- View all Rooms
SELECT * FROM Room;

-- View all Admissions
SELECT * FROM Admission;
