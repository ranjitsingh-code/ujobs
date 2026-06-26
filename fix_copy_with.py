import re

with open("lib/core/models/company_profile.dart", "r") as f:
    content = f.read()

# Fix copyWith method signature
content = content.replace("String? industryCategoryId,", "String? industryCategoryId,\n    int? profileStatus,")

# Fix copyWith method body
content = content.replace("this.profileStatus = 0,\n      activeJobs: activeJobs,", "profileStatus: profileStatus ?? this.profileStatus,\n      activeJobs: activeJobs,")

with open("lib/core/models/company_profile.dart", "w") as f:
    f.write(content)

