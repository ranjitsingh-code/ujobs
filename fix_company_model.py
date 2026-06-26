import re

with open("lib/core/models/company_profile.dart", "r") as f:
    content = f.read()

content = content.replace("final int activeJobs;", "final bool? verified;\n\n  final int activeJobs;")
content = content.replace("this.profileStatus = 0,", "this.profileStatus = 0,\n    this.verified,")
content = content.replace("profileStatus: json['profile_completed'] is int", "verified: json['verified'] as bool?,\n      profileStatus: json['profile_completed'] is int")
content = content.replace("profileStatus: profileStatus ?? this.profileStatus,", "profileStatus: profileStatus ?? this.profileStatus,\n      verified: verified ?? this.verified,")

content = content.replace("int? profileStatus,", "int? profileStatus,\n    bool? verified,")

with open("lib/core/models/company_profile.dart", "w") as f:
    f.write(content)

