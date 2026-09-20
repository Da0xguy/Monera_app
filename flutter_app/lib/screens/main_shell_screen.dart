// lib/screens/main_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/wallet')) return 0;
    if (location.startsWith('/pay-scan')) return 1;
    if (location.startsWith('/cards')) return 2;
    if (location.startsWith('/earn')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/wallet');
        break;
      case 1:
        context.go('/pay-scan');
        break;
      case 2:
        context.go('/cards');
        break;
      case 3:
        context.go('/earn');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF060B18).withValues(alpha: 0.98),
          border: const Border(
            top: BorderSide(color: Color(0xFF0F1E3D), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  currentIndex: selectedIndex,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Wallet',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  currentIndex: selectedIndex,
                  icon: Icons.qr_code_scanner_outlined,
                  activeIcon: Icons.qr_code_scanner,
                  label: 'Pay & Scan',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  currentIndex: selectedIndex,
                  icon: Icons.credit_card_outlined,
                  activeIcon: Icons.credit_card,
                  label: 'Cards',
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  currentIndex: selectedIndex,
                  icon: Icons.trending_up_outlined,
                  activeIcon: Icons.trending_up,
                  label: 'Earn',
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  currentIndex: selectedIndex,
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune,
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.electricBlue.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppColors.electricBlue : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.electricBlue : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
