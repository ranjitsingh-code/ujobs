import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dio_client.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/notification.dart';
import '../../../core/providers/role_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final role = ref.watch(activeRoleProvider);
  return NotificationService(dioClient, role);
});

class NotificationResponse {
  final List<AppNotification> notifications;
  final int unreadCount;
  final int totalPages;

  NotificationResponse({
    required this.notifications,
    required this.unreadCount,
    required this.totalPages,
  });
}

class NotificationService {
  final DioClient _api;
  final String _role;

  NotificationService(this._api, this._role);

  String get _baseEndpoint =>
      _role == 'employer' ? Ep.empNotifications : Ep.seekerNotifications;

  Future<NotificationResponse> getNotifications({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (type != null && type.isNotEmpty && type != 'all') params['type'] = type;

    final response = await _api.dio.get(
      _baseEndpoint,
      queryParameters: params,
    );

    final data = response.data;
    if (data['success'] == true) {
      final List items = data['data'] ?? [];
      final notifications =
          items.map((e) => AppNotification.fromJson(e)).toList();
      final meta = data['meta'] ?? {};
      return NotificationResponse(
        notifications: notifications,
        unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
    }
    throw Exception('Failed to load notifications');
  }


Future<int> getUnreadCount() async {
    try {
      final endpoint = _role == 'employer' ? Ep.empUnreadCount : Ep.seekUnreadCount;
      final res = await _api.dio.get(endpoint);
      final data = res.data;
      if (data['success'] == true) {
        return (data['data']['count'] as num).toInt();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }


  Future<void> markAllAsRead() async {
    final endpoint = _role == 'employer' ? Ep.empMarkAllRead : Ep.seekMarkAllRead;
    await _api.dio.patch(endpoint);
  }

  Future<void> markAsRead(String id) async {
    final endpoint = _role == 'employer'
        ? Ep.empNotifRead(id)
        : Ep.seekNotifRead(id);
    await _api.dio.patch(endpoint);
  }

  Future<void> deleteNotification(String id) async {
    // Assuming DELETE /api/v1/mobile/.../notifications/:id exists, else skip
    await _api.dio.delete('$_baseEndpoint/$id');
  }
}
