// lib/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

enum CurrencyType { ngn, usd, monad }

class WalletState {
  final UserModel user;
  final double availableBalanceUsd;
  final double heldBalanceUsd;
  final double fxUsdToNgn;
  final double monadUsdPrice;
  final CurrencyType selectedCurrency;
  final bool isBalanceVisible;
  final bool isLoading;
  final List<TransactionModel> transactions;

  const WalletState({
    required this.user,
    this.availableBalanceUsd = 1250.00,
    this.heldBalanceUsd = 0.00,
    this.fxUsdToNgn = 1485.00,
    this.monadUsdPrice = 14.50,
    this.selectedCurrency = CurrencyType.ngn,
    this.isBalanceVisible = true,
    this.isLoading = false,
    this.transactions = const [],
  });

  String get formattedBalance {
    if (!isBalanceVisible) return '••••••••';
    switch (selectedCurrency) {
      case CurrencyType.ngn:
        final ngn = availableBalanceUsd * fxUsdToNgn;
        return '₦${ngn.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      case CurrencyType.usd:
        return '\$${availableBalanceUsd.toStringAsFixed(2)}';
      case CurrencyType.monad:
        final monad = availableBalanceUsd / monadUsdPrice;
        return '⨇ ${monad.toStringAsFixed(3)} MONAD';
    }
  }

  WalletState copyWith({
    UserModel? user,
    double? availableBalanceUsd,
    double? heldBalanceUsd,
    double? fxUsdToNgn,
    double? monadUsdPrice,
    CurrencyType? selectedCurrency,
    bool? isBalanceVisible,
    bool? isLoading,
    List<TransactionModel>? transactions,
  }) {
    return WalletState(
      user: user ?? this.user,
      availableBalanceUsd: availableBalanceUsd ?? this.availableBalanceUsd,
      heldBalanceUsd: heldBalanceUsd ?? this.heldBalanceUsd,
      fxUsdToNgn: fxUsdToNgn ?? this.fxUsdToNgn,
      monadUsdPrice: monadUsdPrice ?? this.monadUsdPrice,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref ref;

  WalletNotifier(this.ref)
      : super(
          WalletState(
            user: const UserModel(
              id: 'usr_monera_9921',
              privyUserId: 'did:privy:cm2e9k1a00192h9x87zla8p',
              walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
              name: 'Ayobami Oketona',
              email: 'ayobamioketona@gmail.com',
              phone: '+234 803 123 4567',
              kycStatus: 'verified',
              bvnMasked: '2224******9',
              ninMasked: '7819******2',
            ),
            transactions: [
              TransactionModel(
                id: 'tx_sudo_001',
                title: 'Uber Lagos B.V.',
                description: 'Sudo Mastercard Point of Sale (POS)',
                amountNgn: 14500.00,
                amountUsd: 9.76,
                type: 'pos_purchase',
                channel: 'sudo_mastercard',
                status: 'settled',
                createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
                authorizationCode: 'AUTH_SUDO_88329',
                latencyMs: 67,
                onChainTxRef: '0x9a8f23b1c4e7...001',
              ),
              TransactionModel(
                id: 'tx_nqr_002',
                title: 'Shoprite Lekki Mall',
                description: 'NIBSS NQR Instant Merchant Payment',
                amountNgn: 48114.00,
                amountUsd: 32.40,
                type: 'nqr_merchant',
                channel: 'nibss_nqr',
                status: 'settled',
                createdAt: DateTime.now().subtract(const Duration(hours: 3)),
                authorizationCode: 'NQR_REF_991823',
                latencyMs: 168,
                onChainTxRef: '0x334bc12df09a...712',
              ),
              TransactionModel(
                id: 'tx_fund_003',
                title: 'Wema Bank Transfer',
                description: 'Inbound Virtual Account Funding',
                amountNgn: 371250.00,
                amountUsd: 250.00,
                type: 'deposit',
                channel: 'nip_transfer',
                status: 'settled',
                createdAt: DateTime.now().subtract(const Duration(hours: 18)),
                latencyMs: 820,
              ),
            ],
          ),
        );

  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceVisible: !state.isBalanceVisible);
  }

  void setCurrency(CurrencyType currency) {
    state = state.copyWith(selectedCurrency: currency);
  }

  Future<void> simulateDeposit(double amountNgn) async {
    state = state.copyWith(isLoading: true);
    final usdCredit = amountNgn / state.fxUsdToNgn;

    final newTx = TransactionModel(
      id: 'tx_dep_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Wema Bank Virtual Funding',
      description: 'Instant NIP settlement into Monad Ledger',
      amountNgn: amountNgn,
      amountUsd: usdCredit,
      type: 'deposit',
      channel: 'nip_transfer',
      status: 'settled',
      createdAt: DateTime.now(),
      latencyMs: 450,
      onChainTxRef: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}...credit',
    );

    state = state.copyWith(
      availableBalanceUsd: state.availableBalanceUsd + usdCredit,
      transactions: [newTx, ...state.transactions],
      isLoading: false,
    );
  }
}

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});
