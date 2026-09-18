import React, { useState } from 'react';
import { X, Copy, Check, Building2, AlertCircle, ArrowUpRight, Sparkles } from 'lucide-react';
import { VirtualAccountInfo } from '../types';
import { useTheme } from '../context/ThemeContext';

interface FundModalProps {
  isOpen: boolean;
  onClose: () => void;
  virtualAccount: VirtualAccountInfo | null;
  onSimulateDeposit: (amountNgn: number) => Promise<void>;
}

export const FundModal: React.FC<FundModalProps> = ({
  isOpen,
  onClose,
  virtualAccount,
  onSimulateDeposit,
}) => {
  const { isDark } = useTheme();
  const [copied, setCopied] = useState(false);
  const [simAmount, setSimAmount] = useState<number>(100000);
  const [isDepositing, setIsDepositing] = useState(false);
  const [depositSuccess, setDepositSuccess] = useState(false);

  if (!isOpen) return null;

  const handleCopy = () => {
    if (virtualAccount?.accountNumber) {
      navigator.clipboard.writeText(virtualAccount.accountNumber);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handleSimulate = async () => {
    setIsDepositing(true);
    try {
      await onSimulateDeposit(simAmount);
      setDepositSuccess(true);
      setTimeout(() => {
        setDepositSuccess(false);
        onClose();
      }, 1400);
    } finally {
      setIsDepositing(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-sm p-0 sm:p-4 animate-in fade-in duration-200">
      <div className={`border rounded-t-3xl sm:rounded-3xl w-full max-w-md p-6 shadow-2xl relative max-h-[90vh] overflow-y-auto transition-colors ${
        isDark ? 'bg-[#121824] border-slate-800' : 'bg-white border-slate-200'
      }`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 p-2 rounded-full transition-colors ${
            isDark
              ? 'text-slate-400 hover:text-white bg-slate-800/50 hover:bg-slate-800'
              : 'text-slate-500 hover:text-slate-800 bg-slate-100 hover:bg-slate-200'
          }`}
        >
          <X className="w-5 h-5" />
        </button>

        <div className="flex items-center gap-3 mb-5">
          <div className="w-11 h-11 rounded-2xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 flex items-center justify-center">
            <Building2 className="w-6 h-6" />
          </div>
          <div>
            <h3 className={`text-lg font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>Add Money via Bank</h3>
            <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>NGN Inbound Rail & Stablecoin Auto-Credit</p>
          </div>
        </div>

        {/* Virtual Account Card */}
        <div className={`border rounded-2xl p-5 mb-5 shadow-inner transition-colors ${
          isDark
            ? 'bg-gradient-to-br from-slate-900 via-[#161d2b] to-slate-900 border-slate-800'
            : 'bg-gradient-to-br from-slate-50 via-slate-100 to-slate-50 border-slate-200'
        }`}>
          <div className="flex justify-between items-start mb-3">
            <span className={`text-xs font-medium ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>Bank Name</span>
            <span className="text-xs font-semibold text-emerald-500 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full">
              Instant Credit
            </span>
          </div>
          <p className={`text-sm font-bold mb-4 ${isDark ? 'text-white' : 'text-slate-900'}`}>
            {virtualAccount?.bankName || 'Wema Bank (Monera Reserve)'}
          </p>

          <div className={`flex justify-between items-end border rounded-xl p-3 mb-4 transition-colors ${
            isDark ? 'bg-black/40 border-slate-800/80' : 'bg-white border-slate-200 shadow-xs'
          }`}>
            <div>
              <span className={`text-[10px] block uppercase tracking-wider mb-0.5 ${
                isDark ? 'text-slate-400' : 'text-slate-500'
              }`}>Account Number</span>
              <span className={`text-2xl font-mono font-bold tracking-wider ${
                isDark ? 'text-white' : 'text-slate-900'
              }`}>
                {virtualAccount?.accountNumber || '9023481239'}
              </span>
            </div>
            <button
              onClick={handleCopy}
              className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-emerald-500/15 hover:bg-emerald-500/25 text-emerald-600 dark:text-emerald-300 text-xs font-semibold transition-colors"
            >
              {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
              {copied ? 'Copied' : 'Copy'}
            </button>
          </div>

          <div className={`flex justify-between text-xs pt-1 border-t ${
            isDark ? 'text-slate-400 border-slate-800/80' : 'text-slate-500 border-slate-200'
          }`}>
            <span>Account Name:</span>
            <span className={`font-medium ${isDark ? 'text-slate-200' : 'text-slate-800'}`}>
              {virtualAccount?.accountName || 'MONERA / AYOBAMI OKETONA'}
            </span>
          </div>
        </div>

        <div className={`flex items-start gap-2.5 p-3 rounded-xl border mb-6 text-xs ${
          isDark
            ? 'bg-blue-500/5 border-blue-500/15 text-slate-300'
            : 'bg-blue-50 border-blue-200 text-slate-700'
        }`}>
          <AlertCircle className="w-4 h-4 text-blue-500 shrink-0 mt-0.5" />
          <p>
            Funds sent to this account are automatically converted to stablecoin and credited to your Monad non-custodial ledger within seconds.
          </p>
        </div>

        {/* Live Simulation Sandbox for testing */}
        <div className={`border-t pt-5 ${isDark ? 'border-slate-800/80' : 'border-slate-200'}`}>
          <div className="flex items-center justify-between mb-3">
            <span className={`text-xs font-semibold flex items-center gap-1.5 ${
              isDark ? 'text-slate-300' : 'text-slate-700'
            }`}>
              <Sparkles className="w-3.5 h-3.5 text-blue-500" />
              Simulate Inbound Deposit (Sandbox)
            </span>
            <span className={`text-[11px] ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>Instant test</span>
          </div>

          <div className="grid grid-cols-3 gap-2 mb-3">
            {[50000, 100000, 250000].map((amt) => (
              <button
                key={amt}
                onClick={() => setSimAmount(amt)}
                className={`py-2 px-3 rounded-xl text-xs font-semibold border transition-all ${
                  simAmount === amt
                    ? 'bg-blue-600 text-white border-blue-500 shadow-md shadow-blue-900/30'
                    : isDark
                    ? 'bg-slate-900/80 text-slate-300 border-slate-800 hover:border-slate-700'
                    : 'bg-slate-50 text-slate-700 border-slate-200 hover:border-slate-300'
                }`}
              >
                ₦{amt.toLocaleString()}
              </button>
            ))}
          </div>

          <button
            onClick={handleSimulate}
            disabled={isDepositing}
            className="w-full py-3.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold text-sm flex items-center justify-center gap-2 shadow-lg shadow-emerald-950/20 transition-all disabled:opacity-50"
          >
            {isDepositing ? (
              <span className="inline-block animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
            ) : depositSuccess ? (
              <>
                <Check className="w-4 h-4" /> Deposit Credited!
              </>
            ) : (
              <>
                <ArrowUpRight className="w-4 h-4" /> Simulate ₦{simAmount.toLocaleString()} Credit
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};
