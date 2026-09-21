// lib/models/transaction_model.dart
class TransactionModel {
  final String id;
  final String title;
  final String description;
  final double amountNgn;
  final double amountUsd;
  final String
      type; // 'pos_purchase' | 'online_purchase' | 'nqr_merchant' | 'bank_transfer' | 'deposit' | 'earn_yield'
  final String
      channel; // 'sudo_mastercard' | 'nibss_nqr' | 'nip_transfer' | 'monad_l1' | 'vault'
  final String status; // 'settled' | 'pending' | 'failed'
  final DateTime createdAt;
  final String? authorizationCode;
  final int? latencyMs;
  final String? onChainTxRef;
  final String? merchantCategory;

  final String? senderName;
  final String? recipientName;
  final String? recipientBank;
  final String? recipientAccount;
  final String? sessionId;
  final double feeNgn;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amountNgn,
    required this.amountUsd,
    required this.type,
    required this.channel,
    required this.status,
    required this.createdAt,
    this.authorizationCode,
    this.latencyMs,
    this.onChainTxRef,
    this.merchantCategory,
    this.senderName,
    this.recipientName,
    this.recipientBank,
    this.recipientAccount,
    this.sessionId,
    this.feeNgn = 0.0,
  });

  bool get isCredit =>
      type == 'deposit' || type == 'earn_yield' || type == 'transfer_in';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Transaction',
      description: json['description'] as String? ?? '',
      amountNgn: (json['amountNgn'] as num?)?.toDouble() ?? 0.0,
      amountUsd: (json['amountUsd'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'pos_purchase',
      channel: json['channel'] as String? ?? 'sudo_mastercard',
      status: json['status'] as String? ?? 'settled',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      authorizationCode: json['authorizationCode'] as String?,
      latencyMs: json['latencyMs'] as int?,
      onChainTxRef: json['onChainTxRef'] as String?,
      merchantCategory: json['merchantCategory'] as String?,
      senderName: json['senderName'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientBank: json['recipientBank'] as String?,
      recipientAccount: json['recipientAccount'] as String?,
      sessionId: json['sessionId'] as String?,
      feeNgn: (json['feeNgn'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'amountNgn': amountNgn,
        'amountUsd': amountUsd,
        'type': type,
        'channel': channel,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'authorizationCode': authorizationCode,
        'latencyMs': latencyMs,
        'onChainTxRef': onChainTxRef,
        'merchantCategory': merchantCategory,
        'senderName': senderName,
        'recipientName': recipientName,
        'recipientBank': recipientBank,
        'recipientAccount': recipientAccount,
        'sessionId': sessionId,
        'feeNgn': feeNgn,
      };
}
