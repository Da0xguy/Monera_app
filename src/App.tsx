import React, { useState, useEffect } from 'react';
import {
  CardItem,
  DisplayCurrency,
  EarnVaultState,
  FxRates,
  LedgerAccount,
  LedgerEntry,
  NQRMerchant,
  UserProfile,
  VirtualAccountInfo,
} from './types';
import { WalletHome } from './components/WalletHome';
import { PayAndScan } from './components/PayAndScan';
import { CardsView } from './components/CardsView';
import { EarnVault } from './components/EarnVault';
import { SettingsView } from './components/SettingsView';
import { FundModal } from './components/FundModal';
import { PinModal } from './components/PinModal';
import { TransactionReceiptSheet } from './components/TransactionReceiptSheet';
import { MoneraLogo } from './components/MoneraLogo';
import { useTheme } from './context/ThemeContext';
import {
  Wallet,
  Send,
  CreditCard,
  TrendingUp,
  Settings,
  Wifi,
  Battery,
  Zap,
} from 'lucide-react';

export default function App() {
  const { theme, isDark } = useTheme();
  const [activeTab, setActiveTab] = useState<'home' | 'pay' | 'cards' | 'earn' | 'settings'>('home');
  const [selectedTx, setSelectedTx] = useState<LedgerEntry | null>(null);

  // Core User Profile
  const [user, setUser] = useState<UserProfile>({
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
    monadChainId: 10143,
  });

  // Off-Chain Authoritative Ledger
  const [ledger, setLedger] = useState<LedgerAccount>({
    userId: 'usr_monera_9921',
    availableBalanceUsd: 1250.0,
    heldBalanceUsd: 0,
    earnedYieldUsd: 42.8,
    currencyUnit: 'USDC',
    updatedAt: new Date().toISOString(),
  });

  // FX Rates
  const [fxRates, setFxRates] = useState<FxRates>({
    USD_NGN: 1485.0,
    MONAD_USD: 14.5,
    updatedAt: new Date().toISOString(),
  });

  const [transactions, setTransactions] = useState<LedgerEntry[]>([]);
  const [cards, setCards] = useState<CardItem[]>([]);
  const [earnVault, setEarnVault] = useState<EarnVaultState>({
    vaultAddress: '0x8891aFa813e3b97bA0B84D34Ccfb2a26c483B109',
    network: 'Monad L1 (Chain ID: 10143)',
    apyPercent: 8.4,
    totalPooledUsd: 1482930.5,
    userPrincipalUsd: 500.0,
    userAccruedYieldUsd: 42.8,
    dailyYieldUsd: 0.115,
    status: 'active',
  });

  // Modals
  const [isFundOpen, setIsFundOpen] = useState(false);
  const [virtualAccount, setVirtualAccount] = useState<VirtualAccountInfo | null>(null);

  const [pinModalConfig, setPinModalConfig] = useState<{
    isOpen: boolean;
    title: string;
    description: string;
    onSuccess: (pin: string) => void;
  }>({
    isOpen: false,
    title: '',
    description: '',
    onSuccess: () => {},
  });

  // Fetch initial data
  const refreshData = async () => {
    try {
      const [balRes, txRes, cardRes, earnRes] = await Promise.all([
        fetch('/api/wallet/balance'),
        fetch('/api/transactions'),
        fetch('/api/cards'),
        fetch('/api/earn/state'),
      ]);

      if (balRes.ok) {
        const bal = await balRes.json();
        setLedger((prev) => ({
          ...prev,
          availableBalanceUsd: bal.availableBalanceUsd,
          heldBalanceUsd: bal.heldBalanceUsd,
          earnedYieldUsd: bal.earnedYieldUsd,
        }));
        setFxRates(bal.fxRates);
        setUser((prev) => ({ ...prev, displayCurrency: bal.displayCurrency }));
      }

      if (txRes.ok) {
        const txData = await txRes.json();
        setTransactions(txData.transactions || []);
      }

      if (cardRes.ok) {
        const cData = await cardRes.json();
        setCards(cData.cards || []);
      }

      if (earnRes.ok) {
        const eData = await earnRes.json();
        if (eData.earnVault) setEarnVault(eData.earnVault);
      }
    } catch (err) {
      console.error('Failed to refresh data from server:', err);
    }
  };

  useEffect(() => {
    refreshData();
  }, []);

  // Change currency
  const handleCurrencyChange = async (currency: DisplayCurrency) => {
    setUser((prev) => ({ ...prev, displayCurrency: currency }));
    try {
      await fetch('/api/wallet/currency', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ currency }),
      });
      refreshData();
    } catch (e) {
      console.error(e);
    }
  };

  // Open Fund Modal
  const handleOpenFund = async () => {
    try {
      const res = await fetch('/api/fund/bank-transfer/init', { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setVirtualAccount(data);
      }
    } catch (e) {
      console.error(e);
    }
    setIsFundOpen(true);
  };

  // Simulate Inbound Deposit
  const handleSimulateDeposit = async (amountNgn: number) => {
    const res = await fetch('/api/fund/simulate-deposit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amountNgn }),
    });
    if (!res.ok) throw new Error('Deposit failed');
    await refreshData();
  };

  // PIN prompt helper
  const promptPin = (
    callback: (pin: string) => void,
    title = 'Enter Transaction PIN',
    description = 'Authorize this transaction with your 4-digit security PIN'
  ) => {
    setPinModalConfig({
      isOpen: true,
      title,
      description,
      onSuccess: (pin: string) => {
        setPinModalConfig((prev) => ({ ...prev, isOpen: false }));
        callback(pin);
      },
    });
  };

  // Pay NQR
  const handlePayNQR = async (merchant: NQRMerchant, amountNgn: number, pin: string) => {
    const res = await fetch('/api/pay/qr', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        qrPayload: merchant.qrPayload,
        merchantName: merchant.merchantName,
        merchantId: merchant.merchantId,
        amountNgn,
        subCode: merchant.subCode,
        bankCode: merchant.bankCode,
        terminalId: merchant.terminalId,
        pin,
      }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'NQR payment failed');
    await refreshData();
    return data;
  };

  // Transfer
  const handleTransfer = async (payload: {
    rail: 'local_currency' | 'digital_asset';
    destination: string;
    amount: number;
    currency: 'NGN' | 'USD';
    pin: string;
  }) => {
    const res = await fetch('/api/pay/transfer', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Transfer failed');
    await refreshData();
    return data;
  };

  // Card Freeze
  const handleToggleFreeze = async (cardId: string) => {
    const res = await fetch(`/api/cards/${cardId}/freeze`, { method: 'POST' });
    if (res.ok) {
      await refreshData();
    }
  };

  // Card Reveal PAN / CVV
  const handleRevealCard = async (cardId: string, pin: string) => {
    const res = await fetch(`/api/cards/${cardId}/reveal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pin }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Failed to reveal credentials');
    return data;
  };

  // Issue New Card
  const handleIssueCard = async (type: 'virtual' | 'physical') => {
    const res = await fetch('/api/cards', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type, colorTheme: 'purple' }),
    });
    if (res.ok) {
      await refreshData();
    }
  };

  // Earn Deposit
  const handleEarnDeposit = async (amountUsd: number) => {
    const res = await fetch('/api/earn/opt-in', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amountUsd }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Earn deposit failed');
    await refreshData();
  };

  // Earn Withdraw
  const handleEarnWithdraw = async (amountUsd: number) => {
    const res = await fetch('/api/earn/withdraw', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amountUsd }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Earn withdraw failed');
    await refreshData();
  };

  return (
    <div className={`min-h-screen ${isDark ? 'bg-[#030712]' : 'bg-slate-100'} flex items-center justify-center p-0 sm:p-4 md:p-6 select-none font-sans transition-colors duration-300`}>
      {/* Mobile Device Canvas (Native App Viewport) */}
      <div
        className={`relative w-full max-w-[430px] h-screen sm:h-[880px] ${
          isDark
            ? 'bg-[#060b17] text-slate-100 sm:border-[#0f244a] sm:shadow-[0_25px_80px_rgba(0,0,0,0.95),0_0_40px_rgba(0,119,182,0.15)]'
            : 'bg-slate-50 text-slate-900 sm:border-slate-300 sm:shadow-[0_20px_60px_rgba(0,0,0,0.12),0_0_30px_rgba(37,99,235,0.06)]'
        } sm:rounded-[48px] sm:border-4 flex flex-col overflow-hidden transition-colors duration-300`}
      >
        {/* iOS / Android Native Status Bar */}
        <header className={`px-6 pt-3 pb-2 flex justify-between items-center text-[12px] font-semibold ${isDark ? 'text-slate-400' : 'text-slate-600'} shrink-0 z-30 transition-colors`}>
          <span className="font-medium">9:41</span>
          {/* Dynamic Island */}
          <div className={`w-24 h-5 rounded-full bg-black border ${isDark ? 'border-blue-950/80' : 'border-slate-700'} mx-auto flex items-center justify-end px-2`}>
            <div className="w-2 h-2 rounded-full bg-blue-400 animate-pulse shadow-[0_0_8px_rgba(56,189,248,0.8)]" />
          </div>
          <div className="flex items-center gap-1.5">
            <span className="text-[10px] font-bold text-blue-500">5G</span>
            <Wifi className="w-3.5 h-3.5 text-blue-500" />
            <Battery className="w-4 h-4 text-emerald-500" />
          </div>
        </header>

        {/* Currency Pill Header with Official Monera Logo */}
        <div className={`px-5 py-2.5 flex items-center justify-between border-b ${isDark ? 'border-blue-950/60 bg-[#060b17]/80' : 'border-slate-200 bg-white/80'} backdrop-blur-md z-20 shrink-0 transition-colors`}>
          <div className="flex items-center">
            <MoneraLogo variant="horizontal" size={22} color={isDark ? 'white' : 'black'} />
          </div>

          {/* Quick Currency Selector */}
          <div className={`flex items-center ${isDark ? 'bg-slate-950/90 border-blue-900/40' : 'bg-slate-200/80 border-slate-300'} border rounded-full p-0.5 transition-colors`}>
            {(['NGN', 'USD', 'MONAD'] as DisplayCurrency[]).map((curr) => {
              const active = user.displayCurrency === curr;
              return (
                <button
                  key={curr}
                  onClick={() => handleCurrencyChange(curr)}
                  className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold transition-all ${
                    active
                      ? 'bg-blue-600 text-white shadow-xs shadow-blue-500/30'
                      : isDark
                      ? 'text-slate-400 hover:text-slate-200'
                      : 'text-slate-600 hover:text-slate-900'
                  }`}
                >
                  {curr === 'NGN' ? '₦ NGN' : curr === 'USD' ? '$ USD' : '⨇ MONAD'}
                </button>
              );
            })}
          </div>
        </div>

        {/* Scrollable Screen Body */}
        <main className={`flex-1 overflow-y-auto px-4 pt-3 pb-6 scrollbar-none ${isDark ? 'bg-[#060b17]' : 'bg-slate-50'} transition-colors`}>
          {activeTab === 'home' && (
            <WalletHome
              user={user}
              ledger={ledger}
              fxRates={fxRates}
              displayCurrency={user.displayCurrency}
              transactions={transactions}
              onOpenFund={handleOpenFund}
              onNavigateToPay={() => setActiveTab('pay')}
              onNavigateToScan={() => setActiveTab('pay')}
              onNavigateToCards={() => setActiveTab('cards')}
              onNavigateToEarn={() => setActiveTab('earn')}
              onSelectTx={(tx) => setSelectedTx(tx)}
            />
          )}

          {activeTab === 'pay' && (
            <PayAndScan
              initialTab="scan"
              ledger={ledger}
              fxRates={fxRates}
              displayCurrency={user.displayCurrency}
              onPayNQR={handlePayNQR}
              onTransfer={handleTransfer}
              onRequestPin={promptPin}
            />
          )}

          {activeTab === 'cards' && (
            <CardsView
              cards={cards}
              displayCurrency={user.displayCurrency}
              fxRates={fxRates}
              onToggleFreeze={handleToggleFreeze}
              onRevealCard={handleRevealCard}
              onIssueCard={handleIssueCard}
              onRequestPin={promptPin}
            />
          )}

          {activeTab === 'earn' && (
            <EarnVault
              earnVault={earnVault}
              ledger={ledger}
              fxRates={fxRates}
              onDeposit={handleEarnDeposit}
              onWithdraw={handleEarnWithdraw}
            />
          )}

          {activeTab === 'settings' && (
            <div className="space-y-4">
              <SettingsView
                user={user}
                onUpdatePin={() =>
                  promptPin(
                    async (newPin) => {
                      await fetch('/api/security/pin', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ pin: newPin }),
                      });
                      alert('Transaction PIN updated successfully');
                    },
                    'Set New 4-Digit PIN',
                    'Choose a secure 4-digit code for all authorization approvals'
                  )
                }
                onSimulateKyc={async () => {
                  await fetch('/api/kyc/verify', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                  });
                  refreshData();
                }}
              />
            </div>
          )}
        </main>

        {/* Native Bottom Navigation Bar */}
        <nav
          className={`shrink-0 border-t ${
            isDark ? 'border-blue-950/80 bg-[#040814]/98' : 'border-slate-200 bg-white/98 shadow-lg'
          } backdrop-blur-xl px-2 pt-2 pb-5 z-20 transition-colors`}
        >
          <div className="grid grid-cols-5 gap-1">
            {[
              { id: 'home', label: 'Wallet', icon: Wallet },
              { id: 'pay', label: 'Pay & Scan', icon: Send },
              { id: 'cards', label: 'Cards', icon: CreditCard },
              { id: 'earn', label: 'Earn', icon: TrendingUp },
              { id: 'settings', label: 'Settings', icon: Settings },
            ].map(({ id, label, icon: Icon }) => {
              const active = activeTab === id;
              return (
                <button
                  key={id}
                  onClick={() => setActiveTab(id as any)}
                  className={`flex flex-col items-center justify-center py-1 rounded-xl transition-all ${
                    active
                      ? isDark
                        ? 'text-blue-400 scale-105'
                        : 'text-blue-600 scale-105 font-bold'
                      : isDark
                      ? 'text-slate-500 hover:text-slate-300'
                      : 'text-slate-400 hover:text-slate-700'
                  }`}
                >
                  <Icon className={`w-5 h-5 mb-1 ${active ? 'stroke-[2.5]' : ''}`} />
                  <span className="text-[10px] font-bold">{label}</span>
                </button>
              );
            })}
          </div>

          {/* iPhone Home Indicator */}
          <div className={`w-32 h-1 rounded-full ${isDark ? 'bg-blue-900/40' : 'bg-slate-300'} mx-auto mt-2 transition-colors`} />
        </nav>
      </div>

      {/* Nigerian Bank Transfer Deposit Modal */}
      <FundModal
        isOpen={isFundOpen}
        onClose={() => setIsFundOpen(false)}
        virtualAccount={virtualAccount}
        onSimulateDeposit={handleSimulateDeposit}
      />

      {/* 4-Digit Transaction PIN Modal */}
      <PinModal
        isOpen={pinModalConfig.isOpen}
        onClose={() => setPinModalConfig((prev) => ({ ...prev, isOpen: false }))}
        onSuccess={pinModalConfig.onSuccess}
        title={pinModalConfig.title}
        description={pinModalConfig.description}
      />

      {/* Transaction Detail Receipt Bottom Sheet */}
      <TransactionReceiptSheet tx={selectedTx} onClose={() => setSelectedTx(null)} />
    </div>
  );
}
