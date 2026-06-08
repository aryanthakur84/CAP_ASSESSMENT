using { com.epm as epm } from '../db/schema';

using {
    ProductCatalog as PC,
    OrderReport as OR,
    LowStockAlert as LS
} from '../db/views';

service SalesService {

    entity Products as projection on epm.Products;

    entity Customers as projection on epm.Customers;

    entity SalesOrders as projection on epm.SalesOrders actions {

        action confirm()
        returns {
            status  : String;
            message : String;
        };

        action cancel(
            reason : String(500)
        )
        returns {
            status  : String;
            message : String;
        };

        action ship(
            trackingNumber : String(50),
            carrier        : String(50)
        )
        returns {
            status  : String;
            message : String;
        };
    };
}

service AdminService {

    entity Suppliers as projection on epm.Suppliers;

    entity Categories as projection on epm.Categories;

    entity Products as projection on epm.Products;

    entity Customers as projection on epm.Customers;

    entity SalesOrders as projection on epm.SalesOrders;

    entity PurchaseOrders as projection on epm.PurchaseOrders;
}

service ReportService {

    entity ProductCatalog as projection on PC;

    entity OrderReport as projection on OR;

    entity LowStockAlert as projection on LS;
}