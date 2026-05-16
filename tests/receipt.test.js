'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { parseReceipt, aggregateReceipts } = require('../lib/receipt');

describe('parseReceipt', () => {
  it('parses a valid receipt', () => {
    const receipt = parseReceipt({
      paymentId: 'pay-001',
      amount: 1500.5,
      currency: 'KES',
      timestamp: '2026-05-15T10:00:00.000Z',
    });

    assert.equal(receipt.paymentId, 'pay-001');
    assert.equal(receipt.amount, 1500.5);
    assert.equal(receipt.currency, 'KES');
  });

  it('rejects missing amount', () => {
    assert.throws(() => parseReceipt({ paymentId: 'pay-002' }), /Invalid receipt/);
  });
});

describe('aggregateReceipts', () => {
  it('aggregates count, total, and timestamp range', () => {
    const summary = aggregateReceipts([
      {
        paymentId: 'a',
        amount: 100,
        currency: 'KES',
        timestamp: '2026-05-15T08:00:00.000Z',
      },
      {
        paymentId: 'b',
        amount: 250,
        currency: 'KES',
        timestamp: '2026-05-15T12:00:00.000Z',
      },
    ]);

    assert.equal(summary.count, 2);
    assert.equal(summary.totalAmount, 350);
    assert.equal(summary.currency, 'KES');
    assert.equal(summary.timestampRange.earliest, '2026-05-15T08:00:00.000Z');
    assert.equal(summary.timestampRange.latest, '2026-05-15T12:00:00.000Z');
  });
});
