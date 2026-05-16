'use strict';

const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');

const client = new S3Client({
  region: process.env.AWS_REGION || 'us-east-1',
  ...(process.env.AWS_ENDPOINT_URL
    ? { endpoint: process.env.AWS_ENDPOINT_URL, forcePathStyle: true }
    : {}),
});

/**
 * Write a payment receipt JSON object to the receipts bucket (triggers kk-processor).
 */
async function writeReceipt(receipt) {
  const bucket = process.env.RECEIPTS_BUCKET;
  if (!bucket) {
    throw new Error('RECEIPTS_BUCKET is not configured');
  }

  const key = `receipts/${receipt.paymentId}.json`;

  await client.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: JSON.stringify(receipt, null, 2),
      ContentType: 'application/json',
    })
  );

  return { bucket, key };
}

module.exports = { writeReceipt };
