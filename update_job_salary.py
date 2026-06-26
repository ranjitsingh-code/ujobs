import re

with open("lib/core/models/job.dart", "r") as f:
    content = f.read()

content = content.replace("final String? salaryMax;", "final String? salaryMax;\n  final String? salaryCurrency;\n  final String? salaryPeriod;")
content = content.replace("this.salaryMax,", "this.salaryMax,\n    this.salaryCurrency,\n    this.salaryPeriod,")
content = content.replace("salaryMax: json['salary_max']?.toString(),", "salaryMax: json['salary_max']?.toString(),\n      salaryCurrency: json['salary_currency'] as String?,\n      salaryPeriod: json['salary_period'] as String?,")

with open("lib/core/models/job.dart", "w") as f:
    f.write(content)

