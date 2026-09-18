// lib/providers/api_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../services/sudo_jit_service.dart';
import '../services/nibss_nqr_service.dart';
import '../services/monad_rpc_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final sudoServiceProvider = Provider<SudoJitService>((ref) {
  final client = ref.watch(apiClientProvider);
  return SudoJitService(apiClient: client);
});

final nqrServiceProvider = Provider<NibssNqrService>((ref) {
  final client = ref.watch(apiClientProvider);
  return NibssNqrService(apiClient: client);
});

final monadRpcProvider = Provider<MonadRpcService>((ref) {
  return MonadRpcService();
});
