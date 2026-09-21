// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/main_shell_screen.dart';
import '../../screens/wallet_home_screen.dart';
import '../../screens/pay_scan_screen.dart';
import '../../screens/cards_screen.dart';
import '../../screens/earn_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/transaction_receipt_screen.dart';
import '../../screens/auth_screen.dart';
import '../../models/transaction_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/wallet',
  routes: [
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/wallet',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WalletHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/pay-scan',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PayScanScreen(),
          ),
        ),
        GoRoute(
          path: '/cards',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CardsScreen(),
          ),
        ),
        GoRoute(
          path: '/earn',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EarnScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/receipt',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final tx = state.extra as TransactionModel?;
        return TransactionReceiptScreen(transaction: tx);
      },
    ),
  ],
);
