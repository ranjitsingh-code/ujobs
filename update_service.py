import re

with open('lib/features/shared/notifications/notification_service.dart', 'r') as f:
    text = f.read()

mark_all_read_code = """
  Future<void> markAllAsRead() async {
    final endpoint = _role == 'employer' ? Ep.empMarkAllRead : Ep.seekMarkAllRead;
    await _api.dio.patch(endpoint);
  }
"""

text = text.replace('  Future<void> markAsRead(String id) async {', mark_all_read_code + '\n  Future<void> markAsRead(String id) async {')

with open('lib/features/shared/notifications/notification_service.dart', 'w') as f:
    f.write(text)

