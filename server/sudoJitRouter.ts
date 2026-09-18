import { Router, Request, Response } from 'express';
import crypto from 'crypto';
import { z } from 'zod';
import { db } from './db';
import { CardAuthEvent, LedgerEntry } from '../src/types';

export const sudoJitRouter = Router();

// Environment secret for Sudo Africa webhook verification
const SUDO_WEBHOOK_SECRET = process.env.SUDO_WEBHOOK_SECRET || 'sudo_sec_live_monera_sandbox_key_9921';

// -------------------------------------------------------------
// Zod Schema for Sudo Africa JIT Authorization Webhook Payload
// -------------------------------------------------------------
export const SudoJitAuthPayloadSchema = z.object({
  event: z.literal('authorization.request'),
  data: z.object({
    id: z.string().min(1, 'Authorization ID is required'),
    cardId: z.string().min(1, 'Card ID is required'),
    amount: z.number().positive('Amount must be positive'), // In minor units (kobo) or major units
    currency: z.enum(['NGN', 'USD']),
    merchant: z.object({
      name: z.string(),
      city: z.string().optional().default('Lagos'),
      country: z.string().optional().default('NGA'),
      mcc: z.string().optional().default('5411'),
      category: z.string().optional().default('General Merchant'),
    }),
    channel: z.enum(['pos', 'web', 'atm', 'recurring']).default('pos'),
    reference: z.string().optional(),
  }),
  timestamp: z.string().or(z.number()).optional(),
});

export type SudoJitAuthPayload = z.infer<typeof SudoJitAuthPayloadSchema>;

// Latency & Circuit Breaker Tracking
let consecutiveErrors = 0;
const CIRCUIT_BREAKER_THRESHOLD = 5;
let circuitBreakerOpenUntil = 0;

/**
 * Verify Sudo Africa Webhook Signature (HMAC-SHA512 or HMAC-SHA256)
 */
export function verifySudoSignature(req: Request): boolean {
  const signature = (req.headers['x-sudo-signature'] || req.headers['sudo-signature']) as string | undefined;
  
  // In development/simulator mode, allow mock header or fallback test key
  if (!signature) {
    if (process.env.NODE_ENV !== 'production' && req.headers['x-simulator'] === 'true') {
      return true;
    }
    return false;
  }

  try {
    const rawBody = (req as any).rawBody || JSON.stringify(req.body);
    const expectedSig512 = crypto
      .createHmac('sha512', SUDO_WEBHOOK_SECRET)
      .update(rawBody)
      .digest('hex');
    const expectedSig256 = crypto
      .createHmac('sha256', SUDO_WEBHOOK_SECRET)
      .update(rawBody)
      .digest('hex');

    const sigBuffer = Buffer.from(signature);
    const buf512 = Buffer.from(expectedSig512);
    const buf256 = Buffer.from(expectedSig256);

    const match512 = sigBuffer.length === buf512.length && crypto.timingSafeEqual(sigBuffer, buf512);
    const match256 = sigBuffer.length === buf256.length && crypto.timingSafeEqual(sigBuffer, buf256);

    return match512 || match256;
  } catch (err) {
    return false;
  }
}

/**
 * POST /api/webhooks/sudo/jit-auth
 * Sudo Africa JIT Authorization Webhook Handler
 * Target SLO: <200ms end-to-end response time.
 */
