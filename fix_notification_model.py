import re

with open('lib/core/models/notification.dart', 'r') as f:
    text = f.read()

text = text.replace("final String? data;", "final Map<String, dynamic>? data;")
text = text.replace("data: json['data'] as String?,", "data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,")
text = text.replace("this.data,", "this.data,") # nothing to do

with open('lib/core/models/notification.dart', 'w') as f:
    f.write(text)

