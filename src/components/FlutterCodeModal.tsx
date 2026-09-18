import React, { useState } from 'react';
import { X, Copy, Check, Smartphone } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface FlutterCodeModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const PUBSPEC_YAML = `# pubspec.yaml
name: monera
description: "Monera - Non-Custodial Neobank on Monad L1 with Sudo Africa Mastercard & NIBSS NQR"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management & DI
  flutter_riverpod: ^2.5.1
  
  # Routing & Deep Linking
  go_router: ^14.2.0
  
  # High-Performance HTTP & RPC
  dio: ^5.4.3+1
  
  # Vector & Asset Rendering
  flutter_svg: ^2.0.10+1
  
  # Hardware & Security Rails
  local_auth: ^2.2.0
  flutter_secure_storage: ^9.2.2
  mobile_scanner: ^5.1.1
  qr_flutter: ^4.1.0
  
  # Formatting & Utilities
  intl: ^0.19.0
  cached_network_image: ^3.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
`;

const MAIN_DART = `// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // High-performance status bar styling (Obsidian & Electric Blue)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF030712),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // Riverpod root provider scope
    const ProviderScope(
      child: MoneraNeobankApp(),
    ),
  );
}

class MoneraNeobankApp extends ConsumerWidget {
  const MoneraNeobankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Monera Neobank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
`;

const APP_THEME_DART = `// lib/core/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppColors {
  // Pure Black & Blue Theme
  static const Color background = Color(0xFF030712);     // Obsidian Deep Black
  static const Color surface = Color(0xFF060B17);        // Card Deep Navy/Black
  static const Color surfaceElevated = Color(0xFF0C162D);// Action item surface
  
  // Electric Cyber Blue Accents
  static const Color primary = Color(0xFF00B4D8);        // Electric Blue
  static const Color primaryDark = Color(0xFF0077B6);    // Deep Blue
  static const Color cyanAccent = Color(0xFF38BDF8);     // Cyan highlight
  
  // FinTech Status Rails
  static const Color success = Color(0xFF10B981);        // NIP Instant Settlement
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderSubtle = Color(0xFF0F244A);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.cyanAccent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
`;

const RIVERPOD_PROVIDER_DART = `// lib/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/monad_rpc_service.dart';
import 'api_providers.dart';

class WalletState {
  final double availableBalanceUsd;
  final double monadL1Balance;
  final double usdcBalance;
  final double fxRateUsdToNgn;
  final String selectedCurrency; // NGN, USD, MONAD
  final bool isLoading;

  const WalletState({
    required this.availableBalanceUsd,
    required this.monadL1Balance,
    required this.usdcBalance,
    required this.fxRateUsdToNgn,
    required this.selectedCurrency,
    this.isLoading = false,
  });

  double get displayAmount {
    if (selectedCurrency == 'NGN') return availableBalanceUsd * fxRateUsdToNgn;
    if (selectedCurrency == 'MONAD') return monadL1Balance;
    return availableBalanceUsd;
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final MonadRpcService _rpcService;

  WalletNotifier(this._rpcService)
      : super(const WalletState(
          availableBalanceUsd: 1250.00,
          monadL1Balance: 86.206,
          usdcBalance: 1250.00,
          fxRateUsdToNgn: 1485.00,
          selectedCurrency: 'NGN',
        ));

  Future<void> refreshBalances(String walletAddress) async {
    state = state.copyWith(isLoading: true);
    try {
      final monadNative = await _rpcService.getMonadBalance(walletAddress);
      final usdc = await _rpcService.getUsdcBalance(walletAddress);
      state = state.copyWith(
        availableBalanceUsd: usdc,
        monadL1Balance: monadNative,
        usdcBalance: usdc,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setCurrency(String currency) {
    state = state.copyWith(selectedCurrency: currency);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final rpcService = ref.watch(monadRpcServiceProvider);
  return WalletNotifier(rpcService);
});
`;

const WALLET_HOME_DART = `// lib/screens/wallet_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../providers/wallet_provider.dart';

class WalletHomeScreen extends ConsumerWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final walletNotifier = ref.read(walletProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Currency Pill
              _buildTopBar(wallet, walletNotifier),
              const SizedBox(height: 24),
              // Obsidian & Electric Blue Balance Card
              _buildBalanceCard(wallet),
              const SizedBox(height: 24),
              // Quick Actions (Add, Send, Scan NQR, Cards)
              _buildQuickActions(context),
              const SizedBox(height: 24),
              // Sudo JIT Spend Adapter Banner
              _buildSpendAdapterBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletState wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2340), Color(0xFF071329), Color(0xFF030712)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE SPEND BALANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wallet.selectedCurrency == 'NGN'
                ? '₦\${wallet.displayAmount.toStringAsFixed(2)}'
                : wallet.selectedCurrency == 'USD'
                    ? '$\${wallet.displayAmount.toStringAsFixed(2)}'
                    : '⨇ \${wallet.displayAmount.toStringAsFixed(3)} MONAD',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF0F244A)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Monad L1 • ~600ms finality',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Text('Earn 8.4% APY',
                  style: TextStyle(fontSize: 12, color: AppColors.cyanAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
`;

