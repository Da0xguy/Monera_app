import React from 'react';
import { Shield, Smartphone, Terminal, Wallet, Globe, ArrowLeftRight } from 'lucide-react';
import { DisplayCurrency, UserProfile } from '../types';

interface HeaderBarProps {
  user: UserProfile;
  displayCurrency: DisplayCurrency;
  onCurrencyChange: (currency: DisplayCurrency) => void;
  activeView: 'mobile' | 'studio';
  onViewChange: (view: 'mobile' | 'studio') => void;
  deviceFrame: boolean;
  onToggleDeviceFrame: () => void;
}

export const HeaderBar: React.FC<HeaderBarProps> = ({
  user,
  displayCurrency,
  onCurrencyChange,
  activeView,
  onViewChange,
  deviceFrame,
  onToggleDeviceFrame,
}) => {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-slate-800/80 bg-[#0b0f17]/90 backdrop-blur-md px-4 py-3">
      <div className="max-w-7xl mx-auto flex flex-wrap items-center justify-between gap-3">
        {/* Brand */}
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center text-white font-extrabold shadow-lg shadow-blue-900/40">
            M
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-extrabold text-base tracking-tight text-white">Monera</span>
              <span className="px-1.5 py-0.5 text-[10px] font-bold rounded-md bg-blue-500/15 text-blue-400 border border-blue-500/30">
                Monad L1
              </span>
            </div>
            <p className="text-[11px] text-slate-400">Non-Custodial Neobank & JIT Card Rails</p>
          </div>
        </div>

        {/* Center: Currency selector */}
        <div className="flex items-center bg-slate-900/90 border border-slate-800 rounded-xl p-0.5">
          {(['NGN', 'USD', 'MONAD'] as DisplayCurrency[]).map((curr) => (
            <button
              key={curr}
              onClick={() => onCurrencyChange(curr)}
              className={`px-2.5 py-1 text-xs font-bold rounded-lg transition-all ${
                displayCurrency === curr
                  ? 'bg-purple-600 text-white shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              {curr === 'NGN' ? '₦ NGN' : curr === 'USD' ? '$ USD' : '⨇ MONAD'}
            </button>
          ))}
        </div>

        {/* Right actions: View mode switch & Privy info */}
        <div className="flex items-center gap-2">
          {/* Privy Address Badge */}
          <div className="hidden sm:flex items-center gap-2 bg-slate-900/80 border border-slate-800 px-3 py-1.5 rounded-xl text-xs text-slate-300">
            <Shield className="w-3.5 h-3.5 text-emerald-400" />
            <span className="font-mono text-[11px] text-slate-400">
              {user.walletAddress.slice(0, 6)}...{user.walletAddress.slice(-4)}
            </span>
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
          </div>

          {/* View Mode Toggle: Mobile Neobank vs Dev/JIT Studio */}
          <div className="flex items-center bg-slate-900/90 border border-slate-800 rounded-xl p-0.5">
            <button
              onClick={() => onViewChange('mobile')}
              className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg transition-all ${
                activeView === 'mobile'
                  ? 'bg-gradient-to-r from-purple-600 to-indigo-600 text-white shadow-md'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <Smartphone className="w-3.5 h-3.5" />
              <span>Mobile App</span>
            </button>
            <button
              onClick={() => onViewChange('studio')}
              className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg transition-all ${
                activeView === 'studio'
                  ? 'bg-gradient-to-r from-purple-600 to-indigo-600 text-white shadow-md'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <Terminal className="w-3.5 h-3.5" />
              <span>JIT & Webhook Studio</span>
            </button>
          </div>

          {/* Device frame toggle in mobile view */}
          {activeView === 'mobile' && (
            <button
              onClick={onToggleDeviceFrame}
              title="Toggle iPhone 16 frame"
              className={`p-2 rounded-xl border text-xs transition-colors hidden md:flex items-center gap-1.5 ${
                deviceFrame
                  ? 'bg-slate-800 border-slate-700 text-purple-300'
                  : 'bg-slate-900 border-slate-800 text-slate-400 hover:text-white'
              }`}
            >
              <Smartphone className="w-4 h-4" />
              <span className="text-[11px] font-medium">{deviceFrame ? 'Frame On' : 'Full Screen'}</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
