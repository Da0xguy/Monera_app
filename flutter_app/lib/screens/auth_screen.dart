// lib/screens/auth_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/monera_logo.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String _enteredPin = '';
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _buildCurrentStep(authState),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AuthState state) {
    switch (state.onboardingStep) {
      case 1:
        return _buildOtpView(state);
      case 2:
        return _buildPinSetupView(state);
      case 3:
        return _buildBiometricsView(state);
      case 4:
        return _buildWelcomeScreen(state);
      case 0:
      default:
        return _buildMainAuthView(state);
    }
  }

  // ==========================================
  // STEP 0: Main Login / Sign Up with Privy
  // ==========================================
  Widget _buildMainAuthView(AuthState state) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isSignIn = state.authMode == AuthMode.signIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Monera Logo & Wordmark
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: MoneraLogo(
              variant: MoneraLogoVariant.icon,
              size: 32,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'MONERA',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Non-Custodial Neobank on Monad L1',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),

        // Sign In / Create Account Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => authNotifier.setAuthMode(AuthMode.signUp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          !isSignIn ? AppColors.darkGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            !isSignIn ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => authNotifier.setAuthMode(AuthMode.signIn),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSignIn ? AppColors.darkGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isSignIn ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Phone Input Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSignIn
                    ? 'Enter your registered phone number'
                    : 'Get started with your phone number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Passwordless authentication via Privy OTP.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Nigerian Phone Field
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Row(
                      children: [
                        Text('🇳🇬', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text(
                          '+234',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '803 123 4821',
                        hintStyle: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.darkGreen, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                      color: AppColors.crimsonRed, fontSize: 11),
                ),
              ],
              const SizedBox(height: 16),

              // Continue Button
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final phone = _phoneController.text.trim().isEmpty
                            ? '803 123 4821'
                            : _phoneController.text.trim();
                        final success =
                            await authNotifier.sendPhoneOtp('+234 $phone');
                        if (success) {
                          _startResendTimer();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isSignIn ? 'Sign In with OTP' : 'Continue with Phone',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Divider
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderSubtle)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderSubtle)),
          ],
        ),
        const SizedBox(height: 20),

        // Google Sign-In Button
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await authNotifier.signInWithGoogle();
            if (ok && isSignIn && mounted) {
              context.go('/wallet');
            }
          },
          icon: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          label: const Text(
            'Continue with Google',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.borderSubtle),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Passkey Sign-In Button
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await authNotifier.signInWithPasskey();
            if (ok && isSignIn && mounted) {
              context.go('/wallet');
            }
          },
          icon: const Icon(
            Icons.fingerprint,
            color: AppColors.darkGreen,
            size: 22,
          ),
          label: const Text(
            'Sign in with Passkey / Face ID',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.borderSubtle),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Privy Non-Custodial Footer
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined,
                size: 14, color: AppColors.textTertiary),
            SizedBox(width: 6),
            Text(
              'Privy Non-Custodial Architecture • Monad L1 Enclave',
              style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STEP 1: OTP Verification
  // ==========================================
  Widget _buildOtpView(AuthState state) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => authNotifier.setOnboardingStep(0),
        ),
        const SizedBox(height: 12),
        const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the 6-digit code sent to ${state.enteredPhone}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // 6 OTP Digit Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 46,
              height: 54,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.darkGreen, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: AppColors.crimsonRed, fontSize: 11),
          ),
        ],
        const SizedBox(height: 20),

        // Quick Auto-fill button for testing
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              const code = '123456';
              for (int i = 0; i < 6; i++) {
                _otpControllers[i].text = code[i];
              }
            },
            icon: const Icon(Icons.flash_on, size: 14, color: AppColors.lime),
            label: const Text(
              'Demo Auto-fill: 123456',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Verify Button
        ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  final code = _otpControllers.map((c) => c.text).join().trim();
                  final ok = await authNotifier.verifyOtp(code);
                  if (ok && state.authMode == AuthMode.signIn && mounted) {
                    context.go('/wallet');
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Verify Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Resend Timer
        Center(
          child: _resendSeconds > 0
              ? Text(
                  'Resend code in ${_resendSeconds}s',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                )
              : TextButton(
                  onPressed: () {
                    _startResendTimer();
                    authNotifier.sendPhoneOtp(state.enteredPhone);
                  },
                  child: const Text(
                    'Resend SMS Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: PIN Setup (Per Spec Section 7, Item 1)
  // ==========================================
  Widget _buildPinSetupView(AuthState state) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.pin, color: AppColors.darkGreen, size: 36),
        const SizedBox(height: 12),
        const Text(
          'Set 4-Digit Security PIN',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Required for ATM card withdrawals, NQR scan-to-pay, and high-value transfers.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),

        // 4 PIN Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < _enteredPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isFilled ? AppColors.darkGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isFilled ? AppColors.darkGreen : AppColors.borderSubtle,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 36),

        // Number Keypad
        _buildNumericKeypad(
          onDigitTap: (digit) {
            if (_enteredPin.length < 4) {
              setState(() => _enteredPin += digit);
              if (_enteredPin.length == 4) {
                authNotifier.setSecurityPin(_enteredPin);
              }
            }
          },
          onBackspace: () {
            if (_enteredPin.isNotEmpty) {
              setState(() => _enteredPin =
                  _enteredPin.substring(0, _enteredPin.length - 1));
            }
          },
        ),
      ],
    );
  }

  Widget _buildNumericKeypad({
    required Function(String) onDigitTap,
    required VoidCallback onBackspace,
  }) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 72, height: 72);
            }
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (key == '⌫') {
                  onBackspace();
                } else {
                  onDigitTap(key);
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  key,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // ==========================================
  // STEP 3: Biometrics Opt-In
  // ==========================================
  Widget _buildBiometricsView(AuthState state) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 36),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.darkGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.darkGreen, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.fingerprint,
              color: AppColors.darkGreen,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enable Biometric Security',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Authorize instant card transactions, ATM PIN verification, and quick unlocks using Face ID or Touch ID.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: () => authNotifier.optInBiometrics(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Enable Biometrics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => authNotifier.optInBiometrics(false),
          child: const Text(
            'Skip for now',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 4: Welcome to Monera (Matching Screen Figma Photo!)
  // ==========================================
  Widget _buildWelcomeScreen(AuthState state) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Enclave Active Top Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield, color: AppColors.darkGreen, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'ENCLAVE ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Monera Logo Card
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: MoneraLogo(
              variant: MoneraLogoVariant.icon,
              size: 38,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Welcome Headline
        const Text(
          'Welcome to Monera',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your wallet is ready. You\'re all set to manage your sovereign wealth.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Step Complete Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                    'STEP COMPLETE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.lime.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '3 of 3',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCheckItem('Account created'),
              const SizedBox(height: 10),
              _buildCheckItem('Credentials initialized'),
              const SizedBox(height: 10),
              _buildCheckItem(
                  'Phone verified (${state.enteredPhone.isNotEmpty ? state.enteredPhone : "+234 •••• 4821"})'),
              const SizedBox(height: 10),
              _buildCheckItem('Enclave secured & biometric enclave'),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.enclaveId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Icon(Icons.copy,
                      size: 14, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Dashboard Button
        ElevatedButton(
          onPressed: () {
            authNotifier.finishOnboarding();
            context.go('/wallet');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Center(
          child: Text(
            '• LEVEL 4 CRYPTO ENCLAVE • PRIVY ZERO-KNOWLEDGE',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppColors.lime,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 12,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
