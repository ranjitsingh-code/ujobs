import re

with open('lib/features/shared/notifications/notification_service.dart', 'r') as f:
    text = f.read()

get_unread_code = """
  Future<int> getUnreadCount() async {
    final endpoint = _role == 'employer' ? Ep.empUnreadCount : Ep.seekUnreadCount;
    final res = await _api.dio.get(endpoint);
    final data = res.data;
    if (data['success'] == true) {
      return (data['data']['count'] as num).toInt();
    }
    return 0;
  }
"""

text = text.replace('  Future<void> markAsRead(String id) async {', get_unread_code + '\n  Future<void> markAsRead(String id) async {')

with open('lib/features/shared/notifications/notification_service.dart', 'w') as f:
    f.write(text)

