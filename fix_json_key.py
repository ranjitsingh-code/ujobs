import re

with open("lib/core/models/company_profile.dart", "r") as f:
    content = f.read()

content = content.replace("json['profile_status']", "json['profile_completed']")

with open("lib/core/models/company_profile.dart", "w") as f:
    f.write(content)

