// lib/screens/earn_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/earn_provider.dart';

class EarnScreen extends ConsumerStatefulWidget {
  const EarnScreen({super.key});

  @override
  ConsumerState<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends ConsumerState<EarnScreen> {
  Timer? _yieldTimer;

  @override
  void initState() {
    super.initState();
    // Continuous compounding simulation every 1 second
    _yieldTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(earnNotifierProvider.notifier).tickYield();
    });
  }

  @override
  void dispose() {
    _yieldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earnState = ref.watch(earnNotifierProvider);
    final vault = earnState.vault;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earn Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vault Balance Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0C2647), // Deep midnight cyber blue
                    Color(0xFF030A18), // Pure obsidian black
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cobaltBlue.withValues(alpha: 0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'IDLE CAPITAL YIELD VAULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${vault.apyPercent}% Net APY',
                          style: const TextStyle(
                            color: AppColors.emeraldGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '\$${vault.vaultBalanceUsd.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Accrued Interest: +\$${vault.accruedYieldUsd.toStringAsFixed(5)} USDC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Smart Contract Specs
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TreasuryVault.sol on Monad L1',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Earns auto-compounding yield on idle balances. Whenever card swipe or QR checkout occurs, funds unvault in the exact same block with 0% penalty and zero lockup delay.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.45),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Contract Address', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      Text(
                        '${vault.contractAddress.substring(0, 8)}...${vault.contractAddress.substring(vault.contractAddress.length - 6)}',
                        style: const TextStyle(color: AppColors.electricBlue, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: earnState.isDepositing
                        ? null
                        : () => ref.read(earnNotifierProvider.notifier).deposit(100.0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: earnState.isDepositing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Deposit \$100', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: earnState.isWithdrawing
                        ? null
                        : () => ref.read(earnNotifierProvider.notifier).withdraw(50.0),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderGlow),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: earnState.isWithdrawing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Withdraw \$50', style: TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
