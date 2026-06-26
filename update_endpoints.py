import re

with open('lib/core/api/api_endpoints.dart', 'r') as f:
    text = f.read()

text = text.replace(
    "  static const employerFeatureFlags = '/employer/features';",
    "  static const employerFeatureFlags = '/employer/features';\n  static const publicJobFormOptions = '/public/job-form-options';"
)

with open('lib/core/api/api_endpoints.dart', 'w') as f:
    f.write(text)

