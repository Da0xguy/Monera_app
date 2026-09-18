import React from 'react';
import {
  Wallet,
  Send,
  CreditCard,
  TrendingUp,
  Settings,
  Wifi,
  Battery,
} from 'lucide-react';

interface MobileFrameProps {
  children: React.ReactNode;
  activeTab: 'home' | 'pay' | 'cards' | 'earn' | 'settings';
  onTabChange: (tab: 'home' | 'pay' | 'cards' | 'earn' | 'settings') => void;
  isFramed: boolean;
}

export const MobileFrame: React.FC<MobileFrameProps> = ({
  children,
  activeTab,
  onTabChange,
  isFramed,
}) => {
  const content = (
    <div className="flex flex-col h-full bg-[#0b0f17] text-slate-100 select-none">
      {/* Phone Status Bar (if framed) */}
      <div className="px-6 pt-3 pb-1 flex justify-between items-center text-[12px] font-semibold text-slate-400 shrink-0">
        <span>9:41</span>
        {/* Dynamic Island pill */}
        <div className="w-24 h-5 rounded-full bg-black border border-slate-800/80 mx-auto flex items-center justify-end px-2">
          <div className="w-2 h-2 rounded-full bg-purple-500/80 animate-pulse" />
        </div>
        <div className="flex items-center gap-1.5">
          <span className="text-[10px] font-bold text-purple-400">5G</span>
          <Wifi className="w-3.5 h-3.5" />
          <Battery className="w-4 h-4 text-emerald-400" />
        </div>
      </div>

      {/* Scrollable View Content */}
      <div className="flex-1 overflow-y-auto px-4 pt-3 pb-6 scrollbar-none">
        {children}
      </div>

      {/* Bottom Navigation Bar (Section 7 Spec: Pay / Deposit / Wallet / Cards / Settings) */}
      <nav className="shrink-0 border-t border-slate-800/80 bg-[#0d121c]/95 backdrop-blur-lg px-2 pt-2 pb-5 z-20">
        <div className="grid grid-cols-5 gap-1">
          <button
            onClick={() => onTabChange('home')}
            className={`flex flex-col items-center justify-center py-1 rounded-xl transition-all ${
              activeTab === 'home'
                ? 'text-purple-400'
                : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            <Wallet className={`w-5 h-5 mb-1 ${activeTab === 'home' ? 'stroke-[2.5]' : ''}`} />
            <span className="text-[10px] font-bold">Wallet</span>
          </button>

          <button
            onClick={() => onTabChange('pay')}
            className={`flex flex-col items-center justify-center py-1 rounded-xl transition-all ${
              activeTab === 'pay'
                ? 'text-purple-400'
                : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            <Send className={`w-5 h-5 mb-1 ${activeTab === 'pay' ? 'stroke-[2.5]' : ''}`} />
            <span className="text-[10px] font-bold">Pay & Scan</span>
          </button>

          <button
            onClick={() => onTabChange('cards')}
            className={`flex flex-col items-center justify-center py-1 rounded-xl transition-all ${
              activeTab === 'cards'
                ? 'text-purple-400'
                : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            <CreditCard className={`w-5 h-5 mb-1 ${activeTab === 'cards' ? 'stroke-[2.5]' : ''}`} />
            <span className="text-[10px] font-bold">Cards</span>
          </button>

          <button
            onClick={() => onTabChange('earn')}
            className={`flex flex-col items-center justify-center py-1 rounded-xl transition-all ${
              activeTab === 'earn'
                ? 'text-purple-400'
                : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            <TrendingUp className={`w-5 h-5 mb-1 ${activeTab === 'earn' ? 'stroke-[2.5]' : ''}`} />
            <span className="text-[10px] font-bold">Earn</span>
          </button>

          <button
            onClick={() => onTabChange('settings')}
            className={`flex flex-col items-center justify-center py-1 rounded-xl transition-all ${
              activeTab === 'settings'
                ? 'text-purple-400'
                : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            <Settings className={`w-5 h-5 mb-1 ${activeTab === 'settings' ? 'stroke-[2.5]' : ''}`} />
            <span className="text-[10px] font-bold">Settings</span>
          </button>
        </div>

        {/* iPhone Home Indicator bar */}
        <div className="w-32 h-1 rounded-full bg-slate-700/60 mx-auto mt-2" />
      </nav>
    </div>
  );

  if (!isFramed) {
    return <div className="max-w-md mx-auto min-h-screen pb-12">{content}</div>;
  }

  return (
    <div className="flex justify-center items-center py-4">
      {/* Device Bezel */}
      <div className="relative w-[390px] h-[820px] rounded-[52px] bg-[#1a1f2c] p-3 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.8),0_0_0_1px_rgba(255,255,255,0.08)] border-4 border-[#2d3446]">
        {/* Inner screen border */}
        <div className="w-full h-full rounded-[44px] overflow-hidden border border-black/80 relative">
          {content}
        </div>
      </div>
    </div>
  );
};