sudoJitRouter.post('/jit-auth', async (req: Request, res: Response) => {
  const startTime = process.hrtime();

  // Helper to calculate elapsed ms
  const getElapsedMs = () => {
    const diff = process.hrtime(startTime);
    return Math.round((diff[0] * 1000 + diff[1] / 1e6) * 10) / 10;
  };

  // 1. Circuit Breaker Check
  if (Date.now() < circuitBreakerOpenUntil) {
    const latencyMs = getElapsedMs();
    return res.status(503).json({
      statusCode: '96',
      message: 'System malfunction: Circuit breaker active. Auto-declining for safety.',
      data: { authorizationCode: null },
      metrics: { latencyMs, decision: 'declined' },
    });
  }

  // 2. Cryptographic Signature Verification
  const isSignatureValid = verifySudoSignature(req);
  if (!isSignatureValid && process.env.NODE_ENV === 'production') {
    const latencyMs = getElapsedMs();
    return res.status(401).json({
      statusCode: '05',
      message: 'Unauthorized: Invalid Sudo webhook signature',
      data: { authorizationCode: null },
      metrics: { latencyMs, decision: 'declined' },
    });
  }

  // 3. Strict Payload Validation with Zod
  const parseResult = SudoJitAuthPayloadSchema.safeParse(req.body);
  if (!parseResult.success) {
    const latencyMs = getElapsedMs();
    return res.status(400).json({
      statusCode: '30',
      message: 'Format error: Invalid payload schema',
      errors: parseResult.error.format(),
      data: { authorizationCode: null },
      metrics: { latencyMs, decision: 'declined' },
    });
  }

  const { data: authData } = parseResult.data;
  const sudoAuthRef = authData.id;
  const cardId = authData.cardId;

  // 4. Idempotency Check (Anti-Replay / Network Retry)
  if (db.idempotencyCache.has(sudoAuthRef)) {
    const cached = db.idempotencyCache.get(sudoAuthRef)!;
    const latencyMs = getElapsedMs();
    return res.status(200).json({
      ...cached.payload,
      metrics: { latencyMs, decision: cached.decision, cached: true },
    });
  }

  try {
    // 5. Atomic Lock on Card to Prevent Race Conditions & Double-Spending
    const result = await db.acquireCardLock(cardId, async () => {
      // Find card
      const card = db.cards.find((c) => c.id === cardId || c.sudoCardId === cardId);
      if (!card) {
        return {
          statusCode: '14',
          message: 'Invalid card number or card not found',
          decision: 'declined' as const,
          reason: 'Card not found in Monera ledger registry',
        };
      }

      // Check card status
      if (card.status !== 'active') {
        return {
          statusCode: '62',
          message: `Restricted card: Card is currently ${card.status}`,
          decision: 'declined' as const,
          reason: `Card status is ${card.status}`,
        };
      }

      // Convert requested amount to USD stablecoin basis
      // Sudo amounts are usually in NGN for Nigerian cards
      const amountNgn = authData.currency === 'NGN' ? authData.amount : authData.amount * db.fxRates.USD_NGN;
      const amountUsd = authData.currency === 'USD' ? authData.amount : Math.round((authData.amount / db.fxRates.USD_NGN) * 100) / 100;

      // Check spending limits
      if (card.spentThisMonthNgn + amountNgn > card.spendingLimitNgn) {
        return {
          statusCode: '61',
          message: 'Exceeds monthly card withdrawal/spend limit',
          decision: 'declined' as const,
          reason: 'Monthly spending limit reached',
        };
      }

      // Check authoritative off-chain ledger balance
      if (db.ledger.availableBalanceUsd < amountUsd) {
        return {
          statusCode: '51',
          message: 'Insufficient funds in Monad stablecoin ledger',
          decision: 'declined' as const,
          reason: `Available: $${db.ledger.availableBalanceUsd.toFixed(2)}, Required: $${amountUsd.toFixed(2)}`,
        };
      }

      // --- EXECUTE ATOMIC DEBIT ---
      // Update ledger synchronously (authoritative fast off-chain state)
      db.ledger.availableBalanceUsd -= amountUsd;
      card.spentThisMonthNgn += amountNgn;

      const authCode = `AUTH-${Math.floor(100000 + Math.random() * 900000)}`;

      // Generate synthetic Monad L1 settlement anchor hash (reconciled asynchronously)
      const mockMonadTxHash = '0x' + crypto.randomBytes(32).toString('hex');

      // Record ledger entry
      const ledgerEntry: LedgerEntry = {
        id: `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
        userId: db.user.id,
        type: 'spend-card',
        title: authData.merchant.name,
        description: `Sudo Mastercard JIT (${authData.channel.toUpperCase()})`,
        amountUsd,
        amountNgn,
        feeUsd: 0,
        status: 'settled',
        channel: 'sudo_card',
        merchantName: authData.merchant.name,
        merchantCategory: `${authData.merchant.category} (MCC ${authData.merchant.mcc})`,
        authorizationCode: authCode,
        onChainTxRef: mockMonadTxHash,
        latencyMs: getElapsedMs(),
        createdAt: new Date().toISOString(),
      };
      db.transactions.unshift(ledgerEntry);

      return {
        statusCode: '00',
        message: 'Approved',
        decision: 'approved' as const,
        authCode,
        amountNgn,
        amountUsd,
        txRef: mockMonadTxHash,
      };
    });

    const latencyMs = getElapsedMs();

    // Log CardAuthEvent for observability & latency SLO tracking
    const authEvent: CardAuthEvent = {
      id: `auth_ev_${Date.now()}`,
      cardId,
      sudoAuthRef,
      merchantName: authData.merchant.name,
      merchantCategory: authData.merchant.category || 'General',
      amountNgn: authData.amount,
      amountUsd: Math.round((authData.amount / db.fxRates.USD_NGN) * 100) / 100,
      decision: result.decision,
      declineReason: result.decision === 'declined' ? result.reason : undefined,
      authorizationCode: result.decision === 'approved' ? result.authCode : undefined,
      latencyMs,
      timestamp: new Date().toISOString(),
      signatureVerified: isSignatureValid,
      idempotent: false,
    };
    db.authEvents.unshift(authEvent);
    if (db.authEvents.length > 50) db.authEvents.pop();

    // Build standard Sudo Africa response payload
    const responsePayload = result.decision === 'approved'
      ? {
          statusCode: '00',
          message: 'Approved',
          data: {
            authorizationCode: result.authCode,
            matchedAmount: authData.amount,
            currency: authData.currency,
            fee: 0,
            settlementReference: result.txRef,
          },
        }
      : {
          statusCode: result.statusCode,
          message: result.message,
          data: {
            authorizationCode: null,
            reason: result.reason,
          },
        };

    // Save in Idempotency cache for 10 minutes
    db.idempotencyCache.set(sudoAuthRef, {
      decision: result.decision,
      payload: responsePayload,
      timestamp: Date.now(),
    });

    consecutiveErrors = 0; // reset error count

    return res.status(200).json({
      ...responsePayload,
      metrics: {
        latencyMs,
        sloMet: latencyMs < 200,
        targetSloMs: 200,
        decision: result.decision,
      },
    });
  } catch (error: any) {
    const latencyMs = getElapsedMs();
    consecutiveErrors++;
    if (consecutiveErrors >= CIRCUIT_BREAKER_THRESHOLD) {
      circuitBreakerOpenUntil = Date.now() + 30000; // Open for 30 seconds
    }

    // Security principle: NEVER fail open on financial authorizations
    return res.status(500).json({
      statusCode: '96',
      message: 'System malfunction or timeout',
      data: { authorizationCode: null },
      metrics: { latencyMs, decision: 'declined', error: error.message },
    });
  }
});
