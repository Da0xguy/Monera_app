import { CardItem, LedgerAccount, LedgerEntry, UserProfile, CardAuthEvent, EarnVaultState, FxRates } from '../src/types';

// Mock DB with thread-safe atomic lock simulation for JIT authorizations
class LedgerDatabase {
  public user: UserProfile = {
    id: 'usr_monera_9921',
    privyUserId: 'did:privy:cm2e9k1a00192h9x87zla8p',
    walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    email: 'ayobamioketona@gmail.com',
    phone: '+234 803 123 4567',
    name: 'Ayobami Oketona',
    displayCurrency: 'NGN',
    kycStatus: 'verified',
    bvnMasked: '2224******9',
    ninMasked: '7819******2',
    hasPin: true,
    biometricEnabled: true,
    monadChainId: 10143, // Monad Devnet/Testnet L1
  };

  public ledger: LedgerAccount = {
    userId: 'usr_monera_9921',
    availableBalanceUsd: 1250.00, // $1,250.00 in Monad stablecoin
    heldBalanceUsd: 0.00,
    earnedYieldUsd: 42.80,
    currencyUnit: 'USDC',
    updatedAt: new Date().toISOString(),
  };

  public fxRates: FxRates = {
    USD_NGN: 1485.00, // ₦1,485 per $1
    MONAD_USD: 14.50, // 1 MONAD = $14.50
    updatedAt: new Date().toISOString(),
  };

  public cards: CardItem[] = [
    {
      id: 'crd_sudo_88192a',
      userId: 'usr_monera_9921',
      sudoCardId: 'sudo_crd_live_9921a91',
      type: 'virtual',
      brand: 'mastercard',
      status: 'active',
      cardholderName: 'AYOBAMI OKETONA',
      maskedPan: '5399 •••• •••• 4821',
      last4: '4821',
      expiryMonth: '08',
      expiryYear: '28',
      colorTheme: 'purple',
      spendingLimitNgn: 2000000,
      spentThisMonthNgn: 345000,
      billingAddress: {
        city: 'Victoria Island, Lagos',
        state: 'Lagos',
        country: 'Nigeria',
      },
      createdAt: new Date(Date.now() - 30 * 24 * 3600 * 1000).toISOString(),
    },
    {
      id: 'crd_sudo_33910b',
      userId: 'usr_monera_9921',
      sudoCardId: 'sudo_crd_live_33910bb',
      type: 'physical',
      brand: 'mastercard',
      status: 'active',
      cardholderName: 'AYOBAMI OKETONA',
      maskedPan: '5120 •••• •••• 9014',
      last4: '9014',
      expiryMonth: '11',
      expiryYear: '29',
      colorTheme: 'midnight',
      spendingLimitNgn: 5000000,
      spentThisMonthNgn: 120000,
      billingAddress: {
        city: 'Victoria Island, Lagos',
        state: 'Lagos',
        country: 'Nigeria',
      },
      createdAt: new Date(Date.now() - 15 * 24 * 3600 * 1000).toISOString(),
    },
  ];

  public earnVault: EarnVaultState = {
    vaultAddress: '0x8891aFa813e3b97bA0B84D34Ccfb2a26c483B109',
    network: 'Monad L1 (Chain ID: 10143)',
    apyPercent: 8.40,
    totalPooledUsd: 1482930.50,
    userPrincipalUsd: 500.00,
    userAccruedYieldUsd: 42.80,
    dailyYieldUsd: 0.115,
    status: 'active',
  };

  public transactions: LedgerEntry[] = [
    {
      id: 'tx_monera_001',
      userId: 'usr_monera_9921',
      type: 'spend-card',
      title: 'Uber Lagos',
      description: 'Sudo Mastercard POS Authorization',
      amountUsd: 8.50,
      amountNgn: 12622.50,
      feeUsd: 0.00,
      status: 'settled',
      channel: 'sudo_card',
      merchantName: 'Uber B.V.',
      merchantCategory: 'Transportation (MCC 4121)',
      authorizationCode: 'AUTH-992101',
      onChainTxRef: '0x4f8b2d1c9e8a7b6a5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b',
      latencyMs: 142,
      createdAt: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tx_monera_002',
      userId: 'usr_monera_9921',
      type: 'spend-qr',
      title: 'Shoprite Lekki Mall',
      description: 'NIBSS NQR Merchant Payment',
      amountUsd: 32.40,
      amountNgn: 48114.00,
      feeUsd: 0.00,
      status: 'settled',
      channel: 'nibss_nqr',
      merchantName: 'Shoprite Retail NG',
      merchantCategory: 'Grocery & Supermarket (MCC 5411)',
      authorizationCode: 'NQR-882194',
      onChainTxRef: '0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b',
      latencyMs: 168,
      createdAt: new Date(Date.now() - 7 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tx_monera_003',
      userId: 'usr_monera_9921',
      type: 'fund',
      title: 'NGN Bank Inbound Transfer',
      description: 'Virtual Account Funding (Wema Bank)',
      amountUsd: 250.00,
      amountNgn: 371250.00,
      feeUsd: 0.00,
      status: 'settled',
      channel: 'bank_transfer',
      onChainTxRef: '0x7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f',
      createdAt: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
    },
    {
      id: 'tx_monera_004',
      userId: 'usr_monera_9921',
      type: 'earn-deposit',
      title: 'TreasuryVault Earn Deposit',
      description: 'Monad L1 8.4% APY Vault',
      amountUsd: 500.00,
      amountNgn: 742500.00,
      feeUsd: 0.00,
      status: 'settled',
      channel: 'treasury_vault',
      onChainTxRef: '0x9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d',
      createdAt: new Date(Date.now() - 72 * 3600 * 1000).toISOString(),
    },
  ];

  public authEvents: CardAuthEvent[] = [
    {
      id: 'auth_ev_9901',
      cardId: 'crd_sudo_88192a',
      sudoAuthRef: 'SUDO_REQ_998124',
      merchantName: 'Uber B.V.',
      merchantCategory: 'Transportation (MCC 4121)',
      amountNgn: 12622.50,
      amountUsd: 8.50,
      decision: 'approved',
      authorizationCode: 'AUTH-992101',
      latencyMs: 142,
      timestamp: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
      signatureVerified: true,
      idempotent: false,
    },
  ];

  // In-memory mutex per card to avoid race conditions during concurrent JIT swipes
  private cardLocks = new Map<string, Promise<void>>();

  // Idempotency cache for Sudo authorization references
  public idempotencyCache = new Map<string, { decision: 'approved' | 'declined'; payload: any; timestamp: number }>();

  public async acquireCardLock<T>(cardId: string, fn: () => Promise<T>): Promise<T> {
    while (this.cardLocks.has(cardId)) {
      await this.cardLocks.get(cardId);
    }
    let resolveLock!: () => void;
    const lockPromise = new Promise<void>((resolve) => {
      resolveLock = resolve;
    });
    this.cardLocks.set(cardId, lockPromise);

    try {
      return await fn();
    } finally {
      this.cardLocks.delete(cardId);
      resolveLock();
    }
  }
}

export const db = new LedgerDatabase();
