using PurchasingService as service from '../../srv/purchasing-service';

annotate service.PurchaseOrders with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : poNumber,
            Label : 'PO Number',
        },
        {
            $Type : 'UI.DataField',
            Value : orderDate,
            Label : 'Order Date',
        },
        {
            $Type : 'UI.DataField',
            Value : status,
            Label : 'Status',
        },
        {
            $Type : 'UI.DataField',
            Value : amount,
            Label : 'Amount',
        },
        
    ],
    
    UI.HeaderInfo : {
        TypeName : 'Purchase Order',
        TypeNamePlural : 'Purchase Orders',
        Title : {
            $Type : 'UI.DataField',
            Value : poNumber,
        },
        ImageUrl : supplier.name,
    },
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : poNumber,
                Label : 'PO Number',
            },
            {
                $Type : 'UI.DataField',
                Value : orderDate,
                Label : 'Order Date',
            },
            {
                $Type : 'UI.DataField',
                Value : expectedDate,
                Label : 'Expected Date',
            },
            {
                $Type : 'UI.DataField',
                Value : status,
                Label : 'Status',
            },
            {
                $Type : 'UI.DataField',
                Value : amount,
                Label : 'Amount',
            },
            {
                $Type : 'UI.DataField',
                Value : notes,
                Label : 'Notes',
            },
            {
                $Type : 'UI.DataField',
                Value : supplier_ID,
                Label : 'Supplier',
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneralInfo',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'Items',
            Label : 'Items',
            Target : 'items/@UI.LineItem',
        },
    ],
    UI.Identification : [
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'PurchasingService.submit',
            Label : 'Submit',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'PurchasingService.approve',
            Label : 'Approve',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'PurchasingService.reject',
            Label : 'Reject',
        },
    ],
    UI.DataPoint #amount : {
        Value : amount,
        Visualization : #Rating,
        TargetValue : 5,
    },
    UI.DataPoint #amount1 : {
        Value : amount,
        Visualization : #Progress,
        TargetValue : 100,
    },
    UI.DataPoint #poNumberEditable : {
        Value : poNumberEditable,
        Visualization : #Progress,
        TargetValue : 100,
    },
    UI.DataPoint #supplierEditable : {
        Value : supplierEditable,
        Visualization : #Progress,
        TargetValue : 100,
    },
);

annotate service.PurchaseOrders with {
    supplier_ID @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Suppliers',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : supplier_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
            ],
            Label : 'Supplier',
        },
    );
    status @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'StatusValues',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : status,
                    ValueListProperty : 'code',
                },
            ],
            Label : 'Status',
        },
        Common.ValueListWithFixedValues : true,
    );
};

annotate service.Suppliers with {
    ID @(
        Common.Text : name,
        Common.Text.@UI.TextArrangement : #TextOnly,
    );
};


annotate service.StatusValues with {
    code @(
        Common.Text : name,
        Common.Text.@UI.TextArrangement : #TextOnly,
    );
};

annotate service.PurchaseOrderItems with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : product_ID,
            Label : 'Product',
        },
        {
            $Type : 'UI.DataField',
            Value : quantity,
            Label : 'Quantity',
        },
        {
            $Type : 'UI.DataField',
            Value : unitPrice,
            Label : 'Unit Price',
        },
    ],
    Common.SideEffects : {
        SourceProperties : ['quantity', 'unitPrice'],
        TargetProperties : ['netAmount']
    },


UI.HeaderInfo : {
        TypeName : 'Item',
        TypeNamePlural : 'Items',
        Title : {
            $Type : 'UI.DataField',
            Value : product.name,
        },
    ImageUrl : product.name,
    },
    UI.FieldGroup #ItemDetails : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : quantity,
                Label : 'Quantity',
            },
            {
                $Type : 'UI.DataField',
                Value : unitPrice,
                Label : 'Unit Price',
            },
            {
                $Type : 'UI.DataField',
                Value : product_ID,
                Label : 'product_ID',
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'ItemDetails',
            Label : 'Item Details',
            Target : '@UI.FieldGroup#ItemDetails',
        },
    ],
);

annotate service.PurchaseOrderItems with {
    product_ID @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Products',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : product_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
            ],
            Label : 'Product',
        },
    );
};

annotate service.Products with {
    ID @(
        Common.Text : name,
        Common.Text.@UI.TextArrangement : #TextOnly,
    );
};

annotate service.PurchaseOrders with @(
    Common.SideEffects#TotalRefresh : {
        SourceEntities : ['items'],
        TargetProperties : ['amount']
    }
);
annotate service.PurchaseOrderItems with {
    product @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Products',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : product_ID,
                    ValueListProperty : 'ID',
                },
            ],
        },
        Common.ValueListWithFixedValues : true,
)};

annotate service.PurchaseOrders with {
    supplier @(
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Suppliers',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : supplier_ID,
                    ValueListProperty : 'ID',
                },
            ],
        },
        Common.ValueListWithFixedValues : true,
)};
annotate service.PurchaseOrders with {
    poNumber @title: 'PO Number';
    status   @title: 'Status';
    amount   @title: 'Total Amount';
    orderDate @title: 'Order Date';
    expectedDate @title: 'Expected Delivery';
    notes    @title: 'Notes' @UI.MultiLineText;
    supplier @title: 'Supplier';
};

annotate service.PurchaseOrders with {
    poNumber @Common.FieldControl: poNumberEditable;
    supplier @Common.FieldControl: supplierEditable;
};
annotate service.PurchaseOrders with {
    status @Common.ValueCriticality #Approved : 3;
    status @Common.ValueCriticality #Pending  : 2;
    status @Common.ValueCriticality #Rejected : 1;
    status @Common.ValueCriticality #Draft    : 0;
};
annotate service.PurchaseOrderItems with {
    quantity @Measures.ISOCurrency : product.currency_code
};

