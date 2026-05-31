using logistics.fleet as lf from '../db/schema';

service LogisticsService {

  entity Vehicles       as projection on lf.Vehicles;
  entity Drivers        as projection on lf.Drivers;
  entity Customers      as projection on lf.Customers;
  entity Shipments      as projection on lf.Shipments;
  entity Routes         as projection on lf.Routes;
  entity ServiceRecords as projection on lf.ServiceRecords;

}