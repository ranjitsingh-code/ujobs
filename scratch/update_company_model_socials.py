import re

with open('lib/core/models/company.dart', 'r') as f:
    content = f.read()

orig_fields = """  final bool? isVerified;
  final String? founded;"""
new_fields = """  final bool? isVerified;
  final String? founded;
  final String? linkedinUrl;
  final String? facebookUrl;"""
content = content.replace(orig_fields, new_fields)

orig_constructor = """    this.isVerified,
    this.founded,
  });"""
new_constructor = """    this.isVerified,
    this.founded,
    this.linkedinUrl,
    this.facebookUrl,
  });"""
content = content.replace(orig_constructor, new_constructor)

orig_fromjson = """      isVerified: json['isVerified'] as bool?,
      founded: json['founded'] as String?,
    );"""
new_fromjson = """      isVerified: json['isVerified'] as bool?,
      founded: json['founded'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
    );"""
content = content.replace(orig_fromjson, new_fromjson)

orig_tojson = """    'isVerified': isVerified,
    'founded': founded,
  };"""
new_tojson = """    'isVerified': isVerified,
    'founded': founded,
    'linkedinUrl': linkedinUrl,
    'facebookUrl': facebookUrl,
  };"""
content = content.replace(orig_tojson, new_tojson)

with open('lib/core/models/company.dart', 'w') as f:
    f.write(content)

