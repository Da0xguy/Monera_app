import React, { useState } from 'react';
import {
  Eye,
  EyeOff,
  Plus,
  Send,
  QrCode,
  CreditCard,
  TrendingUp,
  ArrowUpRight,
  ArrowDownLeft,
  Clock,
  Sparkles,
  ExternalLink,
  ShieldCheck,
  CheckCircle2,
} from 'lucide-react';
import { DisplayCurrency, FxRates, LedgerAccount, LedgerEntry, UserProfile } from '../types';
import { MoneraLogo } from './MoneraLogo';
import { useTheme } from '../context/ThemeContext';

interface WalletHomeProps {
  user: UserProfile;
  ledger: LedgerAccount;
  fxRates: FxRates;
  displayCurrency: DisplayCurrency;
  transactions: LedgerEntry[];
  onOpenFund: () => void;
  onNavigateToPay: () => void;
  onNavigateToScan: () => void;
  onNavigateToCards: () => void;
  onNavigateToEarn: () => void;
  onSelectTx?: (tx: LedgerEntry) => void;
}

export const WalletHome: React.FC<WalletHomeProps> = ({
  user,
  ledger,
  fxRates,
  displayCurrency,
  transactions,
  onOpenFund,
  onNavigateToPay,
  onNavigateToScan,
  onNavigateToCards,
  onNavigateToEarn,
  onSelectTx,
}) => {
  const { isDark } = useTheme();
  const [showBalance, setShowBalance] = useState<boolean>(true);

  // Format currency display
  const getFormattedBalance = (amountUsd: number) => {
    if (!showBalance) return '••••••••';
    if (displayCurrency === 'NGN') {
      const ngn = amountUsd * fxRates.USD_NGN;
      return `₦${ngn.toLocaleString('en-NG', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }
    if (displayCurrency === 'MONAD') {
      const monad = amountUsd / fxRates.MONAD_USD;
      return `⨇ ${monad.toFixed(4)} MONAD`;
    }
    return `$${amountUsd.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  };

  const getSubtextEquivalent = (amountUsd: number) => {
    if (displayCurrency === 'NGN') {
      return `≈ $${amountUsd.toFixed(2)} USDC on Monad`;
    }
    const ngn = amountUsd * fxRates.USD_NGN;
    return `≈ ₦${ngn.toLocaleString()} NGN`;
  };

  return (
    <div className="space-y-6 pb-20">
      {/* Top Greeting & KYC Status */}
      <div className="flex items-center justify-between">
        <div>
          <p className={`text-xs font-medium ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>Welcome back,</p>
          <h2 className={`text-xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-slate-900'}`}>{user.name}</h2>
        </div>
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold">
          <ShieldCheck className="w-3.5 h-3.5" />
          <span>Tier 3 KYC Verified</span>
        </div>
      </div>

      {/* Main Balance Card (Dark gradient with Monad blue glow) */}
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#0c2340] via-[#071329] to-[#030712] border border-blue-600/30 p-6 shadow-2xl shadow-blue-950/40">
        {/* Monera Emblem Watermark */}
        <div className="absolute -right-4 -bottom-4 opacity-10 pointer-events-none text-cyan-400">
          <MoneraLogo variant="icon" size={140} />
        </div>

        {/* Glow orb */}
        <div className="absolute -top-16 -right-16 w-44 h-44 rounded-full bg-blue-500/15 blur-3xl pointer-events-none" />
        <div className="absolute -bottom-16 -left-16 w-44 h-44 rounded-full bg-cyan-500/10 blur-3xl pointer-events-none" />

        <div className="relative z-10">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-blue-200/70 font-semibold tracking-wider uppercase flex items-center gap-1.5">
              Available Spend Balance
            </span>
            <button
              onClick={() => setShowBalance(!showBalance)}
              className="p-1.5 rounded-lg text-slate-400 hover:text-white bg-white/5 hover:bg-white/10 transition-colors"
              title={showBalance ? 'Hide balance' : 'Reveal balance'}
            >
              {showBalance ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>

          <div className="mb-2">
            <div className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight font-mono">
              {getFormattedBalance(ledger.availableBalanceUsd)}
            </div>
            {showBalance && (
              <p className="text-xs text-cyan-300/80 font-medium mt-1">
                {getSubtextEquivalent(ledger.availableBalanceUsd)}
              </p>
            )}
          </div>

          {/* Sub-strip with Monad L1 Finality and Earned Yield */}
          <div className="flex items-center justify-between pt-4 mt-4 border-t border-blue-950/80 text-xs">
            <div className="flex items-center gap-2 text-slate-300">
              <span className="w-2 h-2 rounded-full bg-blue-400 animate-ping" />
              <span>Monad L1 • ~600ms finality</span>
            </div>
            <button
              onClick={onNavigateToEarn}
              className="flex items-center gap-1 text-cyan-400 hover:text-cyan-300 font-semibold transition-colors"
            >
              <TrendingUp className="w-3.5 h-3.5" />
              <span>Earn 8.4% APY</span>
            </button>
          </div>
        </div>
      </div>

      {/* Primary Quick Actions */}
      <div className="grid grid-cols-4 gap-2.5 sm:gap-4">
        <button
          onClick={onOpenFund}
          className={`flex flex-col items-center justify-center p-3 sm:p-4 rounded-2xl border active:scale-95 transition-all group ${
            isDark
              ? 'bg-[#0a1224] hover:bg-[#0f1b36] border-blue-900/30 text-slate-200'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-800 shadow-xs'
          }`}
        >
          <div className="w-11 h-11 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <Plus className="w-5 h-5" />
          </div>
          <span className={`text-xs font-semibold ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>Add Money</span>
        </button>

        <button
          onClick={onNavigateToPay}
          className={`flex flex-col items-center justify-center p-3 sm:p-4 rounded-2xl border active:scale-95 transition-all group ${
            isDark
              ? 'bg-[#0a1224] hover:bg-[#0f1b36] border-blue-900/30 text-slate-200'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-800 shadow-xs'
          }`}
        >
          <div className="w-11 h-11 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-500 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <Send className="w-5 h-5" />
          </div>
          <span className={`text-xs font-semibold ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>Send</span>
        </button>

        <button
          onClick={onNavigateToScan}
          className={`flex flex-col items-center justify-center p-3 sm:p-4 rounded-2xl border active:scale-95 transition-all group ${
            isDark
              ? 'bg-[#0a1224] hover:bg-[#0f1b36] border-blue-900/30 text-slate-200'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-800 shadow-xs'
          }`}
        >
          <div className="w-11 h-11 rounded-xl bg-cyan-500/10 border border-cyan-500/20 text-cyan-500 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <QrCode className="w-5 h-5" />
          </div>
          <span className={`text-xs font-semibold ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>Scan NQR</span>
        </button>

        <button
          onClick={onNavigateToCards}
          className={`flex flex-col items-center justify-center p-3 sm:p-4 rounded-2xl border active:scale-95 transition-all group ${
            isDark
              ? 'bg-[#0a1224] hover:bg-[#0f1b36] border-blue-900/30 text-slate-200'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-800 shadow-xs'
          }`}
        >
          <div className="w-11 h-11 rounded-xl bg-sky-500/10 border border-sky-500/20 text-sky-500 flex items-center justify-center mb-2 group-hover:scale-110 transition-transform">
            <CreditCard className="w-5 h-5" />
          </div>
          <span className={`text-xs font-semibold ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>Cards</span>
        </button>
      </div>

      {/* Spend Adapter Teaser / Status Card */}
      <div
        className={`p-4 rounded-2xl border flex items-center justify-between transition-colors ${
          isDark
            ? 'bg-gradient-to-r from-blue-950/40 via-[#071329] to-slate-950 border-blue-800/30'
            : 'bg-white border-slate-200 shadow-xs'
        }`}
      >
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-blue-500/20 text-blue-500 flex items-center justify-center">
            <Sparkles className="w-4 h-4" />
          </div>
          <div>
            <h4 className={`text-xs font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>
              Spend Adapter: Nigeria Active
            </h4>
            <p className={`text-[11px] ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
              Sudo Mastercard JIT & NIBSS NQR ready
            </p>
          </div>
        </div>
        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-500 border border-emerald-500/20">
          Ready
        </span>
      </div>

      {/* Recent Ledger Transactions */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h3 className={`text-sm font-bold tracking-wide uppercase ${isDark ? 'text-slate-200' : 'text-slate-700'}`}>
            Recent Transactions
          </h3>
          <span className="text-xs text-blue-500 hover:text-blue-400 cursor-pointer font-medium">
            {transactions.length} items
          </span>
        </div>

        <div className="space-y-2.5">
          {transactions.map((tx) => {
            const isNegative = tx.type === 'spend-card' || tx.type === 'spend-qr' || tx.type === 'transfer-out' || tx.type === 'earn-deposit';
            return (
              <div
                key={tx.id}
                onClick={() => onSelectTx?.(tx)}
                className={`flex items-center justify-between p-3.5 rounded-2xl active:scale-[0.99] cursor-pointer border transition-all ${
                  isDark
                    ? 'bg-[#131926] hover:bg-[#161f30] border-slate-800/70'
                    : 'bg-white hover:bg-slate-50 border-slate-200 shadow-xs'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={`w-10 h-10 rounded-xl flex items-center justify-center ${
                      tx.type === 'fund' || tx.type === 'transfer-in' || tx.type === 'earn-withdraw'
                        ? 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/20'
                        : tx.type === 'spend-card'
                        ? 'bg-purple-500/10 text-purple-500 border border-purple-500/20'
                        : tx.type === 'spend-qr'
                        ? 'bg-indigo-500/10 text-indigo-500 border border-indigo-500/20'
                        : 'bg-slate-500/10 text-slate-500 border border-slate-500/20'
                    }`}
                  >
                    {tx.type === 'fund' ? (
                      <ArrowDownLeft className="w-5 h-5" />
                    ) : tx.type === 'spend-card' ? (
                      <CreditCard className="w-5 h-5" />
                    ) : tx.type === 'spend-qr' ? (
                      <QrCode className="w-5 h-5" />
                    ) : (
                      <ArrowUpRight className="w-5 h-5" />
                    )}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className={`text-xs font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>{tx.title}</h4>
                      {tx.latencyMs && (
                        <span className="text-[9px] font-mono px-1.5 py-0.2 rounded bg-purple-500/10 text-purple-400 border border-purple-500/20">
                          {tx.latencyMs}ms JIT
                        </span>
                      )}
                    </div>
                    <p className={`text-[11px] ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>{tx.description}</p>
                  </div>
                </div>

                <div className="text-right">
                  <div
                    className={`text-xs font-bold font-mono ${
                      isNegative ? (isDark ? 'text-slate-100' : 'text-slate-900') : 'text-emerald-500'
                    }`}
                  >
                    {isNegative ? '-' : '+'}
                    {displayCurrency === 'NGN'
                      ? `₦${tx.amountNgn.toLocaleString('en-NG', { minimumFractionDigits: 2 })}`
                      : displayCurrency === 'MONAD'
                      ? `⨇ ${(tx.amountUsd / fxRates.MONAD_USD).toFixed(3)}`
                      : `$${tx.amountUsd.toFixed(2)}`}
                  </div>
                  <div className="flex items-center justify-end gap-1 text-[10px] text-slate-400">
                    <Clock className="w-3 h-3" />
                    <span>{new Date(tx.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
