const cds = require('@sap/cds');

module.exports = cds.service.impl(function () {

  this.on('GenerateReport', async (req) => {

    const { reportType, startDate, endDate } = req.data;

    if (!reportType) {
      req.reject(400, 'Report type is required');
    }

    const validTypes = [
      'Sales',
      'Inventory',
      'Customers'
    ];

    if (!validTypes.includes(reportType)) {
      req.reject(
        400,
        `Invalid report type. Must be: ${validTypes.join(', ')}`
      );
    }

    if (startDate > endDate) {
      req.reject(
        400,
        'Start date must be before end date'
      );
    }

    return {
      reportId: cds.utils.uuid(),
      status: 'Generated',
      message:
        `${reportType} report generated successfully for ${startDate} to ${endDate}`
    };
  });

  this.on('PingHealth', () => {

    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0'
    };
  });

});