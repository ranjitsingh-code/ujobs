import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/models/wallet.dart';
import '../../../../core/models/payment.dart';

final walletProvider = FutureProvider.autoDispose<Wallet>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  // Use sharedBaseUrl since this endpoint drops the /mobile path
  final res = await dio.get('${Ep.sharedBaseUrl}${Ep.empWallet}');
  
  final data = res.data['data'] as Map<String, dynamic>;
  return Wallet.fromJson(data);
});

final walletTransactionsProvider = FutureProvider.autoDispose.family<List<WalletTransaction>, int>((ref, page) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(
    '${Ep.sharedBaseUrl}${Ep.empWalletTxs}',
    queryParameters: {'page': page},
  );
  
  final rawData = res.data['data'] as List?;
  if (rawData == null) return [];
  
  return rawData.map((e) => WalletTransaction.fromJson(e)).toList();
});

final paymentsProvider = FutureProvider.autoDispose.family<List<Payment>, int>((ref, page) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get(
    '${Ep.sharedBaseUrl}${Ep.empPayments}',
    queryParameters: {'page': page},
  );
  
  final rawData = res.data['data'] as List?;
  if (rawData == null) return [];
  
  return rawData.map((e) => Payment.fromJson(e)).toList();
});
