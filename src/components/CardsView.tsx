import React, { useState } from 'react';
import {
  CreditCard,
  Lock,
  Unlock,
  Eye,
  EyeOff,
  Plus,
  ShieldCheck,
  CheckCircle2,
  Sparkles,
  RefreshCw,
  Copy,
  Check,
  Zap,
} from 'lucide-react';
import { CardItem, DisplayCurrency, FxRates } from '../types';
import { MoneraLogo } from './MoneraLogo';
import { useTheme } from '../context/ThemeContext';

interface CardsViewProps {
  cards: CardItem[];
  displayCurrency: DisplayCurrency;
  fxRates: FxRates;
  onToggleFreeze: (cardId: string) => Promise<void>;
  onRevealCard: (cardId: string, pin: string) => Promise<{ pan: string; cvv: string; expiry: string }>;
  onIssueCard: (type: 'virtual' | 'physical') => Promise<void>;
  onRequestPin: (callback: (pin: string) => void) => void;
}

export const CardsView: React.FC<CardsViewProps> = ({
  cards,
  displayCurrency,
  fxRates,
  onToggleFreeze,
  onRevealCard,
  onIssueCard,
  onRequestPin,
}) => {
  const { isDark } = useTheme();
  const [selectedCardIndex, setSelectedCardIndex] = useState(0);
  const [revealedData, setRevealedData] = useState<{ pan: string; cvv: string; expiry: string } | null>(null);
  const [isRevealed, setIsRevealed] = useState(false);
  const [copiedField, setCopiedField] = useState<string | null>(null);
  const [isIssuing, setIsIssuing] = useState(false);

  const activeCard = cards[selectedCardIndex] || cards[0];

  const handleReveal = () => {
    if (isRevealed) {
      setIsRevealed(false);
      setRevealedData(null);
      return;
    }

    onRequestPin(async (pin) => {
      try {
        const data = await onRevealCard(activeCard.id, pin);
        setRevealedData(data);
        setIsRevealed(true);
      } catch (err) {
        alert('Failed to reveal card credentials');
      }
    });
  };

  const copyToClipboard = (text: string, field: string) => {
    navigator.clipboard.writeText(text);
    setCopiedField(field);
    setTimeout(() => setCopiedField(null), 1500);
  };

  return (
    <div className="space-y-6 pb-20">
      {/* Top Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className={`text-xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-slate-900'}`}>Spend Cards</h2>
          <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>Sudo Africa Mastercard with JIT Webhooks</p>
        </div>

        <button
          onClick={async () => {
            setIsIssuing(true);
            try {
              await onIssueCard('virtual');
            } finally {
              setIsIssuing(false);
            }
          }}
          disabled={isIssuing}
          className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs shadow-md transition-all disabled:opacity-50"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>New Card</span>
        </button>
      </div>

      {/* Card Selector Pills if multiple */}
      {cards.length > 1 && (
        <div className="flex gap-2">
          {cards.map((c, idx) => (
            <button
              key={c.id}
              onClick={() => {
                setSelectedCardIndex(idx);
                setIsRevealed(false);
                setRevealedData(null);
              }}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all ${
                selectedCardIndex === idx
                  ? isDark
                    ? 'bg-blue-950/80 border-blue-500 text-white shadow-xs shadow-blue-500/20'
                    : 'bg-blue-50 border-blue-600 text-blue-900 shadow-xs'
                  : isDark
                  ? 'bg-slate-950 border-blue-950 text-slate-400'
                  : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50'
              }`}
            >
              {c.type === 'virtual' ? 'Virtual' : 'Physical'} •••• {c.last4}
            </button>
          ))}
        </div>
      )}

      {/* 3D Visual Mastercard */}
      {activeCard && (
        <div className="relative">
          <div
            className={`w-full aspect-[1.58/1] rounded-3xl p-6 relative overflow-hidden shadow-2xl transition-all duration-300 ${
              activeCard.status === 'frozen'
                ? 'bg-gradient-to-tr from-slate-950 via-slate-900 to-slate-950 border border-slate-700 opacity-70 grayscale'
                : activeCard.colorTheme === 'purple' || activeCard.colorTheme === 'blue'
                ? 'bg-gradient-to-tr from-[#1d4ed8] via-[#091e42] to-[#020617] border border-blue-500/40 shadow-blue-950/50'
                : 'bg-gradient-to-tr from-[#0b172a] via-[#050b14] to-[#020617] border border-blue-600/30'
            }`}
          >
            {/* Background Hologram circles & Monera watermark */}
            <div className="absolute -top-12 -right-12 w-48 h-48 rounded-full bg-blue-400/10 blur-xl pointer-events-none" />
            <div className="absolute -bottom-10 -left-10 w-44 h-44 rounded-full bg-cyan-500/10 blur-xl pointer-events-none" />
            <div className="absolute right-6 top-1/2 -translate-y-1/2 opacity-[0.07] pointer-events-none text-white">
              <MoneraLogo variant="icon" size={120} />
            </div>

            {/* Top row: Brand & Chip */}
            <div className="flex justify-between items-start mb-6 relative z-10">
              <div className="flex items-center gap-3">
                <div className="w-10 h-7 rounded-md bg-gradient-to-br from-amber-300 via-amber-400 to-amber-600 shadow-inner flex items-center justify-center p-1">
                  <div className="w-full h-full border border-amber-900/40 rounded-[2px] grid grid-cols-2 gap-0.5 opacity-60">
                    <div className="border-r border-b border-amber-900/40" />
                    <div className="border-b border-amber-900/40" />
                  </div>
                </div>
                <MoneraLogo variant="horizontal" size={16} color="white" />
                <span className="text-[9px] font-mono tracking-wider uppercase text-white/50 border border-white/10 px-1.5 py-0.5 rounded">
                  {activeCard.type}
                </span>
              </div>

              {/* Mastercard circles */}
              <div className="flex items-center">
                <div className="w-7 h-7 rounded-full bg-red-500/90 shadow-md" />
                <div className="w-7 h-7 rounded-full bg-amber-500/90 -ml-3 shadow-md mix-blend-screen" />
              </div>
            </div>

            {/* Middle row: Card Number */}
            <div className="mb-4">
              <div className="text-xl sm:text-2xl font-mono font-bold tracking-[0.2em] text-white flex items-center gap-3">
                {isRevealed && revealedData ? (
                  <span>{revealedData.pan}</span>
                ) : (
                  <span>{activeCard.maskedPan}</span>
                )}
              </div>
            </div>

            {/* Bottom row: Cardholder, Expiry, CVV */}
            <div className="flex justify-between items-end text-white text-xs">
              <div>
                <span className="text-[9px] uppercase tracking-wider text-white/50 block">Cardholder</span>
                <span className="font-semibold tracking-wide">{activeCard.cardholderName}</span>
              </div>

              <div className="flex items-center gap-4">
                <div>
                  <span className="text-[9px] uppercase tracking-wider text-white/50 block">Expires</span>
                  <span className="font-mono font-semibold">
                    {isRevealed && revealedData ? revealedData.expiry : `${activeCard.expiryMonth}/${activeCard.expiryYear}`}
                  </span>
                </div>
                <div>
                  <span className="text-[9px] uppercase tracking-wider text-white/50 block">CVV</span>
                  <span className="font-mono font-bold text-amber-300">
                    {isRevealed && revealedData ? revealedData.cvv : '•••'}
                  </span>
                </div>
              </div>
            </div>

            {/* Frozen Watermark if frozen */}
            {activeCard.status === 'frozen' && (
              <div className="absolute inset-0 bg-black/60 backdrop-blur-[2px] flex items-center justify-center text-white font-bold tracking-widest text-sm gap-2">
                <Lock className="w-4 h-4 text-cyan-400" />
                <span>CARD FROZEN</span>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Card Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <button
          onClick={handleReveal}
          className={`flex items-center justify-center gap-2 p-3.5 rounded-2xl border font-bold text-xs transition-all shadow-xs ${
            isDark
              ? 'bg-[#131926] hover:bg-[#182133] border-slate-800 text-white'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-800'
          }`}
        >
          {isRevealed ? <EyeOff className="w-4 h-4 text-blue-500" /> : <Eye className="w-4 h-4 text-blue-500" />}
          <span>{isRevealed ? 'Hide Details' : 'Reveal PAN & CVV'}</span>
        </button>

        <button
          onClick={() => onToggleFreeze(activeCard.id)}
          className={`flex items-center justify-center gap-2 p-3.5 rounded-2xl border font-bold text-xs transition-all shadow-xs ${
            activeCard.status === 'frozen'
              ? 'bg-cyan-500/15 border-cyan-500/40 text-cyan-300'
              : isDark
              ? 'bg-[#131926] hover:bg-[#182133] border-slate-800 text-white'
              : 'bg-white hover:bg-slate-50 border-slate-200 text-slate-800'
          }`}
        >
          {activeCard.status === 'frozen' ? (
            <>
              <Unlock className="w-4 h-4 text-cyan-400" />
              <span>Unfreeze Card</span>
            </>
          ) : (
            <>
              <Lock className="w-4 h-4 text-cyan-500" />
              <span>Freeze Card</span>
            </>
          )}
        </button>
      </div>

      {/* Revealed Details Box for Easy Copying */}
      {isRevealed && revealedData && (
        <div
          className={`p-4 rounded-2xl border space-y-2 animate-in fade-in shadow-md ${
            isDark ? 'bg-[#071329] border-blue-500/40' : 'bg-white border-blue-200'
          }`}
        >
          <div className="flex justify-between items-center text-xs">
            <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Card Number:</span>
            <button
              onClick={() => copyToClipboard(revealedData.pan.replace(/\s/g, ''), 'pan')}
              className={`flex items-center gap-1 font-mono hover:underline ${
                isDark ? 'text-cyan-300' : 'text-blue-600'
              }`}
            >
              <span>{revealedData.pan}</span>
              {copiedField === 'pan' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
            </button>
          </div>
          <div className="flex justify-between items-center text-xs">
            <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>CVV:</span>
            <button
              onClick={() => copyToClipboard(revealedData.cvv, 'cvv')}
              className={`flex items-center gap-1 font-mono hover:underline ${
                isDark ? 'text-amber-300' : 'text-amber-600 font-bold'
              }`}
            >
              <span>{revealedData.cvv}</span>
              {copiedField === 'cvv' ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
            </button>
          </div>
        </div>
      )}

      {/* Spending Limit Progress */}
      <div
        className={`p-5 rounded-2xl border space-y-3 transition-colors ${
          isDark ? 'bg-[#091224] border-blue-950/80 shadow-md' : 'bg-white border-slate-200 shadow-xs'
        }`}
      >
        <div className="flex justify-between items-center text-xs">
          <span className={`font-semibold ${isDark ? 'text-slate-400' : 'text-slate-600'}`}>Monthly Spend Limit</span>
          <span className={`font-mono ${isDark ? 'text-slate-200' : 'text-slate-800 font-bold'}`}>
            ₦{activeCard.spentThisMonthNgn.toLocaleString()} / ₦{activeCard.spendingLimitNgn.toLocaleString()}
          </span>
        </div>

        <div className={`w-full h-2 rounded-full overflow-hidden ${isDark ? 'bg-slate-900' : 'bg-slate-200'}`}>
          <div
            className="h-full rounded-full bg-gradient-to-r from-blue-600 via-blue-500 to-cyan-400 transition-all duration-500"
            style={{
              width: `${Math.min(
                100,
                (activeCard.spentThisMonthNgn / activeCard.spendingLimitNgn) * 100
              )}%`,
            }}
          />
        </div>

        <div className={`flex items-center justify-between text-[11px] pt-1 ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
          <span className="flex items-center gap-1 text-blue-500 font-medium">
            <Zap className="w-3.5 h-3.5" /> JIT Webhook Protected
          </span>
          <span>Resets on 1st of month</span>
        </div>
      </div>
    </div>
  );
};
