import React, { useState, useEffect } from 'react';
import {
  TrendingUp,
  Shield,
  ArrowUpRight,
  ArrowDownLeft,
  Info,
  CheckCircle2,
  ExternalLink,
  Coins,
} from 'lucide-react';
import { EarnVaultState, FxRates, LedgerAccount } from '../types';
import { useTheme } from '../context/ThemeContext';

interface EarnVaultProps {
  earnVault: EarnVaultState;
  ledger: LedgerAccount;
  fxRates: FxRates;
  onDeposit: (amountUsd: number) => Promise<void>;
  onWithdraw: (amountUsd: number) => Promise<void>;
}

export const EarnVault: React.FC<EarnVaultProps> = ({
  earnVault,
  ledger,
  fxRates,
  onDeposit,
  onWithdraw,
}) => {
  const { isDark } = useTheme();
  const [activeModal, setActiveModal] = useState<'deposit' | 'withdraw' | null>(null);
  const [amount, setAmount] = useState<number>(100);
  const [loading, setLoading] = useState(false);
  const [tickingYield, setTickingYield] = useState<number>(earnVault.userAccruedYieldUsd);

  // Live ticking yield counter animation to showcase real-time Monad performance
  useEffect(() => {
    const interval = setInterval(() => {
      // Small fractional increment every second based on principal & APY
      const perSecondIncrement = (earnVault.userPrincipalUsd * (earnVault.apyPercent / 100)) / (365 * 86400);
      setTickingYield((prev) => prev + perSecondIncrement);
    }, 1000);
    return () => clearInterval(interval);
  }, [earnVault.userPrincipalUsd, earnVault.apyPercent]);

  const handleAction = async () => {
    if (!amount || amount <= 0) return;
    setLoading(true);
    try {
      if (activeModal === 'deposit') {
        await onDeposit(amount);
      } else {
        await onWithdraw(amount);
      }
      setActiveModal(null);
    } catch (err: any) {
      alert(err.message || 'Operation failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6 pb-20">
      {/* Top Banner */}
      <div>
        <h2 className={`text-xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-slate-900'}`}>Treasury Vault</h2>
        <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
          Earn yield on idle stablecoin balances on Monad L1
        </p>
      </div>

      {/* Yield Hero Card */}
      <div className={`relative overflow-hidden rounded-3xl p-6 shadow-2xl transition-all ${
        isDark 
          ? 'bg-gradient-to-br from-[#0c2419] via-[#0f1d1e] to-[#0c1322] border border-emerald-500/30'
          : 'bg-gradient-to-br from-emerald-600 via-teal-700 to-slate-900 text-white border border-emerald-500/20'
      }`}>
        <div className="flex justify-between items-start mb-4">
          <div>
            <span className="text-[11px] font-semibold text-emerald-300 tracking-wider uppercase flex items-center gap-1.5">
              <TrendingUp className="w-3.5 h-3.5" />
              Annual Percentage Yield
            </span>
            <div className="text-4xl font-extrabold text-white font-mono mt-1">
              {earnVault.apyPercent.toFixed(1)}% <span className="text-sm font-sans font-medium text-emerald-300">APY</span>
            </div>
          </div>

          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-white/15 text-emerald-200 border border-white/20">
            Auto-Compounding
          </span>
        </div>

        <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/15">
          <div>
            <span className="text-[10px] text-slate-300 block uppercase">Your Principal</span>
            <span className="text-lg font-bold text-white font-mono">
              ${earnVault.userPrincipalUsd.toFixed(2)}
            </span>
          </div>

          <div>
            <span className="text-[10px] text-slate-300 block uppercase">Accrued Yield (Live)</span>
            <span className="text-lg font-bold text-emerald-300 font-mono">
              +${tickingYield.toFixed(4)}
            </span>
          </div>
        </div>
      </div>

      {/* Quick Deposit & Withdraw Buttons */}
      <div className="grid grid-cols-2 gap-3">
        <button
          onClick={() => {
            setAmount(Math.min(100, Math.floor(ledger.availableBalanceUsd)));
            setActiveModal('deposit');
          }}
          className="flex items-center justify-center gap-2 p-3.5 rounded-2xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold text-xs shadow-lg shadow-emerald-950/20 transition-all"
        >
          <ArrowDownLeft className="w-4 h-4" />
          <span>Deposit to Earn</span>
        </button>

        <button
          onClick={() => {
            setAmount(Math.min(100, Math.floor(earnVault.userPrincipalUsd)));
            setActiveModal('withdraw');
          }}
          disabled={earnVault.userPrincipalUsd <= 0}
          className={`flex items-center justify-center gap-2 p-3.5 rounded-2xl border font-bold text-xs transition-all disabled:opacity-50 ${
            isDark
              ? 'bg-[#131926] hover:bg-[#182133] border-slate-800 text-slate-200'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-700 shadow-xs'
          }`}
        >
          <ArrowUpRight className="w-4 h-4" />
          <span>Withdraw to Spend</span>
        </button>
      </div>

      {/* Contract & Pool details */}
      <div className={`p-5 rounded-2xl border space-y-3 text-xs transition-colors ${
        isDark ? 'bg-[#131926] border-slate-800/80' : 'bg-white border-slate-200 shadow-xs'
      }`}>
        <div className="flex justify-between">
          <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Smart Contract:</span>
          <span className="font-mono text-blue-500">TreasuryVault.sol</span>
        </div>
        <div className="flex justify-between">
          <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Total Vault Liquidity:</span>
          <span className={`font-mono ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>${earnVault.totalPooledUsd.toLocaleString()} USDC</span>
        </div>
        <div className="flex justify-between">
          <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Underlying Network:</span>
          <span className={`font-medium ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>Monad L1 (Chain ID: 10143)</span>
        </div>
        <div className="flex justify-between">
          <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Withdrawal Lockup:</span>
          <span className="text-emerald-500 font-medium">None (Instant Liquidity)</span>
        </div>
      </div>

      {/* Deposit / Withdraw Modal */}
      {activeModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
          <div className={`border rounded-3xl w-full max-w-sm p-6 shadow-2xl relative space-y-4 ${
            isDark ? 'bg-[#121824] border-slate-800' : 'bg-white border-slate-200'
          }`}>
            <h3 className={`text-base font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>
              {activeModal === 'deposit' ? 'Deposit Idle Funds to Earn' : 'Withdraw Principal to Spend'}
            </h3>

            <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
              {activeModal === 'deposit'
                ? `Available in Spend Ledger: $${ledger.availableBalanceUsd.toFixed(2)}`
                : `Active Principal in Vault: $${earnVault.userPrincipalUsd.toFixed(2)}`}
            </p>

            <div className="relative">
              <input
                type="number"
                value={amount}
                onChange={(e) => setAmount(Number(e.target.value))}
                className={`w-full pl-8 pr-16 py-3 rounded-xl border font-mono font-bold text-lg focus:outline-none focus:border-emerald-500 ${
                  isDark ? 'bg-slate-900 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-900'
                }`}
              />
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 font-bold">$</span>
              <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 font-semibold">USDC</span>
            </div>

            <div className="flex gap-2">
              <button
                onClick={() => setActiveModal(null)}
                className={`flex-1 py-3 rounded-xl font-bold text-xs ${
                  isDark ? 'bg-slate-800 hover:bg-slate-700 text-slate-300' : 'bg-slate-100 hover:bg-slate-200 text-slate-700'
                }`}
              >
                Cancel
              </button>
              <button
                onClick={handleAction}
                disabled={loading}
                className="flex-1 py-3 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs flex items-center justify-center gap-1.5 disabled:opacity-50"
              >
                {loading ? (
                  <span className="inline-block animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                ) : (
                  <span>Confirm</span>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
