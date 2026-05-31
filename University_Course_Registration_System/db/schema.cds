namespace edu.university;

using { cuid } from '@sap/cds/common';

// Reusable Types
type Email      : String(100);
type Phone      : String(15);
type Percentage : Decimal(5,2);
type GradePoint : Decimal(3,2);
type Semester   : Integer;

// Enums
type Designation : String(20) enum {
  Assistant; Associate; Full; Distinguished;
}

type EnrollmentStatus : String(15) enum {
  Enrolled; Dropped; Completed;
}

type Grade : String(2) enum {
  A; B; C; D; F;
}

type ExamType : String(15) enum {
  Midterm; Final; Quiz; Assignment;
}

// Departments
entity Departments {
  key code            : String(10);
  name                : String(100);
  building            : String(50);
  headProfessor       : String(100);
  establishedYear     : Integer;
}

// Professors
entity Professors : cuid {
  firstName      : String(50);
  lastName       : String(50);
  email          : Email;
  phone          : Phone;
  department     : Association to Departments;
  designation    : Designation;
  joinDate       : Date;
  salary         : Decimal(10,2);
  officeRoom     : String(20);
}

// Courses
entity Courses {
  key code           : String(10);
  title              : String(100);
  description        : String(500);
  credits            : Integer;
  maxStudents        : Integer;
  currentEnrolled    : Integer default 0;
  semester           : Semester;
  department         : Association to Departments;
  professor          : Association to Professors;
  schedule           : String(50);
  roomNumber         : String(20);
  isActive           : Boolean default true;
}

// Students
entity Students : cuid {
  rollNumber       : String(20);
  firstName        : String(50);
  lastName         : String(50);
  email            : Email;
  phone            : Phone;
  dateOfBirth      : Date;
  admissionYear    : Integer;
  currentSemester  : Semester;
  cgpa             : GradePoint;
  department       : Association to Departments;
  isActive         : Boolean default true;
}

// Enrollments - Composite Key
entity Enrollments {
  key student          : Association to Students;
  key course           : Association to Courses;
  enrollmentDate       : Date;
  status               : EnrollmentStatus default 'Enrolled';
  grade                : Grade;
  gradePoints          : GradePoint;
  attendancePercent    : Percentage;
}

// Exams
entity Exams : cuid {
  course           : Association to Courses;
  examType         : ExamType;
  date             : Date;
  maxMarks         : Integer;
  weightagePercent : Percentage;
}