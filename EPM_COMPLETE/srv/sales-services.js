const cds = require('@sap/cds');
const { SELECT, UPDATE } = cds.ql;



module.exports = cds.service.impl(function () {

  this.before('CREATE', 'SalesOrders', async (req) => {

    const { customer_ID, orderDate, items } = req.data;

    // Customer required
    if (!customer_ID) {
      req.error(400, 'Customer is required for orders', 'customer_ID');
    }

    // Date validation
    if (orderDate) {
      const today = new Date().toISOString().split('T')[0];

      if (orderDate < today) {
        req.error(400, 'Order date cannot be in the past', 'orderDate');
      }
    }

    // At least one item
    if (!items || items.length === 0) {
      req.error(400, 'Order must have at least one item');
    }

    // Validate customer exists
    if (customer_ID) {
      const customer = await SELECT.one
        .from('com.epm.Customers')
        .where({ ID: customer_ID });

      if (!customer) {
        req.error(404, 'Customer not found', 'customer_ID');
      }
    }

    // Validate items
    let netAmount = 0;

    if (items) {

      for (let i = 0; i < items.length; i++) {

        const item = items[i];

        if (!item.product_ID) {
          req.error(400, `Item ${i + 1}: Product is required`);
        }

        if (!item.quantity || item.quantity <= 0) {
          req.error(400, `Item ${i + 1}: Quantity must be greater than zero`);
        }

        if (!item.unitPrice || item.unitPrice <= 0) {
          req.error(400, `Item ${i + 1}: Unit price must be greater than zero`);
        }

        item.netAmount =
          +(item.quantity * item.unitPrice).toFixed(2);

        netAmount += item.netAmount;
      }
    }

    // Calculated totals
    req.data.netAmount = +netAmount.toFixed(2);
    req.data.taxAmount = +(netAmount * 0.18).toFixed(2);
    req.data.grossAmount = +(netAmount * 1.18).toFixed(2);

    // IMPORTANT
    req.data.amount = req.data.grossAmount;

    // Default status
    if (!req.data.status) {
      req.data.status = 'New';
    }

    // Default order number
    if (!req.data.orderNumber) {
      req.data.orderNumber =
        'SO-' + Date.now();
    }
  });

  this.before('UPDATE', 'SalesOrders', async (req) => {

    if (!req.data.status) return;

    const orderId = req.params[0]?.ID || req.params[0];

    const order = await SELECT.one
      .from('com.epm.SalesOrders')
      .where({ ID: orderId });

    if (!order) {
      req.reject(404, 'Order not found');
    }

    const transitions = {
      New: ['Confirmed', 'Cancelled'],
      Confirmed: ['Shipped', 'Cancelled'],
      Shipped: ['Delivered'],
      Delivered: [],
      Cancelled: []
    };

    const allowed =
      transitions[order.status] || [];

    if (!allowed.includes(req.data.status)) {

      req.reject(
        400,
        `Cannot change status from "${order.status}" to "${req.data.status}"`
      );
    }
  });

  this.before('DELETE', 'SalesOrders', async (req) => {

    const orderId =
      req.params[0]?.ID || req.params[0];

    const order = await SELECT.one
      .from('com.epm.SalesOrders')
      .where({ ID: orderId });

    if (
      order &&
      order.status === 'Delivered'
    ) {
      req.reject(
        409,
        'Cannot delete a delivered order'
      );
    }
  });

  this.after('READ', 'SalesOrders', (results) => {

    const orders =
      Array.isArray(results)
        ? results
        : [results];

    for (const order of orders) {

      if (!order) continue;

      const map = {
        New: {
          priority: 'Normal',
          color: 'blue'
        },
        Confirmed: {
          priority: 'Normal',
          color: 'green'
        },
        Shipped: {
          priority: 'High',
          color: 'orange'
        },
        Delivered: {
          priority: 'Low',
          color: 'grey'
        },
        Cancelled: {
          priority: 'None',
          color: 'red'
        }
      };

      const info = map[order.status];

      if (info) {
        order.statusPriority =
          info.priority;

        order.statusColor =
          info.color;
      }
    }
  });


  // =========================
// CONFIRM ORDER
// =========================

this.on('confirm', 'SalesOrders', async (req) => {

  const orderId = req.params[0].ID;

  const order = await SELECT.one
    .from('com.epm.SalesOrders')
    .where({ ID: orderId });

  if (!order) {
    req.reject(404, 'Order not found');
  }

  if (order.status !== 'New') {
    req.reject(
      400,
      `Order must be in New status. Current status: ${order.status}`
    );
  }

  await UPDATE('com.epm.SalesOrders')
    .set({ status: 'Confirmed' })
    .where({ ID: orderId });

  return {
    status: 'Confirmed',
    message: 'Order confirmed successfully'
  };
});


// =========================
// CANCEL ORDER
// =========================

this.on('cancel', 'SalesOrders', async (req) => {

  const orderId = req.params[0].ID;
  const { reason } = req.data;

  const order = await SELECT.one
    .from('com.epm.SalesOrders')
    .where({ ID: orderId });

  if (!order) {
    req.reject(404, 'Order not found');
  }

  if (
    order.status === 'Delivered' ||
    order.status === 'Cancelled'
  ) {
    req.reject(400, 'Order cannot be cancelled');
  }

  if (!reason) {
    req.reject(400, 'Cancellation reason is required');
  }

  await UPDATE('com.epm.SalesOrders')
    .set({ status: 'Cancelled' })
    .where({ ID: orderId });

  return {
    status: 'Cancelled',
    message: `Order cancelled. Reason: ${reason}`
  };
});


// =========================
// SHIP ORDER
// =========================

this.on('ship', 'SalesOrders', async (req) => {

  const orderId = req.params[0].ID;

  const {
    trackingNumber,
    carrier
  } = req.data;

  const order = await SELECT.one
    .from('com.epm.SalesOrders')
    .where({ ID: orderId });

  if (!order) {
    req.reject(404, 'Order not found');
  }

  if (order.status !== 'Confirmed') {
    req.reject(
      400,
      'Only confirmed orders can be shipped'
    );
  }

  if (!trackingNumber) {
    req.reject(400, 'Tracking number is required');
  }

  if (!carrier) {
    req.reject(400, 'Carrier is required');
  }

  await UPDATE('com.epm.SalesOrders')
    .set({ status: 'Shipped' })
    .where({ ID: orderId });

  return {
    status: 'Shipped',
    message: `Order shipped via ${carrier}`
  };
});

});