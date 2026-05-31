namespace platform.events;

using { cuid } from '@sap/cds/common';

type Email  : String(100);
type Phone  : String(15);
type Amount : Decimal(10,2);
type Rating : Decimal(2,1);
type Name   : String(100);
type URL    : String(255);

type VenueType : String(20) enum {
  Auditorium; ConferenceHall; Outdoor; Virtual;
}

type EventType : String(15) enum {
  Conference; Workshop; Seminar; Webinar; Meetup;
}

type EventStatus : String(15) enum {
  Draft; Published; Ongoing; Completed; Cancelled;
}

type TicketType : String(10) enum {
  General; VIP; Student;
}

type RegistrationStatus : String(15) enum {
  Confirmed; Cancelled; Waitlisted; Attended;
}

entity Venues : cuid {
  name          : Name;
  address       : String(255);
  city          : String(100);
  capacity      : Integer;
  type          : VenueType;
  amenities     : String(500);
  hourlyRate    : Amount;
  contactPerson : Name;
  phone         : Phone;
  isActive      : Boolean default true;
}

entity Events : cuid {
  title           : String(200);
  description     : String(1000);
  eventType       : EventType;
  venue           : Association to Venues;
  startDate       : Date;
  endDate         : Date;
  startTime       : Time;
  endTime         : Time;
  maxAttendees    : Integer;
  registeredCount : Integer default 0;
  ticketPrice     : Amount;
  status          : EventStatus default 'Draft';
  organizerName   : Name;
  organizerEmail  : Email;
  tags            : String(500);
}

entity Speakers : cuid {
  name        : Name;
  email       : Email;
  phone       : Phone;
  bio         : String(1000);
  company     : String(100);
  designation : String(100);
  expertise   : String(500);
  photoUrl    : URL;
  rating      : Rating;
  totalTalks  : Integer;
  isActive    : Boolean default true;
}

entity EventSpeakers {
  key event           : Association to Events;
  key speaker         : Association to Speakers;
  topic           : String(200);
  sessionTime     : Time;
  sessionDuration : Integer;
  roomNumber      : String(20);
}

entity Registrations : cuid {
  event            : Association to Events;
  attendeeName     : Name;
  attendeeEmail    : Email;
  attendeePhone    : Phone;
  company          : String(100);
  ticketType       : TicketType;
  registrationDate : Date;
  status           : RegistrationStatus default 'Confirmed';
  amountPaid       : Amount;
  paymentId        : String(50);
}

entity Feedback : cuid {
  event         : Association to Events;
  attendeeEmail : Email;
  overallRating : Rating;
  contentRating : Rating;
  venueRating   : Rating;
  speakerRating : Rating;
  comment       : String(1000);
  submittedAt   : DateTime;
}