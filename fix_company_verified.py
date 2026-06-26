import re

with open("lib/core/models/company_profile.dart", "r") as f:
    content = f.read()

old_verified = "verified: json['verified'] as bool?,"
new_verified = "verified: json['verified'] as bool? ?? (json['verification_status'] == 'verified'),"

content = content.replace(old_verified, new_verified)

with open("lib/core/models/company_profile.dart", "w") as f:
    f.write(content)
