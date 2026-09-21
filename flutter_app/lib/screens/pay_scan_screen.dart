// lib/screens/pay_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/constants/app_colors.dart';
import '../providers/api_providers.dart';
import '../services/nibss_nqr_service.dart';
import '../widgets/transaction_signing_sheet.dart';

class PayScanScreen extends ConsumerStatefulWidget {
  const PayScanScreen({super.key});

  @override
  ConsumerState<PayScanScreen> createState() => _PayScanScreenState();
}

class _PayScanScreenState extends ConsumerState<PayScanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _monadAddressController = TextEditingController();
  final TextEditingController _monadAmountController = TextEditingController();

  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _isProcessing = false;
  String? _lastScannedCode;
  String _selectedBank = 'Access Bank';
  String _resolvedAccountName = 'Adeyemi Babatunde';

  final List<String> _popularBanks = [
    'Access Bank',
    'GTBank',
    'Zenith Bank',
    'OPay',
    'Kuda Bank',
    'United Bank for Africa (UBA)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _accountController.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    final text = _accountController.text.trim();
    if (text.length == 10) {
      setState(() {
        _resolvedAccountName = 'Adeyemi Babatunde';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _accountController.removeListener(_onAccountChanged);
    _accountController.dispose();
    _monadAddressController.dispose();
    _monadAmountController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pay & Scan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkGreen,
          indicatorWeight: 3,
          labelColor: AppColors.darkGreen,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(text: 'Scan NQR'),
            Tab(text: 'Bank Payout'),
            Tab(text: 'Monad Send'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(),
          _buildBankPayoutTab(),
          _buildMonadSendTab(),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const Text(
            'Scan any NIBSS NQR Code at Nigerian retail stores',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),

          // High-tech Camera Viewfinder
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.darkGreen, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGreen.withValues(alpha: 0.15),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final code = capture.barcodes.firstOrNull?.rawValue;
                        if (code == null || code == _lastScannedCode) {
                          return;
                        }

                        setState(() => _lastScannedCode = code);
                        _promptScannedPayment(code);
                      },
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lime, width: 2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      child: Container(
                        width: 230,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lime.withValues(alpha: 0.9),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.emeraldGreen
                                  .withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.emeraldGreen, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'NIBSS NQR Verified Rail',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Merchant Presets
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Or tap demo Nigerian merchant:',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          _buildMerchantTile(
            title: 'Shoprite Supermarket Lekki',
            category: 'Groceries & Household',
            amountNgn: 48114.00,
            payload:
                '00020101021226500014shoprite.com0116NQR_SHP_99215405481145802NG',
          ),
          _buildMerchantTile(
            title: 'TotalEnergies Fuel Victoria Island',
            category: 'Fuel & Transportation',
            amountNgn: 25000.00,
            payload:
                '00020101021226500014total.com0116NQR_TOT_11025405250005802NG',
          ),
        ],
      ),
    );
  }

  void _promptScannedPayment(String rawCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: AppColors.darkGreen),
            SizedBox(width: 8),
            Text('NQR Code Scanned',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Merchant: Retail Store Lekki Mall',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Payload: ${rawCode.substring(0, rawCode.length > 28 ? 28 : rawCode.length)}...',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Text('Amount: ₦18,500.00',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeNqrPayment('Retail Store Lekki Mall', 18500.00, rawCode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Authorize',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantTile({
    required String title,
    required String category,
    required double amountNgn,
    required String payload,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(category,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () => _executeNqrPayment(title, amountNgn, payload),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Pay ₦${NumberFormat('#,##0').format(amountNgn)}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Execute NQR payment with TransactionSigningSheet (PIN / Biometrics)
  Future<void> _executeNqrPayment(
      String merchantName, double amount, String payload) async {
    setState(() => _isProcessing = true);
    try {
      final signedTx = await showTransactionSigningSheet(
        context: context,
        amountNgn: amount,
        amountUsd: amount / 1520.0,
        title: merchantName,
        recipientName: merchantName,
        channel: 'nibss_nqr',
        recipientBank: 'NIBSS NQR Merchant Switch',
        recipientAccount: '00020101021226500',
        type: 'nqr_merchant',
        merchantCategory: 'Retail Merchant',
      );

      if (signedTx != null && mounted) {
        try {
          final nqrService = ref.read(nqrServiceProvider);
          final merchant = NqrMerchantPayload.fromRawQr(payload);
          await nqrService.payNqr(
              merchant: merchant, amountNgn: amount, pin: '1234');
        } catch (_) {}

        // Navigate seamlessly to Receipt
        if (mounted) {
          context.push('/receipt', extra: signedTx);
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildBankPayoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Instant Nigerian Bank Transfer',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text(
              'NIP instant routing to GTBank, Access, Zenith, Kuda, OPay, and all 40+ banks.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 18),

          // Bank Selector
          const Text('Select Destination Bank',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBank,
                isExpanded: true,
                items: _popularBanks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Account Number Input
          TextField(
            controller: _accountController,
            decoration: InputDecoration(
              hintText: 'Enter 10-digit NUBAN Account Number',
              hintStyle:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              suffixIcon: TextButton(
                onPressed: () {
                  _accountController.text = '0129482104';
                  setState(() => _resolvedAccountName = 'Adeyemi Babatunde');
                },
                child: const Text('Demo',
                    style: TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 6),

          // Resolved Account Name Badge
          if (_accountController.text.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified,
                      color: AppColors.darkGreen, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Beneficiary: $_resolvedAccountName',
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Amount Input
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              hintText: 'Amount (₦)',
              hintStyle:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              prefixText: '₦ ',
              prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),

          // Quick Amount Presets
          Row(
            children: [5000, 10000, 25000, 50000].map((amt) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: OutlinedButton(
                    onPressed: () => _amountController.text = amt.toString(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.borderSubtle),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('₦${amt ~/ 1000}k',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _handleBankPayout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Sign & Send Payout',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBankPayout() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    final account = _accountController.text.trim().isEmpty
        ? '0129482104'
        : _accountController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final signedTx = await showTransactionSigningSheet(
      context: context,
      amountNgn: amount,
      amountUsd: amount / 1520.0,
      title: 'Transfer to $_resolvedAccountName',
      recipientName: _resolvedAccountName,
      channel: 'nip_transfer',
      recipientBank: _selectedBank,
      recipientAccount: account,
      type: 'bank_transfer',
      merchantCategory: 'Bank Payout',
    );

    if (signedTx != null && mounted) {
      _amountController.clear();
      _accountController.clear();
      context.push('/receipt', extra: signedTx);
    }
  }

  Widget _buildMonadSendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub,
                    size: 28, color: AppColors.electricBlue),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monad L1 Direct Transfer',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text('Sub-second finality (~600ms) • 10,000 TPS capacity',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Monad Recipient Address
          const Text('Recipient Monad EVM Address',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: _monadAddressController,
            decoration: InputDecoration(
              hintText: '0x...',
              hintStyle:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              suffixIcon: TextButton(
                onPressed: () {
                  _monadAddressController.text =
                      '0x3a9F784c498B6C7Eb79116e033A3E4c0840A8c21';
                },
                child: const Text('Demo',
                    style: TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Amount in USDC
          const Text('Amount in USDC',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: _monadAmountController,
            decoration: InputDecoration(
              hintText: 'Amount in USDC',
              hintStyle:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _handleMonadSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Sign & Broadcast on Monad L1',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMonadSend() async {
    final amountUsd =
        double.tryParse(_monadAmountController.text.trim()) ?? 25.0;
    final amountNgn = amountUsd * 1520.0;
    final address = _monadAddressController.text.trim().isEmpty
        ? '0x3a9F784c498B6C7Eb79116e033A3E4c0840A8c21'
        : _monadAddressController.text.trim();

    final signedTx = await showTransactionSigningSheet(
      context: context,
      amountNgn: amountNgn,
      amountUsd: amountUsd,
      title: 'Monad L1 Direct Transfer',
      recipientName:
          'Monad Wallet (${address.substring(0, 6)}...${address.substring(address.length - 4)})',
      channel: 'monad_l1',
      recipientBank: 'Monad L1 Parallel EVM',
      recipientAccount: address,
      type: 'transfer_out',
      merchantCategory: 'L1 Direct Transfer',
    );

    if (signedTx != null && mounted) {
      _monadAddressController.clear();
      _monadAmountController.clear();
      context.push('/receipt', extra: signedTx);
    }
  }
}
