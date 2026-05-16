'use strict';

/**
 * Normalise a payment receipt from kk-payments (K8s) or test fixtures.
 * Required fields: paymentId, amount (number), currency, timestamp (ISO-8601).
 */
function parseReceipt(raw) {
  const data = typeof raw === 'string' ? JSON.parse(raw) : raw;

  const paymentId = data.paymentId || data.id;
  const amount = Number(data.amount);
  const currency = data.currency || 'KES';
  const timestamp = data.timestamp || data.createdAt || new Date().toISOString();

  if (!paymentId || Number.isNaN(amount)) {
    throw new Error(
      'Invalid receipt: paymentId and numeric amount are required'
    );
  }

  return {
    paymentId: String(paymentId),
    amount,
    currency: String(currency),
    timestamp: new Date(timestamp).toISOString(),
    source: data.source || 'kk-payments',
    metadata: data.metadata || {},
  };
}

function aggregateReceipts(receipts) {
  if (receipts.length === 0) {
    return {
      count: 0,
      totalAmount: 0,
      currency: null,
      timestampRange: null,
    };
  }

  const timestamps = receipts.map((r) => new Date(r.timestamp).getTime());
  const totalAmount = receipts.reduce((sum, r) => sum + r.amount, 0);
  const currency = receipts[0].currency;

  return {
    count: receipts.length,
    totalAmount: Math.round(totalAmount * 100) / 100,
    currency,
    timestampRange: {
      earliest: new Date(Math.min(...timestamps)).toISOString(),
      latest: new Date(Math.max(...timestamps)).toISOString(),
    },
  };
}

module.exports = {
  parseReceipt,
  aggregateReceipts,
};
