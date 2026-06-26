import re

with open("lib/core/models/job.dart", "r") as f:
    code = f.read()

# Replace id to parse properly
code = re.sub(r"id:\s*json\['id'\]\s*as\s*int,", "id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,", code)

# Fix required strings
code = re.sub(r"title:\s*json\['title'\]\s*as\s*String,", "title: json['title'] as String? ?? '',", code)
code = re.sub(r"description:\s*json\['description'\]\s*as\s*String,", "description: json['description'] as String? ?? '',", code)
code = re.sub(r"employmentType:\s*json\['employment_type'\]\s*as\s*String,", "employmentType: json['employment_type'] as String? ?? '',", code)
code = re.sub(r"workplaceType:\s*json\['workplace_type'\]\s*as\s*String,", "workplaceType: json['workplace_type'] as String? ?? '',", code)

# Fix nested company mapping
code = code.replace(
    "company: json['company'] != null\n          ? Company.fromJson(json['company'])",
    "company: (json['companies'] ?? json['company']) != null\n          ? Company.fromJson(json['companies'] ?? json['company'])"
)

# Fix categories string mapping
code = code.replace(
    "category: json['category'] as String?,",
    "category: json['categories'] != null ? (json['categories']['name'] as String?) : json['category'] as String?,"
)

# Fix nested counts parsing mapping
code = code.replace(
    "applicants_count',",
    "applicants_count',\n      '_count.applications',"
)

with open("lib/core/models/job.dart", "w") as f:
    f.write(code)

