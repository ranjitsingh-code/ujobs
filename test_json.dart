import 'dart:convert';
void main() {
  String json = '''{
    "success": false,
    "error": {
      "code": "ACCOUNT_LOCKED",
      "message": "Your account is locked until Jun 24, 2026, 11:47 AM due to too many failed at\n tempts."
    }
  }''';
  try {
    print(jsonDecode(json));
  } catch (e) {
    print("Error: $e");
  }
}
