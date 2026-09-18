import React, { useState } from 'react';
import { Lock, Delete, X } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface PinModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (pin: string) => void;
  title?: string;
  description?: string;
}

export const PinModal: React.FC<PinModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
  title = 'Enter Transaction PIN',
  description = 'Authorize this transaction with your 4-digit security PIN',
}) => {
  const { isDark } = useTheme();
  const [pin, setPin] = useState<string>('');
  const [error, setError] = useState<string>('');

  if (!isOpen) return null;

  const handleDigit = (digit: string) => {
    if (pin.length < 4) {
      const nextPin = pin + digit;
      setPin(nextPin);
      setError('');
      if (nextPin.length === 4) {
        // Auto submit
        setTimeout(() => {
          if (nextPin === '1234' || nextPin === '0000') {
            onSuccess(nextPin);
            setPin('');
          } else {
            setError('Incorrect PIN. Try default: 1234');
            setPin('');
          }
        }, 150);
      }
    }
  };

  const handleDelete = () => {
    setPin((prev) => prev.slice(0, -1));
    setError('');
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className={`border rounded-3xl w-full max-w-xs p-6 shadow-2xl relative text-center transition-all ${
        isDark ? 'bg-[#131926] border-slate-800' : 'bg-white border-slate-200'
      }`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 p-2 rounded-full transition-colors ${
            isDark ? 'text-slate-400 hover:text-white' : 'text-slate-400 hover:text-slate-700'
          }`}
        >
          <X className="w-5 h-5" />
        </button>

        <div className="w-12 h-12 rounded-2xl bg-blue-500/10 border border-blue-500/20 text-blue-500 flex items-center justify-center mx-auto mb-3">
          <Lock className="w-6 h-6" />
        </div>

        <h3 className={`text-lg font-bold mb-1 ${isDark ? 'text-white' : 'text-slate-900'}`}>{title}</h3>
        <p className={`text-xs mb-6 ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>{description}</p>

        {/* PIN Indicators */}
        <div className="flex justify-center items-center gap-4 mb-6">
          {[0, 1, 2, 3].map((index) => {
            const isFilled = index < pin.length;
            return (
              <div
                key={index}
                className={`w-4 h-4 rounded-full transition-all duration-200 ${
                  isFilled
                    ? 'bg-blue-600 shadow-[0_0_12px_rgba(37,99,235,0.5)] scale-110'
                    : isDark
                    ? 'border border-slate-700 bg-slate-900/50'
                    : 'border border-slate-300 bg-slate-100'
                }`}
              />
            );
          })}
        </div>

        {error && <p className="text-xs text-red-500 font-medium mb-4 animate-shake">{error}</p>}
        {!error && (
          <p className={`text-[11px] mb-4 ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>
            Demo Default PIN: <span className="text-blue-500 font-mono font-bold">1234</span>
          </p>
        )}

        {/* Keypad */}
        <div className="grid grid-cols-3 gap-3">
          {['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) => (
            <button
              key={digit}
              onClick={() => handleDigit(digit)}
              className={`h-14 rounded-2xl border font-bold text-xl active:scale-95 transition-all flex items-center justify-center ${
                isDark
                  ? 'bg-slate-900/70 hover:bg-slate-800 border-slate-800/80 text-white'
                  : 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-900 shadow-xs'
              }`}
            >
              {digit}
            </button>
          ))}
          <div />
          <button
            onClick={() => handleDigit('0')}
            className={`h-14 rounded-2xl border font-bold text-xl active:scale-95 transition-all flex items-center justify-center ${
              isDark
                ? 'bg-slate-900/70 hover:bg-slate-800 border-slate-800/80 text-white'
                : 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-900 shadow-xs'
            }`}
          >
            0
          </button>
          <button
            onClick={handleDelete}
            className={`h-14 rounded-2xl border active:scale-95 transition-all flex items-center justify-center ${
              isDark
                ? 'bg-slate-900/70 hover:bg-slate-800 border-slate-800/80 text-slate-400 hover:text-white'
                : 'bg-slate-50 hover:bg-slate-100 border-slate-200 text-slate-500 hover:text-slate-900 shadow-xs'
            }`}
          >
            <Delete className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
};
