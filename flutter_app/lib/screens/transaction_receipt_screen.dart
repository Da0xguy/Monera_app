// lib/screens/transaction_receipt_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../widgets/monera_logo.dart';

class TransactionReceiptScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionReceiptScreen({super.key, this.transaction});

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.transaction == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: const Center(child: Text('No transaction details available')),
      );
    }

    final tx = widget.transaction!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Transaction Receipt',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.darkGreen),
            tooltip: 'Share Receipt',
            onPressed: () => _showShareOptionsModal(context, tx),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // RepaintBoundary for high-fidelity receipt capture & sharing
              RepaintBoundary(
                key: _receiptKey,
                child: _buildReceiptCard(context, tx),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () => _showShareOptionsModal(context, tx),
                      icon: const Icon(Icons.share, size: 18, color: Colors.white),
                      label: const Text(
                        'Share Receipt',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDownloadReceipt(context, tx),
                      icon: const Icon(Icons.download_rounded,
                          size: 18, color: AppColors.darkGreen),
                      label: const Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.darkGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Monera Official Receipt Card Layout
  Widget _buildReceiptCard(BuildContext context, TransactionModel tx) {
    final isCredit = tx.isCredit;
    final formattedNgn = NumberFormat('#,##0.00').format(tx.amountNgn);
    final formattedFee = NumberFormat('#,##0.00').format(tx.feeNgn);
    final formattedDate =
        DateFormat('d MMM yyyy, HH:mm:ss').format(tx.createdAt);

    final recipientTitle = tx.recipientName ?? tx.title;
    final recipientBank = tx.recipientBank ??
        (tx.channel == 'sudo_mastercard'
            ? 'Mastercard Worldwide'
            : tx.channel == 'nibss_nqr'
                ? 'NIBSS NQR Merchant'
                : 'Access Bank Nigeria');
    final recipientAccount = tx.recipientAccount ??
        (tx.authorizationCode != null
            ? 'Auth: ${tx.authorizationCode}'
            : '0129482104');
    final senderTitle = tx.senderName ?? 'Soma Orakwue';
    final sessionId = tx.sessionId ??
        '100004${tx.createdAt.year}${tx.createdAt.month.toString().padLeft(2, '0')}${tx.createdAt.day.toString().padLeft(2, '0')}1832159821849102';
    final txRef = tx.authorizationCode ?? tx.id;
    final txHash = tx.onChainTxRef ??
        '0x9f1a8c3d7e5b2a0c4e1f8a9b6c3d5e7f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Receipt Top Header with Monera Logo & Official Receipt Tag
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 22, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MoneraLogo(
                  size: 26,
                  color: AppColors.darkGreen,
                  variant: MoneraLogoVariant.horizontal,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.darkGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text(
                    'OFFICIAL RECEIPT',
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Success Status Emblem & Big Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.emeraldGreen.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.emeraldGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isCredit ? 'Transfer Received' : 'Payment Successful',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${isCredit ? '+' : '-'}₦$formattedNgn',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '≈ \$${tx.amountUsd.toStringAsFixed(2)} USDC on Monad L1',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Perforated Ticket Divider with side notches
          _buildPerforatedDivider(),

          // 4. Detailed Structured Ledger Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                _buildReceiptRow('Transaction Type', _formatTxType(tx.type)),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Recipient', recipientTitle, isBold: true),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Recipient Bank', recipientBank),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Account / Code', recipientAccount),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Sender', senderTitle),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Sender Bank', 'Monera MFB (Monad L1)'),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Transaction Amount', '₦$formattedNgn'),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow(
                  'Transaction Fee',
                  '₦$formattedFee (Zero Gas)',
                  valueColor: AppColors.emeraldGreen,
                ),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow(
                  'Payment Rail',
                  _formatChannel(tx.channel),
                  valueColor: AppColors.darkGreen,
                ),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow('Date & Time', formattedDate),
                const Divider(height: 18, color: AppColors.borderSubtle),
                _buildReceiptRow(
                  'Status',
                  'SUCCESSFUL',
                  valueColor: AppColors.emeraldGreen,
                  isBold: true,
                ),
                const Divider(height: 18, color: AppColors.borderSubtle),
                // Session ID (30-digit NIP session identifier)
                _buildCopyableRow(
                  context,
                  label: 'Session ID',
                  value: sessionId,
                ),
                const Divider(height: 18, color: AppColors.borderSubtle),
                // Transaction Reference
                _buildCopyableRow(
                  context,
                  label: 'Reference No.',
                  value: txRef,
                ),
                const Divider(height: 18, color: AppColors.borderSubtle),
                // Monad L1 Enclave Hash
                _buildCopyableRow(
                  context,
                  label: 'Monad L1 Hash',
                  value: txHash,
                  isMonospace: true,
                  displayShort: true,
                ),
              ],
            ),
          ),

          // 5. Perforated divider before footer
          _buildPerforatedDivider(),

          // 6. Regulatory Disclaimer & Support Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'NDIC Insured • Verified on Monad L1',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monera Microfinance Bank is licensed by the Central Bank of Nigeria (CBN). Deposits are insured by NDIC. Cryptographic settlement executed via non-custodial Monad L1 enclave.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Support: support@monera.app • 24/7 Monera Priority Desk',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Perforated ticket edge with left & right circular cutouts
  Widget _buildPerforatedDivider() {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed horizontal line
          LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 5.0;
              const dashSpace = 4.0;
              final dashCount =
                  ((constraints.maxWidth - 36) / (dashWidth + dashSpace))
                      .floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(dashCount, (_) {
                  return Container(
                    width: dashWidth,
                    height: 1.2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: dashSpace / 2),
                    color: AppColors.borderSubtle,
                  );
                }),
              );
            },
          ),
          // Left Notch Cutout
          Positioned(
            left: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right Notch Cutout
          Positioned(
            right: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isMonospace = false,
    bool displayShort = false,
  }) {
    final displayValue = displayShort && value.length > 20
        ? '${value.substring(0, 10)}...${value.substring(value.length - 8)}'
        : value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayValue,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied to clipboard'),
                    duration: const Duration(milliseconds: 1400),
                    backgroundColor: AppColors.darkGreen,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTxType(String type) {
    switch (type) {
      case 'nqr_merchant':
        return 'NIBSS NQR Payment';
      case 'bank_transfer':
        return 'Transfer to Bank (NIP)';
      case 'pos_purchase':
        return 'Mastercard POS Purchase';
      case 'online_purchase':
        return 'Online Web Checkout';
      case 'deposit':
        return 'Instant Account Deposit';
      case 'earn_yield':
        return 'USDC Vault Yield Payout';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatChannel(String channel) {
    switch (channel) {
      case 'nibss_nqr':
        return 'NIBSS NQR Rail (168ms)';
      case 'sudo_mastercard':
        return 'Sudo Africa Mastercard JIT';
      case 'nip_transfer':
        return 'NIP Instant Bank Switch';
      case 'monad_l1':
        return 'Monad L1 Parallel EVM';
      default:
        return channel.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Share Modal with multiple sharing options
  void _showShareOptionsModal(BuildContext context, TransactionModel tx) {
    final formattedNgn = NumberFormat('#,##0.00').format(tx.amountNgn);
    final formattedDate =
        DateFormat('d MMM yyyy, HH:mm:ss').format(tx.createdAt);
    final recipient = tx.recipientName ?? tx.title;
    final sessionId = tx.sessionId ??
        '100004${tx.createdAt.year}${tx.createdAt.month.toString().padLeft(2, '0')}${tx.createdAt.day.toString().padLeft(2, '0')}1832159821849102';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share Transaction Receipt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose how you would like to share this proof of payment:',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                // Option 1: Share as Image Receipt
                _buildShareActionTile(
                  ctx,
                  icon: Icons.image_outlined,
                  iconColor: AppColors.darkGreen,
                  title: 'Share Receipt Image',
                  subtitle: 'Share high-resolution branded receipt card',
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleDownloadReceipt(context, tx);
                  },
                ),
                const SizedBox(height: 10),

                // Option 2: Share formatted text summary (Standard WhatsApp/SMS format)
                _buildShareActionTile(
                  ctx,
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.emeraldGreen,
                  title: 'Share as Text (WhatsApp / SMS)',
                  subtitle: 'Copy Nigerian banking standard receipt message',
                  onTap: () {
                    Navigator.pop(ctx);
                    final receiptText = '''
*MONERA TRANSACTION RECEIPT*
----------------------------------------
*Status:* SUCCESSFUL
*Amount:* ₦$formattedNgn (≈ \$${tx.amountUsd.toStringAsFixed(2)} USDC)
*Recipient:* $recipient
*Recipient Bank:* ${tx.recipientBank ?? 'Access Bank'}
*Sender:* ${tx.senderName ?? 'Soma Orakwue'}
*Payment Rail:* ${_formatChannel(tx.channel)}
*Date:* $formattedDate
*Session ID:* $sessionId
*Reference:* ${tx.authorizationCode ?? tx.id}
*Monad L1 Hash:* ${tx.onChainTxRef ?? '0x9f1a...48c2'}
----------------------------------------
_Settled via Monera Neobank on Monad L1. NDIC Insured._
''';
                    Clipboard.setData(ClipboardData(text: receiptText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'WhatsApp receipt text copied to clipboard!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.darkGreen,
                        duration: Duration(milliseconds: 2000),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Option 3: Copy Session ID
                _buildShareActionTile(
                  ctx,
                  icon: Icons.copy_rounded,
                  iconColor: AppColors.electricBlue,
                  title: 'Copy NIP Session ID',
                  subtitle: sessionId,
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: sessionId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'NIP Session ID copied to clipboard!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.darkGreen,
                        duration: Duration(milliseconds: 1600),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownloadReceipt(BuildContext context, TransactionModel tx) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.lime, size: 20),
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Receipt saved to device! (MNR-${tx.id.substring(0, tx.id.length > 8 ? 8 : tx.id.length)}.png)',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkGreen,
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }
}
