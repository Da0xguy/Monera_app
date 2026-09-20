// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletNotifierProvider);
    final user = walletState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account & Security',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.cobaltBlue, AppColors.electricBlue]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('AO',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(user.email,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Tier 3',
                      style: TextStyle(
                          color: AppColors.emeraldGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('PREFERRED DISPLAY CURRENCY'),
          _buildCurrencySelector(ref, walletState),
          const SizedBox(height: 20),

          _buildSectionHeader('NIGERIAN BANKING COMPLIANCE'),
          _buildItem(Icons.verified_user, 'KYC Status', 'BVN & NIN Verified',
              trailing: const Icon(Icons.check_circle,
                  color: AppColors.emeraldGreen, size: 18)),
          _buildItem(Icons.badge_outlined, 'Linked BVN', user.bvnMasked,
              trailing: const Text('Active',
                  style: TextStyle(
                      color: AppColors.emeraldGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
          _buildItem(Icons.credit_card, 'Linked NIN', user.ninMasked,
              trailing: const Text('Active',
                  style: TextStyle(
                      color: AppColors.emeraldGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),

          _buildSectionHeader('SECURITY & HARDWARE BIOMETRICS'),
          _buildItem(
            Icons.fingerprint,
            'Biometric Authentication',
            'FaceID / TouchID for POS & transfers',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.electricBlue,
            ),
          ),
          _buildItem(Icons.pin, 'Transaction PIN',
              'Required for transfers over ₦50,000'),
          const SizedBox(height: 20),

          _buildSectionHeader('MONAD L1 NETWORK INFRASTRUCTURE'),
          _buildItem(Icons.dns, 'RPC Node Endpoint',
              'https://rpc.monad.xyz (10,000 TPS)'),
          _buildItem(Icons.link, 'Privy Embedded Wallet',
              '${user.walletAddress.substring(0, 8)}...${user.walletAddress.substring(user.walletAddress.length - 6)}'),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(WidgetRef ref, WalletState walletState) {
    final notifier = ref.read(walletNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your preferred currency for dashboard balances',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCurrencyChip('NGN', CurrencyType.ngn,
                  walletState.selectedCurrency, notifier),
              const SizedBox(width: 8),
              _buildCurrencyChip('USD', CurrencyType.usd,
                  walletState.selectedCurrency, notifier),
              const SizedBox(width: 8),
              _buildCurrencyChip('MONAD', CurrencyType.monad,
                  walletState.selectedCurrency, notifier),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip(
    String label,
    CurrencyType type,
    CurrencyType active,
    WalletNotifier notifier,
  ) {
    final isSelected = type == active;
    return Expanded(
      child: GestureDetector(
        onTap: () => notifier.setCurrency(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.electricBlue : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppColors.electricBlue : AppColors.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle,
      {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.electricBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
