import re

with open('lib/core/models/company.dart', 'r') as f:
    content = f.read()

# Add fields
orig_fields = """  final String? industry;
  final String? size;
  final String? location;"""
new_fields = """  final String? industry;
  final String? size;
  final String? location;
  final bool? isVerified;
  final String? founded;"""
content = content.replace(orig_fields, new_fields)

orig_constructor = """    this.industry,
    this.size,
    this.location,
  });"""
new_constructor = """    this.industry,
    this.size,
    this.location,
    this.isVerified,
    this.founded,
  });"""
content = content.replace(orig_constructor, new_constructor)

orig_fromjson = """      industry: json['industry'] as String?,
      size: json['size'] as String?,
      location: json['location'] as String?,
    );"""
new_fromjson = """      industry: json['industry'] as String?,
      size: json['size'] as String?,
      location: json['location'] as String?,
      isVerified: json['isVerified'] as bool?,
      founded: json['founded'] as String?,
    );"""
content = content.replace(orig_fromjson, new_fromjson)

orig_tojson = """    'industry': industry,
    'size': size,
    'location': location,
  };"""
new_tojson = """    'industry': industry,
    'size': size,
    'location': location,
    'isVerified': isVerified,
    'founded': founded,
  };"""
content = content.replace(orig_tojson, new_tojson)

with open('lib/core/models/company.dart', 'w') as f:
    f.write(content)

