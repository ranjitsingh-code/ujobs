class Company {
  final int id;
  final String name;
  final String? logo;
  final String? website;
  final String? description;
  final String? industry;
  final String? size;
  final String? location;
  final bool? isVerified;
  final String? founded;
  final String? linkedinUrl;
  final String? facebookUrl;

  Company({
    required this.id,
    required this.name,
    this.logo,
    this.website,
    this.description,
    this.industry,
    this.size,
    this.location,
    this.isVerified,
    this.founded,
    this.linkedinUrl,
    this.facebookUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    // API returns id as String ("15")
    final idVal = json['id'];
    final parsedId = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0;

    return Company(
      id: parsedId,
      name: json['name'] as String? ?? '',
      logo: json['logo_url'] as String? ?? json['logo'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      industry: json['industry_other'] as String? ?? json['industry'] as String?,
      size: json['company_size'] as String? ?? json['size'] as String?,
      location: json['city'] != null && json['country'] != null
          ? '${json['city']}, ${json['country']}'
          : json['location'] as String?,
      isVerified: json['verification_status'] == 'verified' || json['isVerified'] == true,
      founded: json['founded'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'website': website,
    'description': description,
    'industry': industry,
    'size': size,
    'location': location,
    'isVerified': isVerified,
    'founded': founded,
    'linkedinUrl': linkedinUrl,
    'facebookUrl': facebookUrl,
  };
}
