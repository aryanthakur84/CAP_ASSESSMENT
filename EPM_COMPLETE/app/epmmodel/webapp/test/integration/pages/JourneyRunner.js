sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"epmmodel/test/integration/pages/ProductCatalogList",
	"epmmodel/test/integration/pages/ProductCatalogObjectPage"
], function (JourneyRunner, ProductCatalogList, ProductCatalogObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('epmmodel') + '/test/flp.html#app-preview',
        pages: {
			onTheProductCatalogList: ProductCatalogList,
			onTheProductCatalogObjectPage: ProductCatalogObjectPage
        },
        async: true
    });

    return runner;
});

