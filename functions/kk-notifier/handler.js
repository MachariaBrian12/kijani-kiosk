'use strict';

const { getObjectBody, putJson } = require('../../lib/s3');
const { parseReceipt } = require('../../lib/receipt');

const NOTIFIER_BUCKET = process.env.NOTIFIER_BUCKET;

/**
 * S3 trigger: new object in kk-payments-processed-{stage}
 * Writes a notification payload for downstream analytics.
 */
exports.main = async (event) => {
  const records = event.Records || [];
  const results = [];

  for (const record of records) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));

    const raw = await getObjectBody(bucket, key);
    const receipt = parseReceipt(raw);

    const notification = {
      type: 'payment_receipt_notified',
      paymentId: receipt.paymentId,
      amount: receipt.amount,
      currency: receipt.currency,
      timestamp: receipt.timestamp,
      notifiedAt: new Date().toISOString(),
      processedKey: key,
      channel: 'receipt-chain',
    };

    const outKey = `notifications/${receipt.paymentId}.json`;
    await putJson(NOTIFIER_BUCKET, outKey, notification);

    console.log(
      JSON.stringify({
        level: 'info',
        function: 'kk-notifier',
        paymentId: receipt.paymentId,
        outputKey: outKey,
      })
    );

    results.push({ paymentId: receipt.paymentId, outputKey: outKey });
  }

  return { notified: results.length, results };
};
