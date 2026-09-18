// lib/services/monad_rpc_service.dart
import 'package:dio/dio.dart';

class MonadRpcService {
  final Dio _dio;
  final String rpcUrl;
  final int chainId;

  MonadRpcService({
    String? rpcUrl,
    this.chainId = 10143,
  })  : rpcUrl = rpcUrl ?? 'https://rpc.monad.xyz',
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ));

  /// Query native MONAD balance
  Future<BigInt> getBalance(String address) async {
    try {
      final response = await _dio.post(
        rpcUrl,
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_getBalance',
          'params': [address, 'latest'],
        },
      );

      final data = response.data;
      final hex = data['result'] as String;
      return BigInt.parse(hex.replaceFirst('0x', ''), radix: 16);
    } catch (_) {
      return BigInt.zero;
    }
  }

  /// Query Monad L1 USDC token balance (ERC-20 balanceOf)
  Future<double> getUsdcBalance(String tokenAddress, String userAddress) async {
    try {
      final cleanAddress = userAddress.replaceFirst('0x', '').padLeft(64, '0');
      final data = '0x70a08231$cleanAddress';

      final response = await _dio.post(
        rpcUrl,
        data: {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'eth_call',
          'params': [
            {'to': tokenAddress, 'data': data},
            'latest',
          ],
        },
      );

      final resData = response.data;
      final hex = resData['result'] as String?;
      if (hex == null || hex == '0x' || hex.isEmpty) return 0.0;
      final rawVal = BigInt.parse(hex.replaceFirst('0x', ''), radix: 16);
      return rawVal.toDouble() / 1e6; // 6 decimals
    } catch (_) {
      return 0.0;
    }
  }
}
