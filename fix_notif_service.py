import re

with open('lib/features/shared/notifications/notification_service.dart', 'r') as f:
    text = f.read()

# Fix import
text = text.replace("import '../../../core/api/dio_client.dart';", "import '../../../core/api/dio_client.dart';\nimport '../../../core/providers/auth_provider.dart';")

# Fix map type
text = text.replace("final params = {", "final params = <String, dynamic>{")

with open('lib/features/shared/notifications/notification_service.dart', 'w') as f:
    f.write(text)

