using hospital.management as hm from '../db/schema';

service HospitalService {

  entity Departments    as projection on hm.Departments;
  entity Doctors        as projection on hm.Doctors;
  entity Patients       as projection on hm.Patients;
  entity Appointments   as projection on hm.Appointments;
  entity MedicalRecords as projection on hm.MedicalRecords;

}