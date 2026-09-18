// lib/models/vault_model.dart
class VaultModel {
  final double vaultBalanceUsd;
  final double accruedYieldUsd;
  final double apyPercent;
  final String contractAddress;
  final String networkName;
  final int monadChainId;

  const VaultModel({
    required this.vaultBalanceUsd,
    required this.accruedYieldUsd,
    required this.apyPercent,
    required this.contractAddress,
    required this.networkName,
    this.monadChainId = 10143,
  });

  factory VaultModel.fromJson(Map<String, dynamic> json) {
    return VaultModel(
      vaultBalanceUsd: (json['vaultBalanceUsd'] as num?)?.toDouble() ?? 850.0,
      accruedYieldUsd: (json['accruedYieldUsd'] as num?)?.toDouble() ?? 4.1284,
      apyPercent: (json['apyPercent'] as num?)?.toDouble() ?? 8.4,
      contractAddress: json['contractAddress'] as String? ??
          '0x8338ECa912a7d23a54bC4402a7737dCba59F7C2B',
      networkName: json['networkName'] as String? ?? 'Monad L1 Devnet',
      monadChainId: json['monadChainId'] as int? ?? 10143,
    );
  }

  VaultModel copyWith({
    double? vaultBalanceUsd,
    double? accruedYieldUsd,
    double? apyPercent,
  }) {
    return VaultModel(
      vaultBalanceUsd: vaultBalanceUsd ?? this.vaultBalanceUsd,
      accruedYieldUsd: accruedYieldUsd ?? this.accruedYieldUsd,
      apyPercent: apyPercent ?? this.apyPercent,
      contractAddress: contractAddress,
      networkName: networkName,
      monadChainId: monadChainId,
    );
  }
}
