# Morenad Neobank (Flutter + Dart)

Production-ready Flutter architecture for **Morenad** — non-custodial neobank on **Monad L1 (Chain ID: 10143)** featuring **Sudo Africa Mastercard JIT (<200ms)** and **NIBSS NQR** payments.

## Color & Design System
- **Background**: Pitch Obsidian Black (`#030712`)
- **Surfaces**: Deep Blue Slate Containers (`#070E1E`, `#0D172E`)
- **Accents**: Electric Cyber Blue (`#00B4D8`, `#0077B6`) and Cyan Glow (`#90E0EF`)
- **Settlement Status**: Emerald Green (`#10B981`)

## Tech Stack & Architecture
- **State Management**: `flutter_riverpod: ^2.5.1` (`StateNotifierProvider`, `ProviderScope`)
- **Declarative Routing**: `go_router: ^14.0.0` (`ShellRoute`, sub-routes, parameter passing)
- **Networking**: `dio: ^5.4.3+1` (Interceptors, bearer auth token injection, connection timeouts)
- **Vector Assets**: `flutter_svg: ^2.0.10+1`
- **Security & Hardware**: `flutter_secure_storage: ^9.0.0`, `local_auth: ^2.1.8` (Biometrics)

## Directory Structure
```
flutter_app/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart                          # ProviderScope + MaterialApp.router setup
    ├── core/
    │   ├── constants/
    │   │   └── app_colors.dart            # Obsidian Black & Electric Blue palette
    │   ├── network/
    │   │   └── api_client.dart            # Dio client with auth interceptor & timeouts
    │   ├── router/
    │   │   └── app_router.dart            # GoRouter with ShellRoute & bottom navigation
    │   └── theme/
    │       └── app_theme.dart             # Material 3 dark black & blue ThemeData
    ├── models/
    │   ├── user_model.dart                # KYC Tier 3, Privy DID, Monad address
    │   ├── card_model.dart                # Sudo Mastercard virtual & physical card entities
    │   ├── transaction_model.dart         # Ledger records, latencies, Monad tx hashes
    │   └── vault_model.dart               # TreasuryVault.sol 8.4% APY idle yield
    ├── services/
    │   ├── sudo_jit_service.dart          # Dio calls for freeze/unfreeze, PIN reveal, limits
    │   ├── nibss_nqr_service.dart         # Dio calls for NIBSS NQR scanning & settlement
    │   └── monad_rpc_service.dart         # Dio JSON-RPC 2.0 client for Monad L1 (10143)
    ├── providers/
    │   ├── api_providers.dart             # Riverpod Dio and service providers
    │   ├── wallet_provider.dart           # Riverpod state notifier for balance & ledger
    │   ├── card_provider.dart             # Riverpod state notifier for Sudo cards
    │   └── earn_provider.dart             # Riverpod state notifier for TreasuryVault yield
    └── screens/
        ├── main_shell_screen.dart         # Bottom navigation shell for GoRouter
        ├── wallet_home_screen.dart        # Home balance, currency pill, action bar, ledger
        ├── pay_scan_screen.dart           # NIBSS NQR viewfinder, presets, NIP transfer
        ├── cards_screen.dart              # Interactive 3D card flip, freeze, spend limits
        ├── earn_screen.dart               # Ticking yield counter, deposit/withdraw
        ├── settings_screen.dart           # BVN/NIN verification, biometrics, RPC node
        └── transaction_receipt_screen.dart# Transaction receipt sheet with Monad tx hash
```

## How to Run on iOS / Android
1. Enter the Flutter app directory:
   ```bash
   cd flutter_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run on device or simulator:
   ```bash
   flutter run
   ```
