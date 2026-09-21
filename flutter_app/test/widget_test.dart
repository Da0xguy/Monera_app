import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monera/main.dart';
import 'package:monera/models/card_model.dart';
import 'package:monera/models/transaction_model.dart';
import 'package:monera/screens/auth_screen.dart';
import 'package:monera/screens/transaction_receipt_screen.dart';
import 'package:monera/widgets/monera_atm_card.dart';
import 'package:monera/widgets/transaction_signing_sheet.dart';

void main() {
  testWidgets('Monera app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MoneraNeobankApp(),
      ),
    );

    expect(find.text('Pay & Scan'), findsAtLeastNWidgets(1));
  });

  testWidgets('MoneraAtmCard renders Monera branding, card number, and details',
      (WidgetTester tester) async {
    const testCard = CardModel(
      id: 'crd_test_1',
      type: 'virtual',
      brand: 'mastercard',
      status: 'active',
      cardholderName: 'SOMA ORAKWUE',
      maskedPan: '5399 •••• •••• 4821',
      last4: '4821',
      expiryMonth: '08',
      expiryYear: '28',
      colorTheme: 'green',
      spendingLimitNgn: 2000000.0,
      spentThisMonthNgn: 150000.0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MoneraAtmCard(card: testCard),
        ),
      ),
    );

    expect(find.text('MONERA'), findsOneWidget);
    expect(find.text('5399 •••• •••• 4821'), findsOneWidget);
    expect(find.text('SOMA ORAKWUE'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('AuthScreen renders passwordless options and Monera branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    expect(find.text('MONERA'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign in with Passkey / Face ID'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('TransactionReceiptScreen renders receipt layout and share options',
      (WidgetTester tester) async {
    final testTx = TransactionModel(
      id: 'tx_test_receipt_1',
      title: 'Shoprite Supermarket Lekki',
      description: 'NIBSS NQR Payment',
      amountNgn: 48114.00,
      amountUsd: 31.65,
      type: 'nqr_merchant',
      channel: 'nibss_nqr',
      status: 'settled',
      createdAt: DateTime(2026, 9, 20, 18, 30, 0),
      authorizationCode: 'NQR_AUTH_9921',
      latencyMs: 168,
      onChainTxRef:
          '0x9f1a8c3d7e5b2a0c4e1f8a9b6c3d5e7f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d',
      senderName: 'Soma Orakwue',
      recipientName: 'Shoprite Supermarket Lekki',
      recipientBank: 'NIBSS NQR Merchant Switch',
      recipientAccount: '00020101021226500',
      sessionId: '100004202609201830009821849102',
      feeNgn: 0.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionReceiptScreen(transaction: testTx),
      ),
    );

    // Verify receipt header and branding
    expect(find.text('MONERA'), findsOneWidget);
    expect(find.text('OFFICIAL RECEIPT'), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('-₦48,114.00'), findsOneWidget);

    // Verify structured ledger details
    expect(find.text('Shoprite Supermarket Lekki'), findsOneWidget);
    expect(find.text('Session ID'), findsOneWidget);
    expect(find.text('100004202609201830009821849102'), findsOneWidget);
    expect(find.text('NDIC Insured • Verified on Monad L1'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Share Receipt'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Ensure button is visible before tapping in scrollable view
    await tester.ensureVisible(find.text('Share Receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Share Transaction Receipt'), findsOneWidget);
    expect(find.text('Share Receipt Image'), findsOneWidget);
    expect(find.text('Share as Text (WhatsApp / SMS)'), findsOneWidget);
    expect(find.text('Copy NIP Session ID'), findsOneWidget);
  });

  testWidgets('TransactionSigningSheet displays PIN keypad and amount',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TransactionSigningSheet(
              amountNgn: 25000.0,
              amountUsd: 16.45,
              title: 'TotalEnergies Fuel VI',
              recipientName: 'TotalEnergies Fuel VI',
              channel: 'nibss_nqr',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Authorize Transaction'), findsOneWidget);
    expect(find.text('₦25,000.00'), findsOneWidget);
    expect(find.text('≈ \$16.45 USDC'), findsOneWidget);
    expect(find.text('TotalEnergies Fuel VI'), findsOneWidget);
    expect(find.text('Enter 4-Digit Security PIN or Use Biometrics'),
        findsOneWidget);

    // Verify Keypad Digits
    expect(find.text('1'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
  });
}
