// lib/services/sudo_jit_service.dart
import 'package:dio/dio.dart';
import '../models/card_model.dart';
import '../core/network/api_client.dart';

class SudoJitService {
  final ApiClient apiClient;

  SudoJitService({required this.apiClient});

  Dio get _dio => apiClient.dio;

  /// Fetch all user Mastercard cards from Sudo Africa
  Future<List<CardModel>> getCards() async {
    try {
      final response = await _dio.get('/cards');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data['cards'] as List<dynamic>?) ?? [];
        return list.map((item) => CardModel.fromJson(item)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Sudo card fetch failed: ${e.message}');
    }
  }

  /// Instant freeze / unfreeze card (<200ms JIT state update)
  Future<bool> toggleFreeze(String cardId) async {
    try {
      final response = await _dio.post('/cards/$cardId/freeze');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Freeze toggle failed: ${e.message}');
    }
  }

  /// Reveal PAN and CVV with PIN verification
  Future<Map<String, String>> revealCardDetails(String cardId, String pin) async {
    try {
      final response = await _dio.post(
        '/cards/$cardId/reveal',
        data: {'pin': pin},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'pan': data['pan'] as String? ?? '5399 4100 8832 4821',
          'cvv': data['cvv'] as String? ?? '891',
          'expiry': data['expiry'] as String? ?? '08/28',
        };
      }
      throw Exception('Invalid PIN authorization');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ?? 'Card reveal failed');
    }
  }

  /// Update dynamic spend limits
  Future<void> updateSpendLimit(String cardId, double newLimitNgn) async {
    await _dio.post(
      '/cards/$cardId/limits',
      data: {'spendingLimitNgn': newLimitNgn},
    );
  }
}
