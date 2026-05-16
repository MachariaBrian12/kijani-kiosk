'use strict';

const { getObjectBody, listJsonKeys } = require('../../lib/s3');
const { parseReceipt, aggregateReceipts } = require('../../lib/receipt');

const NOTIFIER_BUCKET = process.env.NOTIFIER_BUCKET;

/**
 * S3 trigger: new object in kk-notifier-output-{stage}
 * Aggregates all notification records and logs a structured summary.
 */
exports.main = async (event) => {
  const triggerKey =
    event.Records?.[0]?.s3?.object?.key &&
    decodeURIComponent(
      event.Records[0].s3.object.key.replace(/\+/g, ' ')
    );

  const keys = await listJsonKeys(NOTIFIER_BUCKET, 'notifications/');
  const receipts = [];

  for (const key of keys) {
    const raw = await getObjectBody(NOTIFIER_BUCKET, key);
    const body = JSON.parse(raw);
    receipts.push(
      parseReceipt({
        paymentId: body.paymentId,
        amount: body.amount,
        currency: body.currency,
        timestamp: body.timestamp,
      })
    );
  }

  const summary = {
    function: 'kk-analytics',
    stage: process.env.STAGE,
    triggerKey: triggerKey || null,
    generatedAt: new Date().toISOString(),
    ...aggregateReceipts(receipts),
  };

  console.log(JSON.stringify({ level: 'info', analytics: summary }));

  return summary;
};
