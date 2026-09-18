// lib/screens/wallet_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/monera_logo.dart';

class WalletHomeScreen extends ConsumerWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletNotifierProvider);
    final walletNotifier = ref.read(walletNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.electricBlue,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            // refresh data
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(context, walletState, walletNotifier),
                const SizedBox(height: 18),
                _buildBalanceCard(walletState, walletNotifier),
                const SizedBox(height: 22),
                _buildQuickActions(context, walletNotifier),
                const SizedBox(height: 22),
                _buildSudoCardBanner(context),
                const SizedBox(height: 24),
                _buildTransactionHeader(),
                const SizedBox(height: 12),
                _buildTransactionList(context, walletState.transactions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    WalletState state,
    WalletNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cobaltBlue, AppColors.electricBlue],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: MoneraLogo(size: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.user.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: AppColors.emeraldGreen, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Monad L1 (10143) • Tier 3 Verified',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Currency Pill (NGN | USD | MONAD)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              _buildCurrencyChip('NGN', CurrencyType.ngn, state.selectedCurrency, notifier),
              _buildCurrencyChip('USD', CurrencyType.usd, state.selectedCurrency, notifier),
              _buildCurrencyChip('MONAD', CurrencyType.monad, state.selectedCurrency, notifier),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyChip(
    String label,
    CurrencyType type,
    CurrencyType active,
    WalletNotifier notifier,
  ) {
    final isSelected = type == active;
    return GestureDetector(
      onTap: () => notifier.setCurrency(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletState state, WalletNotifier notifier) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.balanceCardGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderGlow.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cobaltBlue.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.08,
                child: const MoneraLogo(size: 130, color: AppColors.electricBlue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text(
                        'AVAILABLE BALANCE',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.lightBlue,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => notifier.toggleBalanceVisibility(),
                        icon: Icon(
                          state.isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.formattedBalance,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.electricBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '≈ \$${state.availableBalanceUsd.toStringAsFixed(2)} USDC on Monad L1 Ledger',
                        style: const TextStyle(fontSize: 11, color: AppColors.lightBlue, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WalletNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: Icons.add,
          label: 'Deposit',
          color: AppColors.emeraldGreen,
          onTap: () {
            // Show bottom sheet with Wema virtual account & instant simulator
            _showDepositModal(context, notifier);
          },
        ),
        _buildActionItem(
          icon: Icons.qr_code_scanner,
          label: 'Pay & Scan',
          color: AppColors.electricBlue,
          onTap: () => context.go('/pay-scan'),
        ),
        _buildActionItem(
          icon: Icons.credit_card,
          label: 'Cards',
          color: AppColors.lightBlue,
          onTap: () => context.go('/cards'),
        ),
        _buildActionItem(
          icon: Icons.trending_up,
          label: 'Earn',
          color: AppColors.cobaltBlue,
          onTap: () => context.go('/earn'),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.35), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSudoCardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/cards'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGlow.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.deepNavy, AppColors.cobaltBlue]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.credit_card, color: AppColors.electricBlue, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sudo Mastercard •••• 4821', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('JIT Webhook <200ms Active • Instant POS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emeraldGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('ACTIVE', style: TextStyle(color: AppColors.emeraldGreen, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        Text(
          'Recent Ledger Activity',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        Text(
          'Sub-second settlement',
          style: TextStyle(fontSize: 11, color: AppColors.electricBlue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context, List<TransactionModel> txs) {
    return Column(
      children: txs.map((tx) {
        final isCredit = tx.isCredit;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => context.push('/receipt', extra: tx),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isCredit ? AppColors.emeraldGreen : AppColors.electricBlue).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? AppColors.emeraldGreen : AppColors.electricBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                        Text(tx.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isCredit ? '+' : '-'}₦${NumberFormat('#,##0.00').format(tx.amountNgn)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isCredit ? AppColors.emeraldGreen : AppColors.textPrimary,
                        ),
                      ),
                      if (tx.latencyMs != null)
                        Text(
                          '${tx.latencyMs}ms JIT',
                          style: const TextStyle(color: AppColors.electricBlue, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDepositModal(BuildContext context, WalletNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fund via Nigerian Bank Transfer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Transfers to this dedicated Wema virtual account settle into Monad L1 in ~15 seconds.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGlow),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text('Bank Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('Wema Bank / ALAT', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text('Account Number', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('0291884721', style: TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                notifier.simulateDeposit(50000.00);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('₦50,000.00 simulated deposit credited to Monad L1!'),
                    backgroundColor: AppColors.emeraldGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Simulate ₦50,000 Inbound Transfer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
