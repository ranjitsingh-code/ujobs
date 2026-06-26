import re

with open('lib/core/models/job.dart', 'r') as f:
    text = f.read()

text = text.replace("final String? category;", "final String? category;\n  final String? categoryId;")
text = text.replace("this.category,", "this.category,\n    this.categoryId,")
text = text.replace("category: json['categories'] != null ? (json['categories']['name'] as String?) : json['category'] as String?,", "category: json['categories'] != null ? (json['categories']['name'] as String?) : json['category'] as String?,\n      categoryId: json['category_id']?.toString() ?? json['categories']?['id']?.toString(),")
text = text.replace("category: category ?? this.category,", "category: category ?? this.category,\n      categoryId: categoryId ?? this.categoryId,")
text = text.replace("String? category,", "String? category,\n    String? categoryId,")

with open('lib/core/models/job.dart', 'w') as f:
    f.write(text)

