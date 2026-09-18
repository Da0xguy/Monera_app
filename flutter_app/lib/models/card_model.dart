// lib/models/card_model.dart
class CardModel {
  final String id;
  final String type; // 'virtual' | 'physical'
  final String brand; // 'mastercard' | 'verve'
  final String status; // 'active' | 'frozen' | 'cancelled'
  final String cardholderName;
  final String maskedPan;
  final String last4;
  final String expiryMonth;
  final String expiryYear;
  final String colorTheme;
  final double spendingLimitNgn;
  final double spentThisMonthNgn;

  const CardModel({
    required this.id,
    required this.type,
    required this.brand,
    required this.status,
    required this.cardholderName,
    required this.maskedPan,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.colorTheme,
    required this.spendingLimitNgn,
    required this.spentThisMonthNgn,
  });

  bool get isFrozen => status == 'frozen';

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'virtual',
      brand: json['brand'] as String? ?? 'mastercard',
      status: json['status'] as String? ?? 'active',
      cardholderName: json['cardholderName'] as String? ?? '',
      maskedPan: json['maskedPan'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
      expiryMonth: json['expiryMonth'] as String? ?? '12',
      expiryYear: json['expiryYear'] as String? ?? '28',
      colorTheme: json['colorTheme'] as String? ?? 'purple',
      spendingLimitNgn: (json['spendingLimitNgn'] as num?)?.toDouble() ?? 1000000.0,
      spentThisMonthNgn: (json['spentThisMonthNgn'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
