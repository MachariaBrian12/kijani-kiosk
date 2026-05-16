'use strict';

const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
  ListObjectsV2Command,
} = require('@aws-sdk/client-s3');

const client = new S3Client({});

async function getObjectBody(bucket, key) {
  const response = await client.send(
    new GetObjectCommand({ Bucket: bucket, Key: key })
  );
  const chunks = [];
  for await (const chunk of response.Body) {
    chunks.push(chunk);
  }
  return Buffer.concat(chunks).toString('utf8');
}

async function putJson(bucket, key, payload) {
  await client.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: JSON.stringify(payload, null, 2),
      ContentType: 'application/json',
    })
  );
}

async function listJsonKeys(bucket, prefix = '') {
  const keys = [];
  let continuationToken;

  do {
    const response = await client.send(
      new ListObjectsV2Command({
        Bucket: bucket,
        Prefix: prefix,
        ContinuationToken: continuationToken,
      })
    );
    for (const item of response.Contents || []) {
      if (item.Key && item.Key.endsWith('.json')) {
        keys.push(item.Key);
      }
    }
    continuationToken = response.IsTruncated
      ? response.NextContinuationToken
      : undefined;
  } while (continuationToken);

  return keys;
}

module.exports = {
  getObjectBody,
  putJson,
  listJsonKeys,
};
