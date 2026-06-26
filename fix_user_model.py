import re

with open("lib/core/models/user.dart", "r") as f:
    content = f.read()

old_2fa = "twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,"
new_2fa = "twoFactorEnabled: (json['two_factor_enabled'] ?? json['two_factor_authentication']) as bool? ?? false,"

content = content.replace(old_2fa, new_2fa)

with open("lib/core/models/user.dart", "w") as f:
    f.write(content)
