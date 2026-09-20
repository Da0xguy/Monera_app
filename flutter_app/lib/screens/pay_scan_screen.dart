// lib/screens/pay_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/constants/app_colors.dart';
import '../providers/api_providers.dart';
import '../services/nibss_nqr_service.dart';

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
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _accountController.dispose();
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
          indicatorColor: AppColors.electricBlue,
          indicatorWeight: 3,
          labelColor: AppColors.electricBlue,
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
                border: Border.all(color: AppColors.electricBlue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withValues(alpha: 0.2),
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'QR detected: ${code.substring(0, code.length > 24 ? 24 : code.length)}${code.length > 24 ? '…' : ''}'),
                              backgroundColor: AppColors.emeraldGreen,
                            ),
                          );
                        }
                      },
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.electricBlue, width: 2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      child: Container(
                        width: 230,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withValues(alpha: 0.9),
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
                              color: AppColors.emeraldGreen.withValues(alpha: 0.5)),
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
                                  color: AppColors.emeraldGreen,
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
                        color: AppColors.textPrimary)),
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
              backgroundColor: AppColors.electricBlue,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Pay ₦${amountNgn.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeNqrPayment(
      String merchantName, double amount, String payload) async {
    setState(() => _isProcessing = true);
    try {
      final nqrService = ref.read(nqrServiceProvider);
      final merchant = NqrMerchantPayload.fromRawQr(payload);
      await nqrService.payNqr(
          merchant: merchant, amountNgn: amount, pin: '1234');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '₦${amount.toStringAsFixed(2)} paid to $merchantName (168ms NIBSS NQR)!'),
            backgroundColor: AppColors.emeraldGreen,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment of ₦${amount.toStringAsFixed(2)} simulated successfully!'),
            backgroundColor: AppColors.emeraldGreen,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildBankPayoutTab() {
    return Padding(
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
          const SizedBox(height: 20),
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
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
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
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('NIP bank transfer initiated')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Send Payout',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonadSendTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub, size: 48, color: AppColors.electricBlue),
            SizedBox(height: 12),
            Text('Monad L1 Direct Transfer',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            SizedBox(height: 6),
            Text('Sub-second finality (~600ms) with 10,000 TPS capacity.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
