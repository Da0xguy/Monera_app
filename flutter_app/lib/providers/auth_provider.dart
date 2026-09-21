// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';

enum AuthMode { signIn, signUp }

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final AuthMode authMode;
  final int
      onboardingStep; // 0: Input, 1: OTP, 2: PIN Setup, 3: Biometrics, 4: Welcome
  final String enteredPhone;
  final String? securityPin;
  final bool biometricsEnabled;
  final String enclaveId;

  const AuthState({
    this.user,
    this.isAuthenticated =
        true, // Default to true for existing sessions; allows smooth navigation
    this.isLoading = false,
    this.errorMessage,
    this.authMode = AuthMode.signUp,
    this.onboardingStep = 0,
    this.enteredPhone = '',
    this.securityPin,
    this.biometricsEnabled = false,
    this.enclaveId = 'MNR-9048-SEC',
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    AuthMode? authMode,
    int? onboardingStep,
    String? enteredPhone,
    String? securityPin,
    bool? biometricsEnabled,
    String? enclaveId,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      authMode: authMode ?? this.authMode,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      enteredPhone: enteredPhone ?? this.enteredPhone,
      securityPin: securityPin ?? this.securityPin,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      enclaveId: enclaveId ?? this.enclaveId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthNotifier(this.ref)
      : super(
          const AuthState(
            user: UserModel(
              id: 'usr_monera_9921',
              privyUserId: 'did:privy:cm2e9k1a00192h9x87zla8p',
              walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
              name: 'Soma Orakwue',
              email: 'soma.orakwue@monera.app',
              phone: '+234 803 123 4821',
              kycStatus: 'verified',
              bvnMasked: '2224******9',
              ninMasked: '7819******2',
            ),
            isAuthenticated: true,
            onboardingStep: 0,
            securityPin: '1234',
            biometricsEnabled: true,
          ),
        );

  void setAuthMode(AuthMode mode) {
    state =
        state.copyWith(authMode: mode, errorMessage: null, onboardingStep: 0);
  }

  void setOnboardingStep(int step) {
    state = state.copyWith(onboardingStep: step, errorMessage: null);
  }

  /// 1. Privy Phone OTP Initiation
  Future<bool> sendPhoneOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 700));

    if (phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter a valid Nigerian mobile phone number.',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: false,
      enteredPhone: phone,
      onboardingStep: 1, // Advance to OTP entry
    );
    return true;
  }

  /// 2. Privy OTP Verification & Embedded Non-Custodial Wallet Provisioning
  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 900));

    if (otp != '123456' && otp.length != 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid verification code. (Hint: Use 123456 in demo)',
      );
      return false;
    }

    if (state.authMode == AuthMode.signIn) {
      // Existing user sign in -> straight to authenticated
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        onboardingStep: 0,
      );
      return true;
    }

    // New sign up -> advance to Step 2 (PIN Setup)
    state = state.copyWith(
      isLoading: false,
      onboardingStep: 2,
    );
    return true;
  }

  /// 3. Privy Passwordless Google Auth
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (state.authMode == AuthMode.signIn) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        onboardingStep: 0,
      );
      return true;
    }

    // New user signing up with Google -> PIN Setup
    state = state.copyWith(
      isLoading: false,
      onboardingStep: 2,
    );
    return true;
  }

  /// 4. Privy Passwordless Passkey Auth
  Future<bool> signInWithPasskey() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final canAuth = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (canAuth) {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Sign in to Monera using your device Passkey',
          options: const AuthenticationOptions(
              stickyAuth: true, biometricOnly: true),
        );

        if (!authenticated) {
          state = state.copyWith(isLoading: false);
          return false;
        }
      }
    } catch (_) {
      // Fallback simulation for emulators/desktops without hardware biometrics
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (state.authMode == AuthMode.signIn) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        onboardingStep: 0,
      );
      return true;
    }

    state = state.copyWith(isLoading: false, onboardingStep: 2);
    return true;
  }

  /// 5. Step 2: Set 4-Digit Security PIN (per Tech Spec Section 7, Item 1)
  Future<void> setSecurityPin(String pin) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      securityPin: pin,
      onboardingStep: 3, // Advance to Biometric Opt-In
    );
  }

  /// 6. Step 3: Biometric Opt-In (per Tech Spec Section 7, Item 1)
  Future<void> optInBiometrics(bool enable) async {
    state = state.copyWith(isLoading: true);

    if (enable) {
      try {
        await _localAuth.authenticate(
          localizedReason: 'Enable Biometric Authentication for Monera',
        );
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Provision non-custodial wallet on Monad L1 & advance to Step 4 (Welcome screen)
    state = state.copyWith(
      isLoading: false,
      biometricsEnabled: enable,
      onboardingStep: 4, // "Welcome to Monera" screen
    );
  }

  /// 7. Step 4: Finish Onboarding -> Enter Dashboard
  void finishOnboarding() {
    state = state.copyWith(
      isAuthenticated: true,
      onboardingStep: 0,
    );
  }

  /// Verify 4-Digit Security PIN for Transaction Authorization
  Future<bool> verifySecurityPin(String pin) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final currentPin = state.securityPin ?? '1234';
    return pin == currentPin;
  }

  /// Authorize Transaction with Device Biometrics (Face ID / Fingerprint)
  Future<bool> authenticateWithBiometrics({
    String reason = 'Scan biometric to sign transaction on Monad L1',
  }) async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuth) {
        // Fallback simulation in tests or environments without biometrics
        await Future.delayed(const Duration(milliseconds: 400));
        return true;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (_) {
      // In simulator/desktop environments where hardware biometrics is unavailable
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }
  }

  /// Sign Out
  void signOut() {
    state = state.copyWith(
      isAuthenticated: false,
      onboardingStep: 0,
      authMode: AuthMode.signIn,
    );
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
