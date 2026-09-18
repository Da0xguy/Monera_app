import { Router, Request, Response } from 'express';
import crypto from 'crypto';
import { z } from 'zod';
import { db } from './db';
import { LedgerEntry } from '../src/types';

export const nqrRouter = Router();

// Schema for NQR payment submission
const NQRPaymentSchema = z.object({
  qrPayload: z.string().min(5, 'Invalid QR payload'),
  merchantName: z.string().min(1),
  merchantId: z.string().min(1),
  amountNgn: z.number().positive('Amount must be positive'),
  subCode: z.string().optional().default('0001'),
  bankCode: z.string().optional().default('058'),
  terminalId: z.string().optional().default('TERM-LAGOS-01'),
  pin: z.string().length(4, 'PIN must be 4 digits'),
});

/**
 * POST /api/pay/qr
 * Resolves NIBSS NQR Merchant, debits off-chain ledger, and triggers NGN payout
 */
nqrRouter.post('/qr', async (req: Request, res: Response) => {
  const startTime = process.hrtime();
  const parseResult = NQRPaymentSchema.safeParse(req.body);

  if (!parseResult.success) {
    return res.status(400).json({
      error: 'Invalid NQR payload format',
      details: parseResult.error.format(),
    });
  }

  const { merchantName, merchantId, amountNgn, pin } = parseResult.data;

  // Simple PIN verification (demo PIN is 1234 or user's PIN)
  if (pin !== '1234' && pin !== '0000') {
    return res.status(403).json({ error: 'Incorrect 4-digit transaction PIN' });
  }

  const amountUsd = Math.round((amountNgn / db.fxRates.USD_NGN) * 100) / 100;

  if (db.ledger.availableBalanceUsd < amountUsd) {
    return res.status(400).json({
      error: 'Insufficient funds in your Monad stablecoin ledger',
      availableUsd: db.ledger.availableBalanceUsd,
      requiredUsd: amountUsd,
    });
  }

  // Deduct from available balance
  db.ledger.availableBalanceUsd -= amountUsd;

  const diff = process.hrtime(startTime);
  const latencyMs = Math.round((diff[0] * 1000 + diff[1] / 1e6) * 10) / 10;
  const mockMonadTxHash = '0x' + crypto.randomBytes(32).toString('hex');
  const nqrRef = `NQR-${Math.floor(100000 + Math.random() * 900000)}`;

  const entry: LedgerEntry = {
    id: `tx_nqr_${Date.now()}`,
    userId: db.user.id,
    type: 'spend-qr',
    title: merchantName,
    description: `NIBSS NQR Scan-to-Pay (ID: ${merchantId})`,
    amountUsd,
    amountNgn,
    feeUsd: 0,
    status: 'settled',
    channel: 'nibss_nqr',
    merchantName,
    merchantCategory: 'Merchant QR Scan',
    authorizationCode: nqrRef,
    onChainTxRef: mockMonadTxHash,
    latencyMs,
    createdAt: new Date().toISOString(),
  };

  db.transactions.unshift(entry);

  return res.json({
    status: 'success',
    message: 'NQR payment settled successfully',
    transaction: entry,
    settlement: {
      merchantId,
      merchantName,
      nqrRef,
      ngnPayoutRail: 'NIBSS Instant Payment (NIP)',
      monadSettlementHash: mockMonadTxHash,
      executionLatencyMs: latencyMs,
    },
  });
});

/**
 * POST /api/webhooks/nibss/nqr
 * Inbound settlement confirmation webhook from NIBSS
 */
nqrRouter.post('/webhooks/nibss/nqr', async (req: Request, res: Response) => {
  const { sessionID, destinationInstitutionCode, channelCode, transactionAmount } = req.body;
  // Acknowledge NIBSS settlement receipt
  res.status(200).json({
    responseCode: '00',
    responseMessage: 'NIBSS NQR settlement accepted and anchored',
    sessionID: sessionID || `NIBSS_${Date.now()}`,
    anchoredAt: new Date().toISOString(),
  });
});
