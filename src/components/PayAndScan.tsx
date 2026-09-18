import React, { useState } from 'react';
import {
  QrCode,
  Send,
  Building2,
  Wallet,
  Camera,
  Flashlight,
  CheckCircle2,
  AlertCircle,
  Clock,
  ArrowRight,
  ShieldAlert,
} from 'lucide-react';
import { DisplayCurrency, FxRates, LedgerAccount, NQRMerchant } from '../types';
import { MoneraLogo } from './MoneraLogo';
import { useTheme } from '../context/ThemeContext';

interface PayAndScanProps {
  initialTab?: 'scan' | 'transfer';
  ledger: LedgerAccount;
  fxRates: FxRates;
  displayCurrency: DisplayCurrency;
  onPayNQR: (merchant: NQRMerchant, amountNgn: number, pin: string) => Promise<any>;
  onTransfer: (data: { rail: 'local_currency' | 'digital_asset'; destination: string; amount: number; currency: 'NGN' | 'USD'; pin: string }) => Promise<any>;
  onRequestPin: (callback: (pin: string) => void) => void;
}

const PRESET_NQR_MERCHANTS: NQRMerchant[] = [
  {
    id: 'nqr_shoprite_01',
    merchantName: 'Shoprite Lekki Retail',
    merchantId: 'NQR-NG-901844',
    subCode: '0001',
    bankCode: '058',
    bankName: 'Guaranty Trust Bank',
    category: 'Supermarket & Groceries',
    terminalId: 'TERM-LEKKI-08',
    fixedAmount: 18500,
    qrPayload: '00020101021226580016NQR-NG-90184452045411535665405185005802NG5916Shoprite Lekki6005Lagos',
  },
  {
    id: 'nqr_fuel_02',
    merchantName: 'TotalEnergies Fuel V.I.',
    merchantId: 'NQR-NG-331092',
    subCode: '0002',
    bankCode: '011',
    bankName: 'First Bank of Nigeria',
    category: 'Petroleum & Gas Station',
    terminalId: 'PUMP-04-VI',
    fixedAmount: 25000,
    qrPayload: '00020101021226580016NQR-NG-33109252045541535665405250005802NG5918TotalEnergies VI6005Lagos',
  },
  {
    id: 'nqr_chopnow_03',
    merchantName: 'ChopNow Gourmet Ikeja',
    merchantId: 'NQR-NG-554210',
    subCode: '0003',
    bankCode: '033',
    bankName: 'United Bank for Africa',
    category: 'Restaurant & Dining',
    terminalId: 'POS-DINE-02',
    fixedAmount: 9200,
    qrPayload: '00020101021226580016NQR-NG-5542105204581253566540492005802NG5915ChopNow Ikeja6005Lagos',
  },
];

