import React from 'react';
import { X, CheckCircle2, ArrowDownLeft, ArrowUpRight, Share2, ShieldCheck } from 'lucide-react';
import { LedgerEntry } from '../types';
import { useTheme } from '../context/ThemeContext';

interface TransactionReceiptSheetProps {
  tx: LedgerEntry | null;
  onClose: () => void;
}

export const TransactionReceiptSheet: React.FC<TransactionReceiptSheetProps> = ({ tx, onClose }) => {
  const { isDark } = useTheme();
  if (!tx) return null;

  const isCredit = tx.type === 'fund' || tx.type === 'transfer-in' || tx.type === 'earn-withdraw';

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className={`border-t rounded-t-[36px] w-full max-w-[430px] p-6 shadow-2xl relative animate-in slide-in-from-bottom duration-300 transition-colors ${
        isDark ? 'bg-[#111622] border-slate-800' : 'bg-white border-slate-200'
      }`}>
        {/* Handle bar */}
        <div className={`w-12 h-1.5 rounded-full mx-auto mb-5 ${isDark ? 'bg-slate-700/80' : 'bg-slate-300'}`} />

        {/* Close button */}
        <button
          onClick={onClose}
          className={`absolute right-5 top-5 p-2 rounded-full transition-colors ${
            isDark
              ? 'text-slate-400 hover:text-white bg-slate-800/60'
              : 'text-slate-500 hover:text-slate-900 bg-slate-100'
          }`}
        >
          <X className="w-4 h-4" />
        </button>

        {/* Header with status */}
        <div className="text-center space-y-2 mb-6">
          <div className="w-14 h-14 rounded-2xl mx-auto flex items-center justify-center bg-blue-500/10 border border-blue-500/20 text-blue-500">
            {isCredit ? (
              <ArrowDownLeft className="w-7 h-7 text-emerald-500" />
            ) : (
              <ArrowUpRight className="w-7 h-7 text-blue-500" />
            )}
          </div>
          <h3 className={`text-lg font-bold tracking-tight ${isDark ? 'text-white' : 'text-slate-900'}`}>{tx.title}</h3>
          <p className={`text-xs flex items-center justify-center gap-1.5 ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
            <span>Transaction Settled ({tx.status})</span>
          </p>
          <div className={`text-3xl font-extrabold font-mono pt-1 ${isDark ? 'text-white' : 'text-slate-900'}`}>
            {isCredit ? '+' : '-'}₦{tx.amountNgn.toLocaleString('en-NG', { minimumFractionDigits: 2 })}
          </div>
          <p className={`text-xs font-mono ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
            ≈ ${tx.amountUsd.toFixed(2)} USDC on Monad L1
          </p>
        </div>

        {/* Details card */}
        <div className={`rounded-2xl border p-4 space-y-3 text-xs mb-6 transition-colors ${
          isDark ? 'bg-slate-900/90 border-slate-800/80' : 'bg-slate-50 border-slate-200'
        }`}>
          <div className={`flex justify-between ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
            <span>Channel Rail</span>
            <span className={`font-semibold capitalize ${isDark ? 'text-white' : 'text-slate-900'}`}>{tx.channel.replace('_', ' ')}</span>
          </div>

          <div className={`flex justify-between ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
            <span>Description</span>
            <span className={isDark ? 'text-slate-200' : 'text-slate-700'}>{tx.description}</span>
          </div>

          {tx.authorizationCode && (
            <div className={`flex justify-between ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
              <span>Sudo Auth Code</span>
              <span className="font-mono text-emerald-500 font-semibold">{tx.authorizationCode}</span>
            </div>
          )}

          {tx.latencyMs && (
            <div className={`flex justify-between ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
              <span>JIT Webhook Latency</span>
              <span className="font-mono text-blue-500 font-semibold">{tx.latencyMs}ms (SLO &lt;200ms)</span>
            </div>
          )}

          <div className={`flex justify-between ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
            <span>Date & Time</span>
            <span className={isDark ? 'text-slate-200' : 'text-slate-700'}>{new Date(tx.createdAt).toLocaleString()}</span>
          </div>

          {tx.onChainTxRef && (
            <div className={`flex justify-between items-center pt-2 border-t ${
              isDark ? 'text-slate-400 border-slate-800/80' : 'text-slate-500 border-slate-200'
            }`}>
              <span>Monad Tx Ref</span>
              <span className="font-mono text-blue-500 text-[11px] truncate max-w-[140px]">
                {tx.onChainTxRef.slice(0, 8)}...{tx.onChainTxRef.slice(-6)}
              </span>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => {
              if (navigator.share) {
                navigator
                  .share({
                    title: 'Transaction Receipt',
                    text: `Payment of ₦${tx.amountNgn} to ${tx.title} settled via Monera neobank.`,
                  })
                  .catch(() => {});
              } else {
                alert('Receipt details copied!');
              }
            }}
            className={`py-3.5 rounded-xl font-bold text-xs flex items-center justify-center gap-2 transition-colors ${
              isDark
                ? 'bg-slate-800 hover:bg-slate-700 text-white'
                : 'bg-slate-100 hover:bg-slate-200 text-slate-800'
            }`}
          >
            <Share2 className="w-4 h-4" />
            <span>Share Receipt</span>
          </button>

          <button
            onClick={onClose}
            className="py-3.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs transition-colors"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
};
