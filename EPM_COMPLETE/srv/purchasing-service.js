const cds = require('@sap/cds');
const { SELECT, UPDATE } = cds.ql;

module.exports = function () {

// Handler

  this.after('READ', 'PurchaseOrders', (results) => {
    const pos = Array.isArray(results) ? results : [results];
    for (const po of pos) {
        if (po.status === 'Draft') {
            po.poNumberEditable = 7;   // Mandatory/Editable
            po.supplierEditable = 7;   // Mandatory/Editable
        } else {
            po.poNumberEditable = 1;   // ReadOnly
            po.supplierEditable = 1;   // ReadOnly
        }
    }
});

this.after('READ', 'PurchaseOrders', (results) => {
    const pos = Array.isArray(results) ? results : [results];
    for (const po of pos) {
        po.statusPercent = po.status === 'Draft' ? 25 :
                           po.status === 'Pending' ? 50 :
                           po.status === 'Approved' ? 100 :
                           po.status === 'Rejected' ? 100 : 0;
    }
});


  // ═══════════════════════════════════════════════
// VALIDATION: During Draft Editing (before activation)
// ═══════════════════════════════════════════════
this.before('CREATE', 'PurchaseOrders', (req) => {
  if (!req.data.supplier_ID) req.error(400, 'Supplier is required');
});

// ═══════════════════════════════════════════════
// VALIDATION: Before Save/Activation
// ═══════════════════════════════════════════════
this.before('SAVE', 'PurchaseOrders', (req) => {
  if (!req.data.poNumber) req.error(400, 'PO Number is required');
});

  // ═══════════════════════════════════════════════
  // SUBMIT Purchase Order
  // ═══════════════════════════════════════════════
  this.on('submit', 'PurchaseOrders', async (req) => {

    const { ID } = req.params[0];
    const { PurchaseOrders, PurchaseOrderItems, Suppliers } = cds.entities;

    const po = await SELECT.one.from(PurchaseOrders).where({ ID });

    if (!po) {
      req.reject(404, 'Purchase Order not found');
    }

    if (po.status !== 'Draft') {
      req.reject(
        400,
        `Cannot submit: PO is in "${po.status}" status. Only Draft POs can be Pending.`
      );
    }

    const items = await SELECT
      .from(PurchaseOrderItems)
      .where({ order_ID: ID });

    if (items.length === 0) {
      req.reject(
        400,
        'Cannot submit: PO has no items. Add at least one item first.'
      );
    }

    const total = items.reduce(
      (sum, item) => sum + (item.quantity * item.unitPrice),
      0
    );

    await UPDATE(PurchaseOrders)
      .set({
        status: 'Pending',
        amount: +total.toFixed(2)
      })
      .where({ ID });

    const supplier = await SELECT.one
      .from(Suppliers)
      .where({ ID: po.supplier_ID });

    await this.emit('POPending', {
      poId: ID,
      poNumber: po.poNumber,
      supplierName: supplier?.name || 'Unknown',
      totalAmount: +total.toFixed(2),
      PendingBy: req.user.id
    });

    return {
      status: 'Pending',
      message: `PO ${po.poNumber} Pending for approval. Total: ${total.toFixed(2)}`
    };
  });

  // ═══════════════════════════════════════════════
  // APPROVE Purchase Order
  // ═══════════════════════════════════════════════
  this.on('approve', 'PurchaseOrders', async (req) => {

    const { ID } = req.params[0];
    const { comment } = req.data;

    const { PurchaseOrders } = cds.entities;

    const po = await SELECT.one
      .from(PurchaseOrders)
      .where({ ID });

    if (!po) {
      req.reject(404, 'Purchase Order not found');
    }

    if (po.status !== 'Pending') {
      req.reject(
        400,
        `Cannot approve: PO is in "${po.status}" status. Only Pending POs can be approved.`
      );
    }

    await UPDATE(PurchaseOrders)
      .set({ status: 'Approved' })
      .where({ ID });

    await this.emit('POApproved', {
      poId: ID,
      poNumber: po.poNumber,
      approvedBy: req.user.id,
      comment: comment || ''
    });

    return {
      status: 'Approved',
      message: `PO ${po.poNumber} approved`,
      approvedAt: new Date().toISOString()
    };
  });

  // ═══════════════════════════════════════════════
  // REJECT Purchase Order
  // ═══════════════════════════════════════════════
  this.on('reject', 'PurchaseOrders', async (req) => {

    const { ID } = req.params[0];
    const { reason } = req.data;

    const { PurchaseOrders } = cds.entities;

    const po = await SELECT.one
      .from(PurchaseOrders)
      .where({ ID });

    if (!po) {
      req.reject(404, 'Purchase Order not found');
    }

    if (po.status !== 'Pending') {
      req.reject(
        400,
        `Cannot reject: PO is in "${po.status}" status. Only Pending POs can be rejected.`
      );
    }

    if (!reason || reason.trim() === '') {
      req.reject(400, 'Rejection reason is required');
    }

    await UPDATE(PurchaseOrders)
      .set({ status: 'Rejected' })
      .where({ ID });

    await this.emit('PORejected', {
      poId: ID,
      poNumber: po.poNumber,
      rejectedBy: req.user.id,
      reason
    });

    return {
      status: 'Rejected',
      message: `PO ${po.poNumber} rejected. Reason: ${reason}`
    };
  });

  // ═══════════════════════════════════════════════
  // RECEIVE Purchase Order
  // ═══════════════════════════════════════════════
  this.on('receive', 'PurchaseOrders', async (req) => {

    const { ID } = req.params[0];
    const { notes } = req.data;

    const {
      PurchaseOrders,
      PurchaseOrderItems,
      Products
    } = cds.entities;

    const po = await SELECT.one
      .from(PurchaseOrders)
      .where({ ID });

    if (!po) {
      req.reject(404, 'Purchase Order not found');
    }

    if (po.status !== 'Approved') {
      req.reject(
        400,
        `Cannot receive: PO must be Approved. Current status: ${po.status}`
      );
    }

    await UPDATE(PurchaseOrders)
      .set({ status: 'Received' })
      .where({ ID });

    const items = await SELECT
      .from(PurchaseOrderItems)
      .where({ order_ID: ID });

    for (const item of items) {

      const product = await SELECT.one
        .from(Products)
        .where({ ID: item.product_ID });

      if (product) {

        await UPDATE(Products)
          .set({
            stock: product.stock + item.quantity
          })
          .where({ ID: item.product_ID });
      }
    }

    return {
      status: 'Received',
      message:
        `PO ${po.poNumber} received. Stock updated for ${items.length} products.` +
        (notes ? ` Notes: ${notes}` : '')
    };
  });

  // ═══════════════════════════════════════════════
  // BOUND FUNCTION: getSummary
  // ═══════════════════════════════════════════════
  this.on('getSummary', 'PurchaseOrders', async (req) => {

    const { ID } = req.params[0];

    const {
      PurchaseOrders,
      PurchaseOrderItems,
      Suppliers
    } = cds.entities;

    const po = await SELECT.one
      .from(PurchaseOrders)
      .where({ ID });

    if (!po) {
      req.reject(404, 'Purchase Order not found');
    }

    const items = await SELECT
      .from(PurchaseOrderItems)
      .where({ order_ID: ID });

    const supplier = await SELECT.one
      .from(Suppliers)
      .where({ ID: po.supplier_ID });

    const createdDate = new Date(
      po.createdAt || po.orderDate
    );

    const daysOpen = Math.floor(
      (Date.now() - createdDate.getTime()) /
      (1000 * 60 * 60 * 24)
    );

    const totalAmount = items.reduce(
      (sum, item) => sum + (item.quantity * item.unitPrice),
      0
    );

    return {
      poNumber: po.poNumber,
      supplier: supplier?.name || 'Unknown',
      itemCount: items.length,
      totalAmount: +totalAmount.toFixed(2),
      status: po.status,
      daysOpen
    };
  });

  // ═══════════════════════════════════════════════
  // UNBOUND FUNCTION
  // ═══════════════════════════════════════════════
  this.on('getPurchasingDashboard', async () => {

    const { PurchaseOrders } = cds.entities;

    const allPOs = await SELECT.from(PurchaseOrders);

    return {
      totalPOs: allPOs.length,
      draftCount: allPOs.filter(p => p.status === 'Draft').length,
      pendingApproval: allPOs.filter(p => p.status === 'Pending').length,
      approvedCount: allPOs.filter(p => p.status === 'Approved').length,
      totalSpend: +allPOs
        .filter(p => ['Approved', 'Received'].includes(p.status))
        .reduce((sum, p) => sum + (p.amount || 0), 0)
        .toFixed(2)
    };
  });

  // ═══════════════════════════════════════════════
  // EVENT LISTENERS
  // ═══════════════════════════════════════════════

  this.on('POPending', msg => {
    console.log('[PO Pending]', msg.data.poNumber);
  });

  this.on('POApproved', msg => {
    console.log('[PO APPROVED]', msg.data.poNumber);
  });

  this.on('PORejected', msg => {
    console.log('[PO REJECTED]', msg.data.poNumber);
  });

};