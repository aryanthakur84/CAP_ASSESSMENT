using { com.epm as epm } from '../db/schema';
using { ProductCatalog as PC } from '../db/views';

service AnalyticsService @(path:'/analytics') {

    action GenerateReport(
        reportType : String(20),
        startDate  : Date,
        endDate    : Date
    ) returns {
        reportId : UUID;
        status   : String(20);
        message  : String(200);
    };

    action PingHealth() returns {
        status    : String(10);
        timestamp : Timestamp;
        version   : String(20);
    };

    @readonly
    entity ProductCatalog as projection on PC;
}