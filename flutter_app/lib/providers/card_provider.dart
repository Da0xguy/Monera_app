// lib/providers/card_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import 'api_providers.dart';

class CardsState {
  final List<CardModel> cards;
  final bool isLoading;
  final String? error;

  const CardsState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
  });

  CardsState copyWith({
    List<CardModel>? cards,
    bool? isLoading,
    String? error,
  }) {
    return CardsState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CardsNotifier extends StateNotifier<CardsState> {
  final Ref ref;

  CardsNotifier(this.ref)
      : super(
          const CardsState(
            cards: [
              CardModel(
                id: 'crd_sudo_4821',
                type: 'virtual',
                brand: 'mastercard',
                status: 'active',
                cardholderName: 'AYOBAMI OKETONA',
                maskedPan: '5399 •••• •••• 4821',
                last4: '4821',
                expiryMonth: '08',
                expiryYear: '28',
                colorTheme: 'blue',
                spendingLimitNgn: 2000000.0,
                spentThisMonthNgn: 359500.0,
              ),
              CardModel(
                id: 'crd_sudo_9102',
                type: 'physical',
                brand: 'mastercard',
                status: 'active',
                cardholderName: 'AYOBAMI OKETONA',
                maskedPan: '5399 •••• •••• 9102',
                last4: '9102',
                expiryMonth: '11',
                expiryYear: '27',
                colorTheme: 'obsidian',
                spendingLimitNgn: 5000000.0,
                spentThisMonthNgn: 120000.0,
              ),
            ],
          ),
        );

  Future<void> toggleFreeze(String cardId) async {
    final currentList = [...state.cards];
    final index = currentList.indexWhere((c) => c.id == cardId);
    if (index == -1) return;

    final target = currentList[index];
    final newStatus = target.status == 'frozen' ? 'active' : 'frozen';

    currentList[index] = CardModel(
      id: target.id,
      type: target.type,
      brand: target.brand,
      status: newStatus,
      cardholderName: target.cardholderName,
      maskedPan: target.maskedPan,
      last4: target.last4,
      expiryMonth: target.expiryMonth,
      expiryYear: target.expiryYear,
      colorTheme: target.colorTheme,
      spendingLimitNgn: target.spendingLimitNgn,
      spentThisMonthNgn: target.spentThisMonthNgn,
    );

    state = state.copyWith(cards: currentList);

    // Call Sudo JIT service in background
    try {
      await ref.read(sudoServiceProvider).toggleFreeze(cardId);
    } catch (_) {
      // Local optimistic update kept for instant responsiveness
    }
  }
}

final cardsNotifierProvider =
    StateNotifierProvider<CardsNotifier, CardsState>((ref) {
  return CardsNotifier(ref);
});
