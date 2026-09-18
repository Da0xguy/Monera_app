// lib/models/user_model.dart
class UserModel {
  final String id;
  final String privyUserId;
  final String walletAddress;
  final String name;
  final String email;
  final String phone;
  final String kycStatus;
  final String bvnMasked;
  final String ninMasked;
  final int monadChainId;

  const UserModel({
    required this.id,
    required this.privyUserId,
    required this.walletAddress,
    required this.name,
    required this.email,
    required this.phone,
    required this.kycStatus,
    required this.bvnMasked,
    required this.ninMasked,
    this.monadChainId = 10143,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      privyUserId: json['privyUserId'] as String? ?? '',
      walletAddress: json['walletAddress'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      kycStatus: json['kycStatus'] as String? ?? 'unverified',
      bvnMasked: json['bvnMasked'] as String? ?? '',
      ninMasked: json['ninMasked'] as String? ?? '',
      monadChainId: json['monadChainId'] as int? ?? 10143,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'privyUserId': privyUserId,
    'walletAddress': walletAddress,
    'name': name,
    'email': email,
    'phone': phone,
    'kycStatus': kycStatus,
    'bvnMasked': bvnMasked,
    'ninMasked': ninMasked,
    'monadChainId': monadChainId,
  };
}
