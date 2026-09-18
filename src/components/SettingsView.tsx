import React, { useState } from 'react';
import {
  User,
  ShieldCheck,
  KeyRound,
  Fingerprint,
  Bell,
  HelpCircle,
  LogOut,
  ChevronRight,
  ExternalLink,
  Shield,
  Smartphone,
  Copy,
  Check,
  Sun,
  Moon,
  Sparkles,
} from 'lucide-react';
import { UserProfile } from '../types';
import { useTheme } from '../context/ThemeContext';

interface SettingsViewProps {
  user: UserProfile;
  onUpdatePin: () => void;
  onSimulateKyc: () => Promise<void>;
}

export const SettingsView: React.FC<SettingsViewProps> = ({
  user,
  onUpdatePin,
  onSimulateKyc,
}) => {
  const { theme, isDark, setTheme, toggleTheme } = useTheme();
  const [biometrics, setBiometrics] = useState(user.biometricEnabled);
  const [notifications, setNotifications] = useState(true);
  const [copied, setCopied] = useState(false);

  const copyAddress = () => {
    navigator.clipboard.writeText(user.walletAddress);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  return (
    <div className="space-y-5 pb-20">
      <div>
        <h2 className={`text-xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-slate-900'}`}>
          Settings & Preferences
        </h2>
        <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
          Identity, Security & Appearance
        </p>
      </div>

      {/* User Profile Card */}
      <div
        className={`p-5 rounded-3xl ${
          isDark
            ? 'bg-[#071329] border border-blue-950/80 shadow-lg shadow-blue-950/20'
            : 'bg-white border border-slate-200 shadow-sm'
        } space-y-4 transition-colors`}
      >
        <div className="flex items-center gap-3.5">
          <div className="w-13 h-13 rounded-2xl bg-gradient-to-tr from-blue-700 via-blue-600 to-cyan-500 flex items-center justify-center text-white font-extrabold text-lg shadow-lg shadow-blue-900/30">
            {user.name.slice(0, 1)}
          </div>
          <div>
            <h3 className={`text-sm font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>{user.name}</h3>
            <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>{user.email}</p>
            <p className={`text-xs ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>{user.phone}</p>
          </div>
        </div>

        {/* Monad Non-Custodial Wallet */}
        <div
          className={`rounded-2xl p-3.5 border space-y-2 ${
            isDark ? 'bg-[#030814] border-blue-950' : 'bg-slate-50 border-slate-200'
          }`}
        >
          <div className="flex justify-between items-center text-xs">
            <span className={`flex items-center gap-1.5 ${isDark ? 'text-slate-400' : 'text-slate-600'}`}>
              <Shield className="w-3.5 h-3.5 text-blue-500" />
              Privy Embedded Monad Wallet
            </span>
            <span className="text-[10px] text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full font-semibold">
              Non-Custodial
            </span>
          </div>

          <div className="flex justify-between items-center">
            <span className={`font-mono text-xs truncate max-w-[200px] ${isDark ? 'text-slate-200' : 'text-slate-700'}`}>
              {user.walletAddress}
            </span>
            <button
              onClick={copyAddress}
              className={`p-1.5 rounded-lg text-xs flex items-center gap-1 transition-colors border ${
                isDark
                  ? 'bg-blue-950/60 hover:bg-blue-900/60 text-cyan-300 border-blue-900/30'
                  : 'bg-white hover:bg-slate-100 text-blue-600 border-slate-200 shadow-xs'
              }`}
              title="Copy address"
            >
              {copied ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
            </button>
          </div>
        </div>
      </div>

      {/* Theme & Appearance (Light & Dark Mode) */}
      <div
        className={`p-5 rounded-3xl border space-y-3.5 text-xs transition-colors ${
          isDark
            ? 'bg-[#131926] border-slate-800/80 shadow-lg shadow-black/20'
            : 'bg-white border-slate-200 shadow-sm'
        }`}
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div
              className={`w-8 h-8 rounded-xl flex items-center justify-center ${
                isDark ? 'bg-blue-500/15 text-cyan-300' : 'bg-blue-50 text-blue-600'
              }`}
            >
              {isDark ? <Moon className="w-4 h-4" /> : <Sun className="w-4 h-4" />}
            </div>
            <div>
              <h4 className={`text-xs font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>
                Theme & Appearance
              </h4>
              <p className={`text-[11px] ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
                {isDark ? 'Dark Theme (Monad Cobalt)' : 'Light Theme (Daylight Slate)'}
              </p>
            </div>
          </div>

          <button
            onClick={toggleTheme}
            className={`px-2.5 py-1 rounded-full text-[11px] font-semibold border transition-all flex items-center gap-1.5 active:scale-95 ${
              isDark
                ? 'bg-blue-500/10 text-cyan-300 border-blue-500/30 hover:bg-blue-500/20'
                : 'bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100'
            }`}
          >
            {isDark ? <Sun className="w-3 h-3 text-amber-400" /> : <Moon className="w-3 h-3 text-blue-600" />}
            <span>{isDark ? 'Switch to Light' : 'Switch to Dark'}</span>
          </button>
        </div>

        {/* Side-by-side Theme Cards */}
        <div className="grid grid-cols-2 gap-2.5 pt-1">
          {/* Dark Mode Card */}
          <button
            onClick={() => setTheme('dark')}
            className={`p-3.5 rounded-2xl border text-left transition-all relative overflow-hidden ${
              isDark
                ? 'bg-gradient-to-br from-[#0c1c38] to-[#060b17] border-cyan-500/60 shadow-md shadow-blue-950/50 ring-1 ring-cyan-500/40'
                : 'bg-slate-100 border-slate-200 hover:border-slate-300 opacity-75 hover:opacity-100'
            }`}
          >
            <div className="flex items-center justify-between mb-2">
              <div className="w-7 h-7 rounded-lg bg-slate-900 border border-slate-700 flex items-center justify-center text-cyan-400 shadow-xs">
                <Moon className="w-3.5 h-3.5" />
              </div>
              {isDark && (
                <span className="w-4 h-4 rounded-full bg-cyan-400 text-slate-950 flex items-center justify-center text-[10px] font-bold">
                  ✓
                </span>
              )}
            </div>
            <div className={`font-bold text-xs ${isDark ? 'text-white' : 'text-slate-700'}`}>Dark Mode</div>
            <div className="text-[10px] text-slate-400 mt-0.5">Midnight Cobalt</div>
          </button>

          {/* Light Mode Card */}
          <button
            onClick={() => setTheme('light')}
            className={`p-3.5 rounded-2xl border text-left transition-all relative overflow-hidden ${
              !isDark
                ? 'bg-gradient-to-br from-white to-blue-50/60 border-blue-600 shadow-md shadow-blue-500/10 ring-1 ring-blue-600'
                : 'bg-[#0a1224] border-slate-800 hover:border-slate-700 opacity-75 hover:opacity-100'
            }`}
          >
            <div className="flex items-center justify-between mb-2">
              <div className="w-7 h-7 rounded-lg bg-amber-50 border border-amber-200 flex items-center justify-center text-amber-500 shadow-xs">
                <Sun className="w-3.5 h-3.5" />
              </div>
              {!isDark && (
                <span className="w-4 h-4 rounded-full bg-blue-600 text-white flex items-center justify-center text-[10px] font-bold">
                  ✓
                </span>
              )}
            </div>
            <div className={`font-bold text-xs ${!isDark ? 'text-slate-900' : 'text-slate-200'}`}>Light Mode</div>
            <div className={`text-[10px] ${!isDark ? 'text-slate-500' : 'text-slate-400'} mt-0.5`}>Daylight Ivory</div>
          </button>
        </div>
      </div>

      {/* Verification & KYC Status */}
      <div
        className={`p-5 rounded-3xl border space-y-3 transition-colors ${
          isDark
            ? 'bg-[#131926] border-slate-800/80 shadow-lg shadow-black/20'
            : 'bg-white border-slate-200 shadow-sm'
        }`}
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center">
              <ShieldCheck className="w-4 h-4" />
            </div>
            <div>
              <h4 className={`text-xs font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>
                Identity Verification
              </h4>
              <p className={`text-[11px] ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
                Nigeria BVN & NIN Tier 3
              </p>
            </div>
          </div>
          <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
            Completed
          </span>
        </div>

        <div
          className={`pt-2 border-t flex justify-between text-xs ${
            isDark ? 'border-slate-800/80 text-slate-400' : 'border-slate-100 text-slate-500'
          }`}
        >
          <span>BVN: {user.bvnMasked}</span>
          <span>NIN: {user.ninMasked}</span>
        </div>
      </div>

      {/* Security Switches & PIN */}
      <div
        className={`p-5 rounded-3xl border space-y-4 text-xs transition-colors ${
          isDark
            ? 'bg-[#131926] border-slate-800/80 shadow-lg shadow-black/20'
            : 'bg-white border-slate-200 shadow-sm'
        }`}
      >
        <h4 className={`font-bold uppercase text-[11px] tracking-wider ${isDark ? 'text-slate-300' : 'text-slate-500'}`}>
          Security & Biometrics
        </h4>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Fingerprint className="w-4 h-4 text-blue-500" />
            <span className={isDark ? 'text-slate-200' : 'text-slate-800'}>
              Biometric Authentication (FaceID / TouchID)
            </span>
          </div>
          <button
            onClick={() => setBiometrics(!biometrics)}
            className={`w-11 h-6 rounded-full transition-colors relative ${
              biometrics ? 'bg-blue-600' : isDark ? 'bg-slate-800' : 'bg-slate-300'
            }`}
          >
            <div
              className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                biometrics ? 'right-1' : 'left-1'
              }`}
            />
          </button>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Bell className="w-4 h-4 text-blue-500" />
            <span className={isDark ? 'text-slate-200' : 'text-slate-800'}>
              Push Notifications & JIT Spend Alerts
            </span>
          </div>
          <button
            onClick={() => setNotifications(!notifications)}
            className={`w-11 h-6 rounded-full transition-colors relative ${
              notifications ? 'bg-blue-600' : isDark ? 'bg-slate-800' : 'bg-slate-300'
            }`}
          >
            <div
              className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                notifications ? 'right-1' : 'left-1'
              }`}
            />
          </button>
        </div>

        <div className={`pt-2 border-t ${isDark ? 'border-slate-800/80' : 'border-slate-100'}`}>
          <button
            onClick={onUpdatePin}
            className={`w-full flex items-center justify-between py-2 group transition-colors ${
              isDark ? 'text-slate-200 hover:text-white' : 'text-slate-800 hover:text-slate-950'
            }`}
          >
            <div className="flex items-center gap-3">
              <KeyRound className="w-4 h-4 text-blue-500" />
              <span>Change 4-Digit Transaction PIN</span>
            </div>
            <ChevronRight
              className={`w-4 h-4 transition-colors ${
                isDark ? 'text-slate-500 group-hover:text-white' : 'text-slate-400 group-hover:text-slate-700'
              }`}
            />
          </button>
        </div>
      </div>

      {/* App Version Info */}
      <div className={`text-center text-xs space-y-1 ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>
        <p>Monera neobank v1.0 • Monad L1</p>
        <p>Sudo Africa Mastercard • NIBSS NQR</p>
      </div>
    </div>
  );
};

