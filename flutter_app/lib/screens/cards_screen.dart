// lib/screens/cards_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../providers/card_provider.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  bool _isFlipped = false;
  int _selectedCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(cardsNotifierProvider);
    final cardNotifier = ref.read(cardsNotifierProvider.notifier);

    if (cardState.cards.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final card = cardState.cards[_selectedCardIndex.clamp(0, cardState.cards.length - 1)];
    final isFrozen = card.isFrozen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sudo Africa Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.electricBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Virtual Mastercard creation initialized')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card switcher if multiple cards
            if (cardState.cards.length > 1)
              Row(
                children: List.generate(cardState.cards.length, (i) {
                  final isSelected = i == _selectedCardIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCardIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.electricBlue : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        cardState.cards[i].type == 'virtual' ? 'Virtual Card' : 'Physical Card',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),

            // The Interactive Mastercard
            GestureDetector(
              onTap: () => setState(() => _isFlipped = !_isFlipped),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isFrozen ? AppColors.frozenCardGradient : AppColors.virtualCardGradient,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isFrozen ? Colors.blueGrey : AppColors.electricBlue.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isFrozen
                          ? Colors.black.withValues(alpha: 0.5)
                          : AppColors.cobaltBlue.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Morenad • Sudo JIT Mastercard',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white70),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: isFrozen ? AppColors.crimsonRed.withValues(alpha: 0.25) : AppColors.emeraldGreen.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isFrozen ? AppColors.crimsonRed : AppColors.emeraldGreen,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            isFrozen ? 'FROZEN' : 'ACTIVE',
                            style: TextStyle(
                              color: isFrozen ? Colors.redAccent : AppColors.emeraldGreen,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _isFlipped
                          ? 'CVV: 891    EXP: ${card.expiryMonth}/${card.expiryYear}'
                          : card.maskedPan,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card.cardholderName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70),
                        ),
                        const Text(
                          'Mastercard',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Card Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionTile(
                  icon: isFrozen ? Icons.lock_open : Icons.ac_unit,
                  label: isFrozen ? 'Unfreeze' : 'Freeze Card',
                  color: isFrozen ? AppColors.emeraldGreen : AppColors.electricBlue,
                  onTap: () => cardNotifier.toggleFreeze(card.id),
                ),
                _buildActionTile(
                  icon: _isFlipped ? Icons.credit_card : Icons.visibility,
                  label: _isFlipped ? 'Show Front' : 'Show CVV',
                  color: AppColors.lightBlue,
                  onTap: () => setState(() => _isFlipped = !_isFlipped),
                ),
                _buildActionTile(
                  icon: Icons.tune,
                  label: 'Limits',
                  color: AppColors.cobaltBlue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Monthly spend limit: ₦2,000,000.00')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly Spend Progress
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Spend Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                      Text(
                        '₦${NumberFormat('#,##0').format(card.spentThisMonthNgn)} / ₦${NumberFormat('#,##0').format(card.spendingLimitNgn)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (card.spentThisMonthNgn / card.spendingLimitNgn).clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceElevated,
                    color: AppColors.electricBlue,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'JIT Webhook intercepts POS swipes and debits Monad L1 USDC instantly with zero pre-funding required.',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
