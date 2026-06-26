import re

with open('lib/features/shared/notifications/notification_service.dart', 'r') as f:
    text = f.read()

get_unread_code = """
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
"""

text = re.sub(r'  Future<int> getUnreadCount\(\) async \{.*?\n    return 0;\n  \}', get_unread_code.strip(), text, flags=re.DOTALL)

with open('lib/features/shared/notifications/notification_service.dart', 'w') as f:
    f.write(text)

