import re

with open("lib/core/models/job.dart", "r") as f:
    content = f.read()

old_company = """      company: (json['companies'] ?? json['company']) != null
          ? Company.fromJson(json['companies'] ?? json['company'])
          : null,"""

new_company = """      company: (json['companies'] ?? json['company']) != null
          ? Company.fromJson((json['companies'] ?? json['company']) is List
              ? ((json['companies'] ?? json['company']) as List).first
              : (json['companies'] ?? json['company']))
          : null,"""

content = content.replace(old_company, new_company)

with open("lib/core/models/job.dart", "w") as f:
    f.write(content)

