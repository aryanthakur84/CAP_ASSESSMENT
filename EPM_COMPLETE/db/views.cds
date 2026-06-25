using { com.epm as epm } from './schema';

view ProductCatalog as
select from epm.Products {
    ID,
    name,
    price,
    stock,
    rating,
    supplier.name as supplierName,
    category.name as categoryName
};

view OrderReport as
select from epm.SalesOrders {
    ID,
    orderNumber,
    customer.name as customerName,
    amount,
    orderDate,
    status
};

view LowStockAlert as
select from epm.Products {
    ID,
    name,
    stock,
    minStock,
    supplier.name as supplierName,
    supplier.contact as contact,
    supplier.email as email
}
where stock <= minStock;