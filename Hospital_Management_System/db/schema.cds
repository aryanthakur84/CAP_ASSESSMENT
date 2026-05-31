namespace hospital.management;

using { cuid } from '@sap/cds/common';

type Name        : String(100);
type Phone       : String(15);
type Email       : String(100);
type Amount      : Decimal(10,2);
type MedicalNote : String(500);

type Gender : String(10) enum {
  Male; Female; Other;
}

type BloodGroup : String(5) enum {
  APos = 'A+'; ANeg = 'A-';
  BPos = 'B+'; BNeg = 'B-';
  OPos = 'O+'; ONeg = 'O-';
  ABPos = 'AB+'; ABNeg = 'AB-';
}

type AppointmentStatus : String(15) enum {
  Scheduled; Completed; Cancelled; NoShow;
}

entity Departments : cuid {
  name     : Name;
  floor    : Integer;
  head     : Name;
  capacity : Integer;
  phone    : Phone;
  isActive : Boolean default true;
}

entity Doctors : cuid {
  firstName      : Name;
  lastName       : Name;
  specialization : String(100);
  qualification  : String(100);
  experience     : Integer;
  fee            : Amount;
  department     : Association to Departments;
  phone          : Phone;
  email          : Email;
  availableDays  : String(50);
  isActive       : Boolean default true;
}

entity Patients : cuid {
  firstName        : Name;
  lastName         : Name;
  dateOfBirth      : Date;
  gender           : Gender;
  bloodGroup       : BloodGroup;
  phone            : Phone;
  email            : Email;
  address          : String(255);
  emergencyContact : Phone;
  registrationDate : Date;
}

entity Appointments : cuid {
  patient         : Association to Patients;
  doctor          : Association to Doctors;
  appointmentDate : Date;
  appointmentTime : Time;
  status          : AppointmentStatus default 'Scheduled';
  reason          : String(255);
  notes           : MedicalNote;
  fee             : Amount;
}

entity MedicalRecords : cuid {
  patient         : Association to Patients;
  doctor          : Association to Doctors;
  appointment     : Association to Appointments;
  diagnosis       : MedicalNote;
  prescription    : MedicalNote;
  testRecommended : String(255);
  recordDate      : Date;
}