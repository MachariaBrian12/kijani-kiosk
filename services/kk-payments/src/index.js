'use strict';

const http = require('http');
const { randomUUID } = require('crypto');
const { writeReceipt } = require('./s3-receipt');

const PORT = Number(process.env.APP_PORT || 3001);
const SERVICE = 'kk-payments';

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => {
      try {
        const raw = Buffer.concat(chunks).toString('utf8') || '{}';
        resolve(JSON.parse(raw));
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

function sendJson(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === 'GET' && req.url === '/health') {
      return sendJson(res, 200, {
        status: 'healthy',
        service: SERVICE,
        receiptsBucket: process.env.RECEIPTS_BUCKET || null,
        timestamp: new Date().toISOString(),
      });
    }

    if (req.method === 'POST' && req.url === '/payments') {
      const body = await readJsonBody(req);
      const amount = Number(body.amount);
      if (Number.isNaN(amount) || amount <= 0) {
        return sendJson(res, 400, { error: 'amount must be a positive number' });
      }

      const receipt = {
        paymentId: body.paymentId || `pay-${randomUUID()}`,
        amount,
        currency: body.currency || 'KES',
        timestamp: new Date().toISOString(),
        source: SERVICE,
        metadata: body.metadata || {},
      };

      const s3 = await writeReceipt(receipt);

      console.log(
        JSON.stringify({
          level: 'info',
          event: 'receipt_uploaded',
          paymentId: receipt.paymentId,
          bucket: s3.bucket,
          key: s3.key,
        })
      );

      return sendJson(res, 201, {
        status: 'created',
        receipt,
        s3,
      });
    }

    sendJson(res, 404, { error: 'not found' });
  } catch (err) {
    console.error(JSON.stringify({ level: 'error', message: err.message }));
    sendJson(res, 500, { error: err.message });
  }
});

server.listen(PORT, () => {
  console.log(
    JSON.stringify({
      level: 'info',
      message: `${SERVICE} listening`,
      port: PORT,
      receiptsBucket: process.env.RECEIPTS_BUCKET,
    })
  );
});

module.exports = server;
