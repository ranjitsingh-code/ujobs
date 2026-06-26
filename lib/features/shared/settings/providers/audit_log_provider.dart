import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/models/audit_log_entry.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/role_provider.dart';

final auditLogProvider = FutureProvider.autoDispose.family<List<AuditLogEntry>, int>((ref, page) async {
  final dio = ref.watch(dioClientProvider).dio;
  final role = ref.watch(activeRoleProvider);
  final isEmployer = role == 'employer';
  
  final endpoint = isEmployer ? Ep.empAuditLog : Ep.seekAuditLog;
  
  final res = await dio.get(
    endpoint,
    queryParameters: {'page': page},
  );
  
  final rawData = res.data['data'] as List?;
  if (rawData == null) return [];
  
  return rawData.map((e) => AuditLogEntry.fromJson(e)).toList();
});
