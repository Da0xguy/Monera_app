export type DisplayCurrency = 'NGN' | 'USD' | 'MONAD';
export type ThemeMode = 'dark' | 'light';

export interface UserProfile {
  id: string;
  privyUserId: string;
  walletAddress: string;
  email: string;
  phone: string;
  name: string;
  displayCurrency: DisplayCurrency;
  kycStatus: 'unverified' | 'pending' | 'verified';
  bvnMasked: string;
  ninMasked: string;
  hasPin: boolean;
  biometricEnabled: boolean;
  monadChainId: number;
}

export interface LedgerAccount {
  userId: string;
  availableBalanceUsd: number;
  heldBalanceUsd: number;
  earnedYieldUsd: number;
  currencyUnit: 'USDC' | 'MONAD-USD';
  updatedAt: string;
}

export type LedgerEntryType = 
  | 'fund' 
  | 'spend-card' 
  | 'spend-qr' 
  | 'transfer-out' 
  | 'transfer-in' 
  | 'earn-deposit' 
  | 'earn-withdraw';

export interface LedgerEntry {
  id: string;
  userId: string;
  type: LedgerEntryType;
  title: string;
  description: string;
  amountUsd: number;
  amountNgn: number;
  feeUsd: number;
  status: 'pending' | 'settled' | 'failed' | 'declined';
  channel: 'sudo_card' | 'nibss_nqr' | 'bank_transfer' | 'monad_chain' | 'treasury_vault';
  onChainTxRef?: string;
  merchantName?: string;
  merchantCategory?: string;
  authorizationCode?: string;
  latencyMs?: number;
  createdAt: string;
}

export interface CardItem {
  id: string;
  userId: string;
  sudoCardId: string;
  type: 'virtual' | 'physical';
  brand: 'mastercard';
  status: 'active' | 'frozen' | 'blocked';
  cardholderName: string;
  maskedPan: string;
  last4: string;
  expiryMonth: string;
  expiryYear: string;
  colorTheme: 'purple' | 'midnight' | 'emerald' | 'blue';
  spendingLimitNgn: number;
  spentThisMonthNgn: number;
  billingAddress: {
    city: string;
    state: string;
    country: string;
  };
  createdAt: string;
}

export interface CardAuthEvent {
  id: string;
  cardId: string;
  sudoAuthRef: string;
  merchantName: string;
  merchantCategory: string;
  amountNgn: number;
  amountUsd: number;
  decision: 'approved' | 'declined';
  declineReason?: string;
  authorizationCode?: string;
  latencyMs: number;
  timestamp: string;
  signatureVerified: boolean;
  idempotent: boolean;
}

export interface NQRMerchant {
  id: string;
  merchantName: string;
  merchantId: string;
  subCode: string;
  bankCode: string;
  bankName: string;
  category: string;
  terminalId: string;
  fixedAmount?: number;
  qrPayload: string;
}

export interface VirtualAccountInfo {
  bankName: string;
  accountNumber: string;
  accountName: string;
  reference: string;
  expiresInMinutes: number;
  feePercent: number;
}

export interface EarnVaultState {
  vaultAddress: string;
  network: string;
  apyPercent: number;
  totalPooledUsd: number;
  userPrincipalUsd: number;
  userAccruedYieldUsd: number;
  dailyYieldUsd: number;
  status: 'active' | 'paused';
}

export interface FxRates {
  USD_NGN: number;
  MONAD_USD: number;
  updatedAt: string;
}

export interface JITMetrics {
  totalRequests: number;
  approvedCount: number;
  declinedCount: number;
  avgLatencyMs: number;
  p95LatencyMs: number;
  p99LatencyMs: number;
  minLatencyMs: number;
  maxLatencyMs: number;
  targetLatencyMs: number;
  slaComplianceRate: number;
  recentAuthEvents: CardAuthEvent[];
}