export const PayAndScan: React.FC<PayAndScanProps> = ({
  initialTab = 'scan',
  ledger,
  fxRates,
  displayCurrency,
  onPayNQR,
  onTransfer,
  onRequestPin,
}) => {
  const { isDark } = useTheme();
  const [activeTab, setActiveTab] = useState<'scan' | 'transfer'>(initialTab);

  // Scan state
  const [selectedMerchant, setSelectedMerchant] = useState<NQRMerchant | null>(null);
  const [customAmountNgn, setCustomAmountNgn] = useState<number>(15000);
  const [isProcessingNqr, setIsProcessingNqr] = useState(false);
  const [nqrSuccess, setNqrSuccess] = useState<any | null>(null);
  const [scannerActive, setScannerActive] = useState(true);

  // Transfer state
  const [transferRail, setTransferRail] = useState<'local_currency' | 'digital_asset'>('local_currency');
  const [bankDestination, setBankDestination] = useState({
    bankName: 'Guaranty Trust Bank',
    accountNumber: '0123456789',
    accountName: 'Oluwaseun Adeyemi',
  });
  const [cryptoDestination, setCryptoDestination] = useState('0x3a91bFc8129Da48F0024A841E3435c249a1a8F9B');
  const [transferAmount, setTransferAmount] = useState<number>(50000);
  const [isTransferring, setIsTransferring] = useState(false);
  const [transferSuccess, setTransferSuccess] = useState<any | null>(null);
  const [errorMessage, setErrorMessage] = useState('');

  // Handle NQR confirmation
  const handleConfirmNQR = () => {
    if (!selectedMerchant) return;
    const amount = selectedMerchant.fixedAmount || customAmountNgn;
    setErrorMessage('');

    onRequestPin(async (pin) => {
      setIsProcessingNqr(true);
      try {
        const result = await onPayNQR(selectedMerchant, amount, pin);
        setNqrSuccess(result);
        setSelectedMerchant(null);
      } catch (err: any) {
        setErrorMessage(err.message || 'Payment failed');
      } finally {
        setIsProcessingNqr(false);
      }
    });
  };

  // Handle Transfer confirmation
  const handleConfirmTransfer = () => {
    setErrorMessage('');
    const dest = transferRail === 'local_currency'
      ? `${bankDestination.bankName} - ${bankDestination.accountNumber} (${bankDestination.accountName})`
      : cryptoDestination;

    onRequestPin(async (pin) => {
      setIsTransferring(true);
      try {
        const result = await onTransfer({
          rail: transferRail,
          destination: dest,
          amount: transferAmount,
          currency: transferRail === 'local_currency' ? 'NGN' : 'USD',
          pin,
        });
        setTransferSuccess(result);
      } catch (err: any) {
        setErrorMessage(err.message || 'Transfer failed');
      } finally {
        setIsTransferring(false);
      }
    });
  };

  return (
    <div className="space-y-6 pb-20">
      {/* Sub tabs: Scan NQR vs Transfer */}
      <div className={`flex p-1 rounded-2xl border transition-colors ${
        isDark ? 'bg-[#040817] border-blue-950' : 'bg-slate-200/80 border-slate-200'
      }`}>
        <button
          onClick={() => {
            setActiveTab('scan');
            setNqrSuccess(null);
            setTransferSuccess(null);
          }}
          className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-bold text-xs transition-all ${
            activeTab === 'scan'
              ? 'bg-blue-600 text-white shadow-md shadow-blue-500/30'
              : isDark
              ? 'text-slate-400 hover:text-white'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <QrCode className="w-4 h-4" />
          <span>Scan NQR Code</span>
        </button>

        <button
          onClick={() => {
            setActiveTab('transfer');
            setNqrSuccess(null);
            setTransferSuccess(null);
          }}
          className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-bold text-xs transition-all ${
            activeTab === 'transfer'
              ? 'bg-blue-600 text-white shadow-md shadow-blue-500/30'
              : isDark
              ? 'text-slate-400 hover:text-white'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Send className="w-4 h-4" />
          <span>Transfer Funds</span>
        </button>
      </div>

      {errorMessage && (
        <div className="flex items-center gap-2 p-3 bg-red-500/10 border border-red-500/20 text-red-500 rounded-xl text-xs">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{errorMessage}</span>
        </div>
      )}

      {/* TAB 1: SCAN NQR CODE */}
      {activeTab === 'scan' && (
        <div className="space-y-4">
          {nqrSuccess ? (
            <div className={`border rounded-3xl p-6 text-center space-y-4 shadow-xl ${
              isDark ? 'bg-[#131926] border-emerald-500/30' : 'bg-white border-emerald-300'
            }`}>
              <div className="w-14 h-14 rounded-full bg-emerald-500/15 border border-emerald-500/30 text-emerald-500 flex items-center justify-center mx-auto">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h3 className={`text-lg font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>Payment Successful!</h3>
              <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
                Settled to merchant via NIBSS NIP rail. Stablecoin debited from Monad ledger.
              </p>

              <div className={`rounded-2xl p-4 text-left text-xs space-y-2 font-mono ${
                isDark ? 'bg-slate-900/80 text-slate-400' : 'bg-slate-50 text-slate-600 border border-slate-200'
              }`}>
                <div className="flex justify-between">
                  <span>Merchant:</span>
                  <span className={`font-sans font-semibold ${isDark ? 'text-white' : 'text-slate-900'}`}>{nqrSuccess.settlement?.merchantName}</span>
                </div>
                <div className="flex justify-between">
                  <span>Amount:</span>
                  <span className="text-emerald-500 font-bold">₦{nqrSuccess.transaction?.amountNgn.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span>Latency:</span>
                  <span className="text-blue-500 font-bold">{nqrSuccess.settlement?.executionLatencyMs}ms</span>
                </div>
                <div className="flex justify-between">
                  <span>Monad Ref:</span>
                  <span className={`truncate max-w-[160px] ${isDark ? 'text-slate-300' : 'text-slate-700'}`}>{nqrSuccess.settlement?.monadSettlementHash}</span>
                </div>
              </div>

              <button
                onClick={() => setNqrSuccess(null)}
                className="w-full py-3 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs shadow-lg shadow-blue-600/30"
              >
                Scan Another Code
              </button>
            </div>
          ) : (
            <>
              {/* Simulated Camera Viewfinder */}
              <div className="relative overflow-hidden rounded-3xl bg-black border border-blue-900/60 aspect-[4/3] flex items-center justify-center group shadow-2xl shadow-blue-950/40">
                {/* Background scanning laser effect */}
                <div className="absolute inset-0 bg-gradient-to-b from-transparent via-blue-500/10 to-transparent animate-pulse" />
                <div className="absolute inset-x-8 top-1/2 -translate-y-1/2 h-0.5 bg-gradient-to-r from-transparent via-cyan-400 to-transparent shadow-[0_0_15px_#38bdf8]" />

                {/* Target Frame Reticle */}
                <div className="w-48 h-48 border-2 border-blue-400/60 rounded-3xl relative flex flex-col items-center justify-center">
                  <div className="absolute top-0 left-0 w-6 h-6 border-t-4 border-l-4 border-cyan-400 rounded-tl-xl" />
                  <div className="absolute top-0 right-0 w-6 h-6 border-t-4 border-r-4 border-cyan-400 rounded-tr-xl" />
                  <div className="absolute bottom-0 left-0 w-6 h-6 border-b-4 border-l-4 border-cyan-400 rounded-bl-xl" />
                  <div className="absolute bottom-0 right-0 w-6 h-6 border-b-4 border-r-4 border-cyan-400 rounded-br-xl" />

                  <QrCode className="w-16 h-16 text-white/20 mb-2" />
                  <MoneraLogo variant="icon" size={24} className="text-cyan-400/50" />
                </div>

                <div className="absolute top-4 left-4 right-4 flex justify-between items-center text-xs text-white/80">
                  <span className="flex items-center gap-1.5 bg-black/70 backdrop-blur-md px-2.5 py-1 rounded-full border border-blue-900/40">
                    <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                    NIBSS NQR Scanner Active
                  </span>
                  <button className="p-2 rounded-full bg-black/70 border border-blue-900/40 hover:bg-white/20 transition-colors">
                    <Flashlight className="w-4 h-4 text-cyan-400" />
                  </button>
                </div>
              </div>

              {/* Preset Merchant QR Codes to test instantly */}
              <div>
                <p className={`text-xs font-bold uppercase tracking-wider mb-2.5 ${
                  isDark ? 'text-slate-400' : 'text-slate-500'
                }`}>
                  Select a Merchant QR (Simulated Live Scans)
                </p>
                <div className="space-y-2">
                  {PRESET_NQR_MERCHANTS.map((m) => (
                    <button
                      key={m.id}
                      onClick={() => setSelectedMerchant(m)}
                      className={`w-full p-3.5 rounded-2xl border text-left transition-all flex items-center justify-between ${
                        selectedMerchant?.id === m.id
                          ? isDark
                            ? 'bg-blue-950/60 border-blue-500 shadow-md shadow-blue-500/20'
                            : 'bg-blue-50 border-blue-500 shadow-xs'
                          : isDark
                          ? 'bg-[#091224] border-blue-950/80 hover:border-blue-800'
                          : 'bg-white border-slate-200 hover:border-slate-300 shadow-xs'
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-500 flex items-center justify-center font-bold text-sm">
                          ₦
                        </div>
                        <div>
                          <h4 className={`text-xs font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>{m.merchantName}</h4>
                          <p className={`text-[11px] ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
                            {m.bankName} • {m.category}
                          </p>
                        </div>
                      </div>

                      <div className="text-right">
                        <span className="text-xs font-bold text-emerald-500 font-mono">
                          ₦{m.fixedAmount?.toLocaleString()}
                        </span>
                        <span className={`text-[10px] block ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>Tap to pay</span>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Confirmation Action */}
              {selectedMerchant && (
                <div className={`p-4 rounded-2xl border shadow-xl space-y-3 animate-in fade-in ${
                  isDark ? 'bg-[#09152b] border-blue-500/40' : 'bg-white border-blue-200'
                }`}>
                  <div className="flex justify-between items-center text-xs">
                    <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Ready to Pay:</span>
                    <span className={`font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>{selectedMerchant.merchantName}</span>
                  </div>
                  <div className="flex justify-between items-center text-xs">
                    <span className={isDark ? 'text-slate-400' : 'text-slate-500'}>Ledger Deduction:</span>
                    <span className="font-bold font-mono text-blue-500">
                      ${((selectedMerchant.fixedAmount || customAmountNgn) / fxRates.USD_NGN).toFixed(2)} USDC
                    </span>
                  </div>

                  <button
                    onClick={handleConfirmNQR}
                    disabled={isProcessingNqr}
                    className="w-full py-3.5 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-blue-950/40 flex items-center justify-center gap-2"
                  >
                    {isProcessingNqr ? (
                      <span className="inline-block animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                    ) : (
                      <>
                        <span>Authorize & Pay with PIN</span>
                        <ArrowRight className="w-4 h-4" />
                      </>
                    )}
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      )}

      {/* TAB 2: TRANSFER */}
      {activeTab === 'transfer' && (
        <div className="space-y-4">
          {transferSuccess ? (
            <div className={`border rounded-3xl p-6 text-center space-y-4 shadow-xl ${
              isDark ? 'bg-[#131926] border-emerald-500/30' : 'bg-white border-emerald-300'
            }`}>
              <div className="w-14 h-14 rounded-full bg-emerald-500/15 border border-emerald-500/30 text-emerald-500 flex items-center justify-center mx-auto">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h3 className={`text-lg font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>Transfer Dispatched!</h3>
              <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>{transferSuccess.message}</p>

              <div className={`rounded-2xl p-4 text-left text-xs space-y-2 font-mono ${
                isDark ? 'bg-slate-900/80 text-slate-400' : 'bg-slate-50 text-slate-600 border border-slate-200'
              }`}>
                <div className="flex justify-between">
                  <span>Destination:</span>
                  <span className={`font-sans font-semibold truncate max-w-[170px] ${
                    isDark ? 'text-white' : 'text-slate-900'
                  }`}>
                    {transferSuccess.transaction?.title}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>ETA:</span>
                  <span className="text-emerald-500 font-bold">{transferSuccess.eta}</span>
                </div>
              </div>

              <button
                onClick={() => setTransferSuccess(null)}
                className="w-full py-3 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs"
              >
                Make Another Transfer
              </button>
            </div>
          ) : (
            <>
              {/* Rail Picker */}
              <div>
                <label className={`text-xs font-semibold block mb-2 ${
                  isDark ? 'text-slate-400' : 'text-slate-600'
                }`}>How would you like to pay?</label>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    onClick={() => setTransferRail('local_currency')}
                    className={`p-3.5 rounded-2xl border text-left transition-all ${
                      transferRail === 'local_currency'
                        ? isDark
                          ? 'bg-blue-950/40 border-blue-500 shadow-md'
                          : 'bg-blue-50 border-blue-600 shadow-xs'
                        : isDark
                        ? 'bg-[#131926] border-slate-800 hover:border-slate-700'
                        : 'bg-white border-slate-200 hover:border-slate-300 shadow-xs'
                    }`}
                  >
                    <div className="w-8 h-8 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-500 flex items-center justify-center mb-2">
                      <Building2 className="w-4 h-4" />
                    </div>
                    <div className={`font-bold text-xs ${isDark ? 'text-white' : 'text-slate-900'}`}>Local Currency</div>
                    <div className="text-[10px] text-emerald-500 flex items-center gap-1 mt-0.5 font-medium">
                      <Clock className="w-3 h-3" /> 1–2 minutes (NIP)
                    </div>
                  </button>

                  <button
                    onClick={() => setTransferRail('digital_asset')}
                    className={`p-3.5 rounded-2xl border text-left transition-all ${
                      transferRail === 'digital_asset'
                        ? isDark
                          ? 'bg-blue-950/40 border-blue-500 shadow-md'
                          : 'bg-blue-50 border-blue-600 shadow-xs'
                        : isDark
                        ? 'bg-[#131926] border-slate-800 hover:border-slate-700'
                        : 'bg-white border-slate-200 hover:border-slate-300 shadow-xs'
                    }`}
                  >
                    <div className="w-8 h-8 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-500 flex items-center justify-center mb-2">
                      <Wallet className="w-4 h-4" />
                    </div>
                    <div className={`font-bold text-xs ${isDark ? 'text-white' : 'text-slate-900'}`}>Digital Asset</div>
                    <div className="text-[10px] text-blue-500 mt-0.5 font-medium">Monad L1 (600ms)</div>
                  </button>
                </div>
              </div>

              {/* Destination Inputs */}
              {transferRail === 'local_currency' ? (
                <div className={`space-y-3 border rounded-2xl p-4 transition-colors ${
                  isDark ? 'bg-[#131926] border-slate-800' : 'bg-white border-slate-200 shadow-xs'
                }`}>
                  <div>
                    <label className={`text-[11px] font-semibold block mb-1 ${
                      isDark ? 'text-slate-400' : 'text-slate-600'
                    }`}>Destination Bank</label>
                    <select
                      value={bankDestination.bankName}
                      onChange={(e) => setBankDestination({ ...bankDestination, bankName: e.target.value })}
                      className={`w-full px-3 py-2.5 rounded-xl border text-xs focus:outline-none focus:border-blue-500 ${
                        isDark ? 'bg-slate-900 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-900'
                      }`}
                    >
                      <option value="Guaranty Trust Bank">Guaranty Trust Bank (GTBank)</option>
                      <option value="Zenith Bank">Zenith Bank Plc</option>
                      <option value="Access Bank">Access Bank Plc</option>
                      <option value="Kuda Microfinance Bank">Kuda Microfinance Bank</option>
                      <option value="Moniepoint MFB">Moniepoint MFB</option>
                    </select>
                  </div>

                  <div>
                    <label className={`text-[11px] font-semibold block mb-1 ${
                      isDark ? 'text-slate-400' : 'text-slate-600'
                    }`}>Account Number</label>
                    <input
                      type="text"
                      maxLength={10}
                      value={bankDestination.accountNumber}
                      onChange={(e) => setBankDestination({ ...bankDestination, accountNumber: e.target.value })}
                      className={`w-full px-3 py-2.5 rounded-xl border font-mono text-xs focus:outline-none focus:border-blue-500 ${
                        isDark ? 'bg-slate-900 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-900'
                      }`}
                    />
                  </div>

                  <div>
                    <label className={`text-[11px] font-semibold block mb-1 ${
                      isDark ? 'text-slate-400' : 'text-slate-600'
                    }`}>Account Name (Auto-resolved)</label>
                    <div className={`px-3 py-2.5 rounded-xl border text-xs font-medium ${
                      isDark ? 'bg-slate-900/60 border-slate-800/80 text-slate-300' : 'bg-slate-100 border-slate-200 text-slate-700'
                    }`}>
                      {bankDestination.accountName}
                    </div>
                  </div>
                </div>
              ) : (
                <div className={`border rounded-2xl p-4 space-y-3 ${
                  isDark ? 'bg-[#131926] border-slate-800' : 'bg-white border-slate-200 shadow-xs'
                }`}>
                  <div className="flex items-center justify-between text-xs">
                    <span className={isDark ? 'text-slate-400' : 'text-slate-600'}>Network</span>
                    <span className="px-2 py-0.5 rounded-md bg-blue-500/10 text-blue-500 border border-blue-500/20 font-mono font-bold">
                      Monad L1 (Chain ID: 10143)
                    </span>
                  </div>

                  <div>
                    <label className={`text-[11px] font-semibold block mb-1 ${
                      isDark ? 'text-slate-400' : 'text-slate-600'
                    }`}>Monad EVM Address</label>
                    <input
                      type="text"
                      value={cryptoDestination}
                      onChange={(e) => setCryptoDestination(e.target.value)}
                      className={`w-full px-3 py-2.5 rounded-xl border font-mono text-xs focus:outline-none focus:border-blue-500 ${
                        isDark ? 'bg-slate-900 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-900'
                      }`}
                    />
                  </div>
                </div>
              )}

              {/* Amount Input */}
              <div className={`border rounded-2xl p-4 ${
                isDark ? 'bg-[#131926] border-slate-800' : 'bg-white border-slate-200 shadow-xs'
              }`}>
                <div className="flex justify-between items-center mb-1">
                  <label className={`text-[11px] font-semibold ${isDark ? 'text-slate-400' : 'text-slate-600'}`}>Transfer Amount</label>
                  <span className="text-[11px] text-blue-500 font-medium">
                    Max: ${ledger.availableBalanceUsd.toFixed(2)}
                  </span>
                </div>
                <div className="relative">
                  <input
                    type="number"
                    value={transferAmount}
                    onChange={(e) => setTransferAmount(Number(e.target.value))}
                    className={`w-full pl-8 pr-16 py-3 rounded-xl border font-mono font-bold text-lg focus:outline-none focus:border-blue-500 ${
                      isDark ? 'bg-slate-900 border-slate-800 text-white' : 'bg-slate-50 border-slate-200 text-slate-900'
                    }`}
                  />
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 font-bold">
                    {transferRail === 'local_currency' ? '₦' : '$'}
                  </span>
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 font-semibold">
                    {transferRail === 'local_currency' ? 'NGN' : 'USDC'}
                  </span>
                </div>
              </div>

              <button
                onClick={handleConfirmTransfer}
                disabled={isTransferring}
                className="w-full py-3.5 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold text-xs shadow-lg shadow-blue-950/40 flex items-center justify-center gap-2"
              >
                {isTransferring ? (
                  <span className="inline-block animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                ) : (
                  <>
                    <span>Confirm & Authorize with PIN</span>
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>
            </>
          )}
        </div>
      )}
    </div>
  );
};
