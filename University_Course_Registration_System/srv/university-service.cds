using edu.university as eu from '../db/schema';

service UniversityService {

  entity Departments  as projection on eu.Departments;
  entity Professors   as projection on eu.Professors;
  entity Courses      as projection on eu.Courses;
  entity Students     as projection on eu.Students;
  entity Enrollments  as projection on eu.Enrollments;
  entity Exams        as projection on eu.Exams;

}