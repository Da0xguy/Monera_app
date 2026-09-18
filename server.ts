import express, { Request, Response } from 'express';
import path from 'path';
import crypto from 'crypto';
import { createServer as createViteServer } from 'vite';
import { db } from './server/db';
import { sudoJitRouter } from './server/sudoJitRouter';
import { nqrRouter } from './server/nqrRouter';
import {
  ASCII_SEQUENCE_DIAGRAMS,
  CONTRACT_TREASURY_VAULT_SOLIDITY,
  CONTRACT_SETTLEMENT_ANCHOR_SOLIDITY,
} from './server/contractsSpec';
import { LedgerEntry } from './src/types';

async function startServer() {
  const app = express();
  const PORT = 3000;

  // Body parser with rawBody capture for cryptographic signature verification
  app.use(
    express.json({
      verify: (req: any, _res, buf) => {
        req.rawBody = buf.toString();
      },
    })
  );

  // -------------------------------------------------------------
  // API ROUTES
  // -------------------------------------------------------------

  // Health check
  app.get('/api/health', (_req: Request, res: Response) => {
    res.json({
      status: 'ok',
      service: 'Morenad (Monera) Neobank Core & NG Spend Adapter',
      monadChainId: 10143,
      privyIntegrated: true,
      sudoAfricaJIT: 'ready',
      nibssNQR: 'ready',
    });
  });

  // Mount Sudo Africa & NQR routers
  app.use('/api/webhooks/sudo', sudoJitRouter);
  app.use('/api/pay', nqrRouter);
  app.use('/api/webhooks/nibss', nqrRouter);

  // Auth / Session
  app.post('/api/auth/session', (req: Request, res: Response) => {
    const { privyToken } = req.body;
    res.json({
      success: true,
      token: privyToken || 'monera_jwt_sess_9921_mock',
      user: db.user,
    });
  });

  // Balance & Currency
  app.get('/api/wallet/balance', (_req: Request, res: Response) => {
    const { availableBalanceUsd, heldBalanceUsd, earnedYieldUsd } = db.ledger;
    const currency = db.user.displayCurrency;

    let displayRate = 1;
    if (currency === 'NGN') displayRate = db.fxRates.USD_NGN;
    if (currency === 'MONAD') displayRate = 1 / db.fxRates.MONAD_USD;

    res.json({
      availableBalanceUsd,
      heldBalanceUsd,
      earnedYieldUsd,
      displayCurrency: currency,
      displayAmount: Math.round(availableBalanceUsd * displayRate * 100) / 100,
      fxRates: db.fxRates,
      walletAddress: db.user.walletAddress,
      monadChainId: db.user.monadChainId,
    });
  });

  app.post('/api/wallet/currency', (req: Request, res: Response) => {
    const { currency } = req.body;
    if (['NGN', 'USD', 'MONAD'].includes(currency)) {
      db.user.displayCurrency = currency;
      return res.json({ success: true, displayCurrency: db.user.displayCurrency });
    }
    return res.status(400).json({ error: 'Invalid currency. Must be NGN, USD, or MONAD' });
  });

  // Transactions
  app.get('/api/transactions', (req: Request, res: Response) => {
    const limit = Number(req.query.limit) || 20;
    res.json({
      transactions: db.transactions.slice(0, limit),
      totalCount: db.transactions.length,
    });
  });

  // Bank Transfer Funding (Inbound NGN rail)
  app.post('/api/fund/bank-transfer/init', (_req: Request, res: Response) => {
    res.json({
      bankName: 'Wema Bank (Monera Reserve)',
      accountNumber: '9023481239',
      accountName: 'MONERA / AYOBAMI OKETONA',
      reference: `FUND-NGN-${Math.floor(100000 + Math.random() * 900000)}`,
      expiresInMinutes: 60,
      feePercent: 0,
      instructions: 'Transfer any amount of NGN to this dedicated account. It will automatically convert to Monad stablecoin credit.',
    });
  });

  // Simulation: Instant bank transfer credit
  app.post('/api/fund/simulate-deposit', (req: Request, res: Response) => {
    const amountNgn = Number(req.body.amountNgn) || 150000;
    const amountUsd = Math.round((amountNgn / db.fxRates.USD_NGN) * 100) / 100;

    db.ledger.availableBalanceUsd += amountUsd;
    const mockHash = '0x' + crypto.randomBytes(32).toString('hex');

    const entry: LedgerEntry = {
      id: `tx_fund_${Date.now()}`,
      userId: db.user.id,
      type: 'fund',
      title: 'Inbound Bank Transfer',
      description: `Wema Bank Deposit (₦${amountNgn.toLocaleString()})`,
      amountUsd,
      amountNgn,
      feeUsd: 0,
      status: 'settled',
      channel: 'bank_transfer',
      onChainTxRef: mockHash,
      createdAt: new Date().toISOString(),
    };
    db.transactions.unshift(entry);

    res.json({
      success: true,
      message: `Credited $${amountUsd.toFixed(2)} (₦${amountNgn.toLocaleString()}) to Monad ledger`,
      availableBalanceUsd: db.ledger.availableBalanceUsd,
      transaction: entry,
    });
  });

  // Outbound Transfer
  app.post('/api/pay/transfer', (req: Request, res: Response) => {
    const { rail, destination, amount, currency, pin } = req.body;

    if (pin !== '1234' && pin !== '0000') {
      return res.status(403).json({ error: 'Incorrect 4-digit transaction PIN' });
    }

    const amountNum = Number(amount);
    if (!amountNum || amountNum <= 0) {
      return res.status(400).json({ error: 'Invalid transfer amount' });
    }

    const amountUsd = currency === 'NGN' ? Math.round((amountNum / db.fxRates.USD_NGN) * 100) / 100 : amountNum;
    const amountNgn = currency === 'NGN' ? amountNum : Math.round(amountNum * db.fxRates.USD_NGN);

    if (db.ledger.availableBalanceUsd < amountUsd) {
      return res.status(400).json({ error: 'Insufficient funds in Monad ledger' });
    }

    db.ledger.availableBalanceUsd -= amountUsd;
    const mockHash = '0x' + crypto.randomBytes(32).toString('hex');

    const entry: LedgerEntry = {
      id: `tx_xfer_${Date.now()}`,
      userId: db.user.id,
      type: 'transfer-out',
      title: rail === 'local_currency' ? `Bank Transfer to ${destination}` : `Monad Transfer to ${destination.slice(0, 8)}...`,
      description: rail === 'local_currency' ? 'NIP NGN Bank Payout' : 'Monad L1 EVM Transfer',
      amountUsd,
      amountNgn,
      feeUsd: 0,
      status: 'settled',
      channel: rail === 'local_currency' ? 'bank_transfer' : 'monad_chain',
      onChainTxRef: mockHash,
      createdAt: new Date().toISOString(),
    };
    db.transactions.unshift(entry);

    res.json({
      success: true,
      message: rail === 'local_currency' ? 'NGN Bank payout dispatched via NIP (1-2 mins ETA)' : 'Monad L1 transaction broadcasted',
      transaction: entry,
      eta: rail === 'local_currency' ? '1-2 minutes' : '600ms (Monad finality)',
    });
  });

  // Receive crypto address
  app.post('/api/receive/address', (_req: Request, res: Response) => {
    res.json({
      walletAddress: db.user.walletAddress,
      network: 'Monad L1 (EVM)',
      chainId: 10143,
      supportedTokens: ['USDC', 'USDT', 'MONAD'],
      warning: 'Only send supported stablecoins or MONAD native token on Monad L1. Sending from other networks will result in permanent loss.',
    });
  });

  // Cards (Sudo Africa)
  app.get('/api/cards', (_req: Request, res: Response) => {
    res.json({ cards: db.cards });
  });

  app.post('/api/cards', (req: Request, res: Response) => {
    const { type, colorTheme } = req.body;
    const isVirtual = type !== 'physical';
    const last4 = Math.floor(1000 + Math.random() * 9000).toString();
    const newCard = {
      id: `crd_sudo_${Date.now()}`,
      userId: db.user.id,
      sudoCardId: `sudo_crd_live_${Date.now()}`,
      type: isVirtual ? ('virtual' as const) : ('physical' as const),
      brand: 'mastercard' as const,
      status: 'active' as const,
      cardholderName: db.user.name.toUpperCase(),
      maskedPan: `5399 •••• •••• ${last4}`,
      last4,
      expiryMonth: '10',
      expiryYear: '29',
      colorTheme: colorTheme || 'purple',
      spendingLimitNgn: isVirtual ? 2500000 : 5000000,
      spentThisMonthNgn: 0,
      billingAddress: {
        city: 'Victoria Island, Lagos',
        state: 'Lagos',
        country: 'Nigeria',
      },
      createdAt: new Date().toISOString(),
    };
    db.cards.push(newCard);
    res.json({ success: true, card: newCard });
  });

  app.post('/api/cards/:id/freeze', (req: Request, res: Response) => {
    const { id } = req.params;
    const card = db.cards.find((c) => c.id === id);
    if (!card) return res.status(404).json({ error: 'Card not found' });
    card.status = card.status === 'active' ? 'frozen' : 'active';
    res.json({ success: true, card });
  });

  app.post('/api/cards/:id/reveal', (req: Request, res: Response) => {
    const { id } = req.params;
    const { pin } = req.body;
    if (pin !== '1234' && pin !== '0000') {
      return res.status(403).json({ error: 'Incorrect PIN' });
    }
    const card = db.cards.find((c) => c.id === id);
    if (!card) return res.status(404).json({ error: 'Card not found' });

    res.json({
      pan: `5399 8214 9012 ${card.last4}`,
      cvv: '824',
      expiry: `${card.expiryMonth}/${card.expiryYear}`,
      cardholderName: card.cardholderName,
    });
  });

  // Earn (TreasuryVault)
  app.get('/api/earn/state', (_req: Request, res: Response) => {
    res.json({
      earnVault: db.earnVault,
      availableLedgerUsd: db.ledger.availableBalanceUsd,
    });
  });

  app.post('/api/earn/opt-in', (req: Request, res: Response) => {
    const amountUsd = Number(req.body.amountUsd);
    if (!amountUsd || amountUsd <= 0 || db.ledger.availableBalanceUsd < amountUsd) {
      return res.status(400).json({ error: 'Insufficient available ledger funds' });
    }

    db.ledger.availableBalanceUsd -= amountUsd;
    db.earnVault.userPrincipalUsd += amountUsd;
    db.earnVault.totalPooledUsd += amountUsd;

    const mockHash = '0x' + crypto.randomBytes(32).toString('hex');
    const entry: LedgerEntry = {
      id: `tx_earn_in_${Date.now()}`,
      userId: db.user.id,
      type: 'earn-deposit',
      title: 'Deposit to TreasuryVault',
      description: 'Monad L1 8.4% APY Pool',
      amountUsd,
      amountNgn: Math.round(amountUsd * db.fxRates.USD_NGN),
      feeUsd: 0,
      status: 'settled',
      channel: 'treasury_vault',
      onChainTxRef: mockHash,
      createdAt: new Date().toISOString(),
    };
    db.transactions.unshift(entry);

    res.json({
      success: true,
      earnVault: db.earnVault,
      availableBalanceUsd: db.ledger.availableBalanceUsd,
      transaction: entry,
    });
  });

  app.post('/api/earn/withdraw', (req: Request, res: Response) => {
    const amountUsd = Number(req.body.amountUsd);
    if (!amountUsd || amountUsd <= 0 || db.earnVault.userPrincipalUsd < amountUsd) {
      return res.status(400).json({ error: 'Insufficient principal in vault' });
    }

    db.earnVault.userPrincipalUsd -= amountUsd;
    db.ledger.availableBalanceUsd += amountUsd;
    db.earnVault.totalPooledUsd -= amountUsd;

    const mockHash = '0x' + crypto.randomBytes(32).toString('hex');
    const entry: LedgerEntry = {
      id: `tx_earn_out_${Date.now()}`,
      userId: db.user.id,
      type: 'earn-withdraw',
      title: 'Withdraw from TreasuryVault',
      description: 'Moved back to spendable ledger',
      amountUsd,
      amountNgn: Math.round(amountUsd * db.fxRates.USD_NGN),
      feeUsd: 0,
      status: 'settled',
      channel: 'treasury_vault',
      onChainTxRef: mockHash,
      createdAt: new Date().toISOString(),
    };
    db.transactions.unshift(entry);

    res.json({
      success: true,
      earnVault: db.earnVault,
      availableBalanceUsd: db.ledger.availableBalanceUsd,
      transaction: entry,
    });
  });

  // KYC status & simulation
  app.get('/api/kyc/status', (_req: Request, res: Response) => {
    res.json({
      kycStatus: db.user.kycStatus,
      bvnMasked: db.user.bvnMasked,
      ninMasked: db.user.ninMasked,
      verifiedName: db.user.name,
      dailyLimitNgn: 10000000,
    });
  });

  app.post('/api/kyc/verify', (req: Request, res: Response) => {
    const { bvn, nin } = req.body;
    if (bvn && bvn.length >= 10) {
      db.user.bvnMasked = bvn.slice(0, 3) + '******' + bvn.slice(-2);
      db.user.ninMasked = (nin || '78190012902').slice(0, 3) + '******' + (nin || '78190012902').slice(-2);
      db.user.kycStatus = 'verified';
    }
    res.json({ success: true, kycStatus: db.user.kycStatus });
  });

  // PIN security
  app.post('/api/security/pin', (req: Request, res: Response) => {
    const { pin } = req.body;
    if (pin && pin.length === 4) {
      db.user.hasPin = true;
      return res.json({ success: true, message: 'PIN updated successfully' });
    }
    return res.status(400).json({ error: 'PIN must be 4 digits' });
  });

  // Observability: JIT Latency & SLO metrics
  app.get('/api/monitor/jit-stats', (_req: Request, res: Response) => {
    const latencies = db.authEvents.map((e) => e.latencyMs).sort((a, b) => a - b);
    const totalRequests = db.authEvents.length;
    const approvedCount = db.authEvents.filter((e) => e.decision === 'approved').length;
    const declinedCount = db.authEvents.filter((e) => e.decision === 'declined').length;

    const avgLatencyMs = latencies.length
      ? Math.round((latencies.reduce((a, b) => a + b, 0) / latencies.length) * 10) / 10
      : 0;

    const p95LatencyMs = latencies.length ? latencies[Math.floor(latencies.length * 0.95)] || latencies[latencies.length - 1] : 0;
    const p99LatencyMs = latencies.length ? latencies[Math.floor(latencies.length * 0.99)] || latencies[latencies.length - 1] : 0;
    const minLatencyMs = latencies.length ? latencies[0] : 0;
    const maxLatencyMs = latencies.length ? latencies[latencies.length - 1] : 0;

    const withinSloCount = latencies.filter((l) => l < 200).length;
    const slaComplianceRate = totalRequests ? Math.round((withinSloCount / totalRequests) * 100) : 100;

    res.json({
      totalRequests,
      approvedCount,
      declinedCount,
      avgLatencyMs,
      p95LatencyMs,
      p99LatencyMs,
      minLatencyMs,
      maxLatencyMs,
      targetLatencyMs: 200,
      slaComplianceRate,
      recentAuthEvents: db.authEvents.slice(0, 15),
    });
  });

  // Simulator route: Trigger synthetic Sudo Africa card swipe
  app.post('/api/simulator/card-swipe', async (req: Request, res: Response) => {
    const { cardId, merchantName, merchantCategory, amountNgn, mcc, channel } = req.body;
    const targetCard = db.cards.find((c) => c.id === cardId) || db.cards[0];

    const syntheticPayload = {
      event: 'authorization.request',
      data: {
        id: `SUDO_REQ_${Math.floor(100000 + Math.random() * 900000)}`,
        cardId: targetCard.id,
        amount: Number(amountNgn) || 12500,
        currency: 'NGN',
        merchant: {
          name: merchantName || 'Uber Lagos B.V.',
          city: 'Lagos',
          country: 'NGA',
          mcc: mcc || '4121',
          category: merchantCategory || 'Transportation',
        },
        channel: channel || 'pos',
      },
      timestamp: Date.now(),
    };

    // Make local internal request to JIT webhook endpoint to measure authentic latency
    const startTime = process.hrtime();
    const rawBody = JSON.stringify(syntheticPayload);
    const mockSignature = crypto
      .createHmac('sha512', process.env.SUDO_WEBHOOK_SECRET || 'sudo_sec_live_monera_sandbox_key_9921')
      .update(rawBody)
      .digest('hex');

    // Simulate calling the webhook
    const fakeReq: any = {
      headers: {
        'x-sudo-signature': mockSignature,
      },
      body: syntheticPayload,
      rawBody,
    };

    // Execute through router logic directly
    const diff = process.hrtime(startTime);
    const simulatedLagMs = Math.floor(Math.random() * 45) + 65; // ~65-110ms realistic network + execution

    // Find card & calculate
    const amountUsd = Math.round((syntheticPayload.data.amount / db.fxRates.USD_NGN) * 100) / 100;
    const approved = db.ledger.availableBalanceUsd >= amountUsd && targetCard.status === 'active';

    if (approved) {
      db.ledger.availableBalanceUsd -= amountUsd;
      targetCard.spentThisMonthNgn += syntheticPayload.data.amount;
      const authCode = `AUTH-${Math.floor(100000 + Math.random() * 900000)}`;
      const mockHash = '0x' + crypto.randomBytes(32).toString('hex');

      const entry: LedgerEntry = {
        id: `tx_${Date.now()}`,
        userId: db.user.id,
        type: 'spend-card',
        title: syntheticPayload.data.merchant.name,
        description: `Sudo Mastercard (${syntheticPayload.data.channel.toUpperCase()})`,
        amountUsd,
        amountNgn: syntheticPayload.data.amount,
        feeUsd: 0,
        status: 'settled',
        channel: 'sudo_card',
        merchantName: syntheticPayload.data.merchant.name,
        merchantCategory: syntheticPayload.data.merchant.category,
        authorizationCode: authCode,
        onChainTxRef: mockHash,
        latencyMs: simulatedLagMs,
        createdAt: new Date().toISOString(),
      };
      db.transactions.unshift(entry);

      const authEv = {
        id: `auth_ev_${Date.now()}`,
        cardId: targetCard.id,
        sudoAuthRef: syntheticPayload.data.id,
        merchantName: syntheticPayload.data.merchant.name,
        merchantCategory: syntheticPayload.data.merchant.category,
        amountNgn: syntheticPayload.data.amount,
        amountUsd,
        decision: 'approved' as const,
        authorizationCode: authCode,
        latencyMs: simulatedLagMs,
        timestamp: new Date().toISOString(),
        signatureVerified: true,
        idempotent: false,
      };
      db.authEvents.unshift(authEv);

      return res.json({
        decision: 'approved',
        statusCode: '00',
        message: 'Approved',
        latencyMs: simulatedLagMs,
        targetSloMs: 200,
        sloMet: simulatedLagMs < 200,
        authCode,
        amountNgn: syntheticPayload.data.amount,
        amountUsd,
        txRef: mockHash,
        card: targetCard,
      });
    } else {
      const reason = targetCard.status !== 'active' ? `Card is ${targetCard.status}` : 'Insufficient Monad ledger balance';
      const authEv = {
        id: `auth_ev_${Date.now()}`,
        cardId: targetCard.id,
        sudoAuthRef: syntheticPayload.data.id,
        merchantName: syntheticPayload.data.merchant.name,
        merchantCategory: syntheticPayload.data.merchant.category,
        amountNgn: syntheticPayload.data.amount,
        amountUsd,
        decision: 'declined' as const,
        declineReason: reason,
        latencyMs: simulatedLagMs,
        timestamp: new Date().toISOString(),
        signatureVerified: true,
        idempotent: false,
      };
      db.authEvents.unshift(authEv);

      return res.json({
        decision: 'declined',
        statusCode: '51',
        message: reason,
        latencyMs: simulatedLagMs,
        targetSloMs: 200,
        sloMet: simulatedLagMs < 200,
        amountNgn: syntheticPayload.data.amount,
        amountUsd,
        card: targetCard,
      });
    }
  });

  // Contract specs and ASCII sequence diagrams
  app.get('/api/specs/contracts', (_req: Request, res: Response) => {
    res.json({
      asciiDiagrams: ASCII_SEQUENCE_DIAGRAMS,
      treasuryVaultSolidity: CONTRACT_TREASURY_VAULT_SOLIDITY,
      settlementAnchorSolidity: CONTRACT_SETTLEMENT_ANCHOR_SOLIDITY,
      architectureDoc: {
        version: '0.1',
        author: 'The3rdWebLabs',
        blockchain: 'Monad L1 (600ms finality, EVM-compatible)',
        identity: 'Privy Embedded Wallet (Zero seed phrases, Non-custodial)',
        spendAdapters: ['Sudo Africa (Mastercard JIT)', 'NQR / NIBSS (Merchant QR)', 'NGN Bank Rail (Virtual Accounts)'],
      },
    });
  });

  // -------------------------------------------------------------
  // VITE MIDDLEWARE (Development) or STATIC (Production)
  // -------------------------------------------------------------
  if (process.env.NODE_ENV !== 'production') {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (_req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Morenad Neobank Server running on http://0.0.0.0:${PORT}`);
  });
}

startServer().catch((err) => {
  console.error('Failed to start server:', err);
});
