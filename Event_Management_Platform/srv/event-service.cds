using platform.events as pe from '../db/schema';

service EventService {

  entity Venues        as projection on pe.Venues;
  entity Events        as projection on pe.Events;
  entity Speakers      as projection on pe.Speakers;
  entity EventSpeakers as projection on pe.EventSpeakers;
  entity Registrations as projection on pe.Registrations;
  entity Feedback      as projection on pe.Feedback;

}