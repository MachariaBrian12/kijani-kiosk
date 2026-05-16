'use strict';

const { getObjectBody, putJson } = require('../../lib/s3');
const { parseReceipt } = require('../../lib/receipt');

const PROCESSED_BUCKET = process.env.PROCESSED_BUCKET;

/**
 * S3 trigger: new object in kk-payments-receipts-{stage}
 * Validates the receipt and writes a processed record.
 */
exports.main = async (event) => {
  const records = event.Records || [];
  const results = [];

  for (const record of records) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));

    if (!key.endsWith('.json')) {
      console.log(JSON.stringify({ level: 'info', message: 'Skipping non-JSON key', key }));
      continue;
    }

    const raw = await getObjectBody(bucket, key);
    const receipt = parseReceipt(raw);

    const processed = {
      ...receipt,
      status: 'processed',
      processedAt: new Date().toISOString(),
      originalKey: key,
    };

    const outKey = `processed/${receipt.paymentId}.json`;
    await putJson(PROCESSED_BUCKET, outKey, processed);

    console.log(
      JSON.stringify({
        level: 'info',
        function: 'kk-processor',
        paymentId: receipt.paymentId,
        amount: receipt.amount,
        outputKey: outKey,
      })
    );

    results.push({ paymentId: receipt.paymentId, outputKey: outKey });
  }

  return { processed: results.length, results };
};
