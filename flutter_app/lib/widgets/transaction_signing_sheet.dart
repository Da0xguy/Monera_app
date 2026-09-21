// lib/widgets/transaction_signing_sheet.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';

Future<TransactionModel?> showTransactionSigningSheet({
  required BuildContext context,
  required double amountNgn,
  required double amountUsd,
  required String title,
  required String recipientName,
  required String channel,
  String? recipientBank,
  String? recipientAccount,
  String? type,
  String? merchantCategory,
}) {
  return showModalBottomSheet<TransactionModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionSigningSheet(
      amountNgn: amountNgn,
      amountUsd: amountUsd,
      title: title,
      recipientName: recipientName,
      channel: channel,
      recipientBank: recipientBank,
      recipientAccount: recipientAccount,
      type: type,
      merchantCategory: merchantCategory,
    ),
  );
}

enum SigningStatus { idle, processing, successful, failed }

class TransactionSigningSheet extends ConsumerStatefulWidget {
  final double amountNgn;
  final double amountUsd;
  final String title;
  final String recipientName;
  final String channel;
  final String? recipientBank;
  final String? recipientAccount;
  final String? type;
  final String? merchantCategory;

  const TransactionSigningSheet({
    super.key,
    required this.amountNgn,
    required this.amountUsd,
    required this.title,
    required this.recipientName,
    required this.channel,
    this.recipientBank,
    this.recipientAccount,
    this.type,
    this.merchantCategory,
  });

  @override
  ConsumerState<TransactionSigningSheet> createState() =>
      _TransactionSigningSheetState();
}

class _TransactionSigningSheetState
    extends ConsumerState<TransactionSigningSheet>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _isVerifying = false;
  SigningStatus _status = SigningStatus.idle;
  String? _errorMessage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Auto-prompt biometrics if supported
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricAuth();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricAuth() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authenticated = await authNotifier.authenticateWithBiometrics(
      reason:
          'Scan biometric to sign transaction of ₦${NumberFormat('#,##0.00').format(widget.amountNgn)}',
    );

    if (authenticated && mounted) {
      _executeCryptographicSigning();
    }
  }

  void _onDigitTapped(String digit) {
    if (_enteredPin.length >= 4 ||
        _isVerifying ||
        _status != SigningStatus.idle) {
      return;
    }

    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty ||
        _isVerifying ||
        _status != SigningStatus.idle) {
      return;
    }
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isValid = await authNotifier.verifySecurityPin(_enteredPin);

    if (!mounted) return;

    if (isValid) {
      _executeCryptographicSigning();
    } else {
      setState(() {
        _isVerifying = false;
        _enteredPin = '';
        _errorMessage = 'Incorrect PIN. Try again (Demo: 1234)';
      });
    }
  }

  Future<void> _executeCryptographicSigning() async {
    setState(() {
      _isVerifying = false;
      _status = SigningStatus.processing;
    });

    try {
      // Clean processing display
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      final random = Random();
      final now = DateTime.now();
      final sessionId =
          '100004${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${random.nextInt(899999) + 100000}${random.nextInt(899999) + 100000}';
      final txHash =
          '0x${List.generate(64, (_) => '0123456789abcdef'[random.nextInt(16)]).join()}';
      final authCode = 'AUTH-${random.nextInt(899999) + 100000}';

      final authState = ref.read(authNotifierProvider);

      final completedTx = TransactionModel(
        id: 'tx_mnr_${now.millisecondsSinceEpoch}',
        title: widget.title,
        description: 'Transfer to ${widget.recipientName}',
        amountNgn: widget.amountNgn,
        amountUsd: widget.amountUsd,
        type: widget.type ?? 'bank_transfer',
        channel: widget.channel,
        status: 'settled',
        createdAt: now,
        authorizationCode: authCode,
        latencyMs: 168,
        onChainTxRef: txHash,
        merchantCategory: widget.merchantCategory ?? 'Transfer & Payout',
        senderName: authState.user?.name ?? 'SOMA ORAKWUE',
        recipientName: widget.recipientName,
        recipientBank: widget.recipientBank ?? 'Access Bank Nigeria',
        recipientAccount: widget.recipientAccount ?? '0129482104',
        sessionId: sessionId,
        feeNgn: 0.0,
      );

      setState(() {
        _status = SigningStatus.successful;
      });

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      Navigator.of(context).pop(completedTx);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = SigningStatus.failed;
        _errorMessage = 'Transaction failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Header with Shield Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.darkGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authorize Transaction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Non-custodial authorization',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: (_status == SigningStatus.processing ||
                            _status == SigningStatus.successful)
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Transaction Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Text(
                      '₦${NumberFormat('#,##0.00').format(widget.amountNgn)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '≈ \$${widget.amountUsd.toStringAsFixed(2)} USDC',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(height: 20, color: AppColors.borderSubtle),
                    _buildSummaryRow('To', widget.recipientName),
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      'Network Fee',
                      '₦0.00 (Gasless via Monad)',
                      valueColor: AppColors.emeraldGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Body: Either Processing/Result or PIN Entry Keypad
              if (_status != SigningStatus.idle)
                _buildProcessingOrResult()
              else
                _buildPinEntrySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingOrResult() {
    final isProcessing = _status == SigningStatus.processing;
    final isSuccess = _status == SigningStatus.successful;
    final isFailed = _status == SigningStatus.failed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProcessing) ...[
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.08);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkGreen.withValues(alpha: 0.1),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ] else if (isSuccess) ...[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldGreen.withValues(alpha: 0.15),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.emeraldGreen,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Successful',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.emeraldGreen,
              ),
            ),
          ] else if (isFailed) ...[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.crimsonRed.withValues(alpha: 0.15),
              ),
              child: const Center(
                child: Icon(
                  Icons.cancel,
                  color: AppColors.crimsonRed,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.crimsonRed,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                setState(() {
                  _status = SigningStatus.idle;
                  _enteredPin = '';
                  _errorMessage = null;
                });
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPinEntrySection() {
    return Column(
      children: [
        const Text(
          'Enter 4-Digit Security PIN or Use Biometrics',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // 4 PIN Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < _enteredPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.darkGreen : Colors.transparent,
                border: Border.all(
                  color: isFilled ? AppColors.darkGreen : AppColors.borderGlow,
                  width: 2,
                ),
              ),
            );
          }),
        ),

        // Error message or verifying indicator
        SizedBox(
          height: 30,
          child: Center(
            child: _isVerifying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                    ),
                  )
                : (_errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null),
          ),
        ),

        // Numeric Keypad
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              _buildKeypadRow(['1', '2', '3']),
              const SizedBox(height: 10),
              _buildKeypadRow(['4', '5', '6']),
              const SizedBox(height: 10),
              _buildKeypadRow(['7', '8', '9']),
              const SizedBox(height: 10),
              _buildKeypadBottomRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildKeypadButton(digit)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return InkWell(
      onTap: () => _onDigitTapped(digit),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 68,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometrics button
        InkWell(
          onTap: _tryBiometricAuth,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 68,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lime.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: Icon(
                Icons.fingerprint,
                color: AppColors.darkGreen,
                size: 24,
              ),
            ),
          ),
        ),
        // Digit 0
        _buildKeypadButton('0'),
        // Backspace
        InkWell(
          onTap: _onBackspace,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 68,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Center(
              child: Icon(
                Icons.backspace_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
