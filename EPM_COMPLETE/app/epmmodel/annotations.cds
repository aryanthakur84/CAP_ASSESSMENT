using AnalyticsService as service from '../../srv/analytics-service';
annotate service.ProductCatalog with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'name',
                Value : name,
            },
            {
                $Type : 'UI.DataField',
                Label : 'price',
                Value : price,
            },
            {
                $Type : 'UI.DataField',
                Label : 'stock',
                Value : stock,
            },
            {
                $Type : 'UI.DataField',
                Label : 'supplierName',
                Value : supplierName,
            },
            {
                $Type : 'UI.DataField',
                Label : 'categoryName',
                Value : categoryName,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'name',
            Value : name,
        },
        {
            $Type : 'UI.DataField',
            Label : 'price',
            Value : price,
        },
        {
            $Type : 'UI.DataField',
            Label : 'stock',
            Value : stock,
            Criticality : stock,
        },
        {
            $Type : 'UI.DataField',
            Label : 'supplierName',
            Value : supplierName,
        },
        {
            $Type : 'UI.DataField',
            Label : 'categoryName',
            Value : categoryName,
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target : '@UI.DataPoint#rating',
            Label : 'Rating',
        },
    ],
    UI.DataPoint #stock : {
        Value : stock,
        Visualization : #Rating,
        TargetValue : 5,
    },
    UI.DataPoint #rating : {
        Value : rating,
        Visualization : #Rating,
        TargetValue : 5,
    },
    UI.HeaderInfo : {
        Title : {
            $Type : 'UI.DataField',
            Value : name,
        },
        TypeName : '',
        TypeNamePlural : '',
        ImageUrl : name,
        TypeImageUrl : 'sap-icon://account',
    },
    UI.SelectionFields : [
        categoryName,
    ],
);
annotate service.ProductCatalog with {
    categoryName @(
        Common.Label : 'categoryName',
        Common.ValueListWithFixedValues : true,
    )
};
annotate service.ProductCatalog with {
    categoryName @Common.ValueList : {
        $Type          : 'Common.ValueListType',
        CollectionPath : 'Categories',
        Parameters     : [
            {
                $Type             : 'Common.ValueListParameterInOut',
                LocalDataProperty : categoryName,
                ValueListProperty : 'name',
            },
        ],
        Label : 'Category',
    };
}
