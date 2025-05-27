--Create Database
CREATE DATABASE HospitalManagement;

--Use Database
USE HospitalManagement;

-- Doctor Table
CREATE TABLE Doctor (
    DoctorID INT IDENTITY(100,1) PRIMARY KEY,
    DoctorName VARCHAR(30),
    Specialization VARCHAR(50),
    Phone VARCHAR(15),
    Email VARCHAR(50),
    ExperienceYears INT,
    Gender CHAR(1)
);

-- Patient Table
CREATE TABLE Patient (
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    PatientName VARCHAR(30),
    DateOfBirth DATE,
    Gender CHAR(1),
    Phone VARCHAR(15)
);

-- Disease Category Table
CREATE TABLE DiseaseCategory (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50)
);

-- Disease Table
CREATE TABLE Disease (
    DiseaseID INT IDENTITY(1000,1) PRIMARY KEY,
    DiseaseName VARCHAR(35),
    CategoryID INT,
    CONSTRAINT FK_Disease_Category FOREIGN KEY (CategoryID) REFERENCES DiseaseCategory(CategoryID)
);

-- Appointment Table (Doctor <-> Patient)
CREATE TABLE Appointment (
    AppointmentID INT IDENTITY(1000,1) PRIMARY KEY,
    DoctorID INT,
    PatientID INT,
    AppointmentDate DATETIME,
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);

-- Patient-Disease Table (Many-to-Many)
CREATE TABLE PatientDisease (
    PatientID INT NOT NULL,
    DiseaseID INT NOT NULL,
    PRIMARY KEY (PatientID, DiseaseID),
    CONSTRAINT FK_PD_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT FK_PD_Disease FOREIGN KEY (DiseaseID) REFERENCES Disease(DiseaseID)
);

-- Room Table
CREATE TABLE Room (
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomNumber VARCHAR(10),
    RoomType VARCHAR(20), 
    Availability BIT
);

-- Admission Table
CREATE TABLE Admission (
    AdmissionID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT,
    RoomID INT,
    DoctorID INT,
    AdmissionDate DATETIME,
    DischargeDate DATETIME,
    CONSTRAINT FK_Admission_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT FK_Admission_Room FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT FK_Admission_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
	);