export const FlutterCodeModal: React.FC<FlutterCodeModalProps> = ({ isOpen, onClose }) => {
  const { isDark } = useTheme();
  const [activeTab, setActiveTab] = useState<'pubspec' | 'main' | 'theme' | 'riverpod' | 'home'>('pubspec');
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const currentCode =
    activeTab === 'pubspec'
      ? PUBSPEC_YAML
      : activeTab === 'main'
      ? MAIN_DART
      : activeTab === 'theme'
      ? APP_THEME_DART
      : activeTab === 'riverpod'
      ? RIVERPOD_PROVIDER_DART
      : WALLET_HOME_DART;

  const handleCopy = () => {
    navigator.clipboard.writeText(currentCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 1800);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className={`border rounded-3xl w-full max-w-3xl max-h-[88vh] flex flex-col shadow-2xl relative overflow-hidden transition-colors ${
        isDark ? 'bg-[#060b17] border-blue-900/60 shadow-blue-950/60' : 'bg-white border-slate-200 shadow-xl'
      }`}>
        {/* Header */}
        <div className={`p-5 border-b flex items-center justify-between transition-colors ${
          isDark ? 'border-blue-950/80 bg-[#040814]' : 'border-slate-200 bg-slate-50'
        }`}>
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-blue-500/15 border border-blue-500/30 text-blue-500 flex items-center justify-center">
              <Smartphone className="w-5 h-5" />
            </div>
            <div>
              <h3 className={`text-base font-bold ${isDark ? 'text-white' : 'text-slate-900'}`}>Flutter Riverpod Codebase (Dart)</h3>
              <p className={`text-xs ${isDark ? 'text-slate-400' : 'text-slate-500'}`}>
                Pure Dart architecture with flutter_riverpod, go_router, dio, & high performance
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className={`p-2 rounded-full transition-colors ${
              isDark ? 'text-slate-400 hover:text-white bg-slate-900 hover:bg-slate-800' : 'text-slate-500 hover:text-slate-900 bg-slate-200/70 hover:bg-slate-200'
            }`}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab switcher */}
        <div className={`px-5 pt-3 pb-2 flex flex-wrap items-center justify-between gap-2 border-b transition-colors ${
          isDark ? 'border-blue-950/60 bg-[#030610]' : 'border-slate-200 bg-slate-100/70'
        }`}>
          <div className="flex flex-wrap gap-1.5">
            {[
              { id: 'pubspec', label: 'pubspec.yaml' },
              { id: 'main', label: 'main.dart' },
              { id: 'theme', label: 'app_theme.dart' },
              { id: 'riverpod', label: 'wallet_provider.dart' },
              { id: 'home', label: 'wallet_home_screen.dart' },
            ].map((t) => (
              <button
                key={t.id}
                onClick={() => setActiveTab(t.id as any)}
                className={`px-3 py-1.5 rounded-lg text-xs font-mono font-semibold transition-all ${
                  activeTab === t.id
                    ? 'bg-blue-600 text-white shadow-xs'
                    : isDark
                    ? 'text-slate-400 hover:text-slate-200 bg-slate-900/60 border border-blue-950/40'
                    : 'text-slate-600 hover:text-slate-900 bg-white border border-slate-200 shadow-2xs'
                }`}
              >
                {t.label}
              </button>
            ))}
          </div>

          <button
            onClick={handleCopy}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-blue-500/15 hover:bg-blue-500/25 text-blue-600 dark:text-cyan-300 text-xs font-semibold border border-blue-500/30 transition-colors"
          >
            {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
            <span>{copied ? 'Copied!' : 'Copy Code'}</span>
          </button>
        </div>

        {/* Code View */}
        <div className={`flex-1 overflow-auto p-4 font-mono text-xs ${
          isDark ? 'bg-[#030610] text-blue-100/90' : 'bg-slate-900 text-slate-100'
        } selection:bg-blue-600 selection:text-white`}>
          <pre className="leading-relaxed whitespace-pre font-mono">{currentCode}</pre>
        </div>
      </div>
    </div>
  );
};
