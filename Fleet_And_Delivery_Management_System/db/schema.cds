namespace logistics.fleet;

using { cuid } from '@sap/cds/common';

type Phone   : String(15);
type Email   : String(100);
type Amount  : Decimal(10,2);
type Distance: Decimal(8,2);
type City    : String(100);
type Address : String(255);
type Rating  : Decimal(2,1);

type VehicleType : String(10) enum {
  Bike; Van; Truck; Trailer;
}

type FuelType : String(10) enum {
  Petrol; Diesel; Electric; CNG;
}

type VehicleStatus : String(15) enum {
  Available; OnTrip; Maintenance; Retired;
}

type DriverStatus : String(15) enum {
  Available; OnTrip; OnLeave;
}

type ShipmentStatus : String(20) enum {
  Booked; PickedUp; InTransit; OutForDelivery; Delivered; Failed;
}

type PaymentStatus : String(10) enum {
  Pending; Paid; COD;
}

type CustomerTier : String(15) enum {
  Regular; Premium; Enterprise;
}

entity Vehicles : cuid {
  registrationNumber : String(20);
  type               : VehicleType;
  make               : String(50);
  model              : String(50);
  year               : Integer;
  capacity           : Decimal(8,2);
  fuelType           : FuelType;
  status             : VehicleStatus default 'Available';
  lastServiceDate    : Date;
  mileage            : Decimal(10,2);
  insuranceExpiry    : Date;
}

entity Drivers : cuid {
  name           : String(100);
  licenseNumber  : String(20);
  licenseExpiry  : Date;
  phone          : Phone;
  email          : Email;
  experience     : Integer;
  rating         : Rating;
  status         : DriverStatus default 'Available';
  vehicle        : Association to Vehicles;
  joinDate       : Date;
}

entity Customers : cuid {
  name       : String(100);
  company    : String(100);
  phone      : Phone;
  email      : Email;
  address    : Address;
  city       : City;
  pincode    : String(10);
  gstNumber  : String(20);
  tier       : CustomerTier default 'Regular';
}

entity Shipments : cuid {
  trackingNumber    : String(20);
  customer          : Association to Customers;
  driver            : Association to Drivers;
  vehicle           : Association to Vehicles;
  pickupAddress     : Address;
  deliveryAddress   : Address;
  pickupCity        : City;
  deliveryCity      : City;
  weight            : Decimal(8,2);
  status            : ShipmentStatus default 'Booked';
  bookedAt          : DateTime;
  pickedUpAt        : DateTime;
  deliveredAt       : DateTime;
  estimatedDelivery : Date;
  actualDistance    : Distance;
  charges           : Amount;
  paymentStatus     : PaymentStatus default 'Pending';
}

entity Routes : cuid {
  fromCity       : City;
  toCity         : City;
  distance       : Distance;
  estimatedHours : Decimal(5,2);
  tollCharges    : Amount;
  isActive       : Boolean default true;
}

entity ServiceRecords : cuid {
  vehicle         : Association to Vehicles;
  serviceDate     : Date;
  serviceType     : String(15) enum { Regular; Repair; Accident; };
  cost            : Amount;
  description     : String(500);
  nextServiceDate : Date;
}