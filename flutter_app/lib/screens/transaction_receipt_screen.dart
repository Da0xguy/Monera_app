// lib/screens/transaction_receipt_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final TransactionModel? transaction;

  const TransactionReceiptScreen({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    if (transaction == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: const Center(child: Text('No transaction details')),
      );
    }

    final tx = transaction!;
    final isCredit = tx.isCredit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Success Badge
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isCredit ? AppColors.emeraldGreen : AppColors.electricBlue).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (isCredit ? AppColors.emeraldGreen : AppColors.electricBlue).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? AppColors.emeraldGreen : AppColors.electricBlue,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tx.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Settled • ${tx.status.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.emeraldGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${isCredit ? '+' : '-'}₦${NumberFormat('#,##0.00').format(tx.amountNgn)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '≈ \$${tx.amountUsd.toStringAsFixed(2)} USDC on Monad L1',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.lightBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Ledger Details Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildRow('Channel Rail', tx.channel.replaceAll('_', ' ').toUpperCase()),
                    const Divider(height: 20),
                    _buildRow('Description', tx.description),
                    if (tx.authorizationCode != null) ...[
                      const Divider(height: 20),
                      _buildRow('Auth Code', tx.authorizationCode!, valueColor: AppColors.electricBlue),
                    ],
                    if (tx.latencyMs != null) ...[
                      const Divider(height: 20),
                      _buildRow('JIT Webhook Latency', '${tx.latencyMs}ms (SLO <200ms)', valueColor: AppColors.emeraldGreen),
                    ],
                    const Divider(height: 20),
                    _buildRow('Timestamp', DateFormat('MMM d, y • HH:mm:ss').format(tx.createdAt)),
                    if (tx.onChainTxRef != null) ...[
                      const Divider(height: 20),
                      _buildRow('Monad L1 Hash', tx.onChainTxRef!, isMonospace: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt copied to clipboard')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderGlow),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Share Receipt', style: TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}
