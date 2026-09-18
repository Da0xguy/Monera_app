// lib/providers/earn_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vault_model.dart';

class EarnState {
  final VaultModel vault;
  final bool isDepositing;
  final bool isWithdrawing;

  const EarnState({
    required this.vault,
    this.isDepositing = false,
    this.isWithdrawing = false,
  });

  EarnState copyWith({
    VaultModel? vault,
    bool? isDepositing,
    bool? isWithdrawing,
  }) {
    return EarnState(
      vault: vault ?? this.vault,
      isDepositing: isDepositing ?? this.isDepositing,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
    );
  }
}

class EarnNotifier extends StateNotifier<EarnState> {
  EarnNotifier()
      : super(
          const EarnState(
            vault: VaultModel(
              vaultBalanceUsd: 850.00,
              accruedYieldUsd: 4.1284,
              apyPercent: 8.4,
              contractAddress: '0x8338ECa912a7d23a54bC4402a7737dCba59F7C2B',
              networkName: 'Monad L1 Devnet',
            ),
          ),
        );

  void tickYield() {
    // 8.4% APY continuous compound simulation
    final perSecRate = (state.vault.apyPercent / 100.0) / (365.25 * 86400.0);
    final increment = state.vault.vaultBalanceUsd * perSecRate;
    state = state.copyWith(
      vault: state.vault.copyWith(
        accruedYieldUsd: state.vault.accruedYieldUsd + increment,
      ),
    );
  }

  Future<void> deposit(double amountUsd) async {
    state = state.copyWith(isDepositing: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isDepositing: false,
      vault: state.vault.copyWith(
        vaultBalanceUsd: state.vault.vaultBalanceUsd + amountUsd,
      ),
    );
  }

  Future<void> withdraw(double amountUsd) async {
    state = state.copyWith(isWithdrawing: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isWithdrawing: false,
      vault: state.vault.copyWith(
        vaultBalanceUsd: (state.vault.vaultBalanceUsd - amountUsd).clamp(0.0, double.infinity),
      ),
    );
  }
}

final earnNotifierProvider =
    StateNotifierProvider<EarnNotifier, EarnState>((ref) {
  return EarnNotifier();
});
