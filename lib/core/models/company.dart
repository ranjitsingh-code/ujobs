class Company {
  final int id;
  final String name;
  final String? logo;
  final String? website;
  final String? description;
  final String? industry;
  final String? size;
  final String? location;

  Company({
    required this.id,
    required this.name,
    this.logo,
    this.website,
    this.description,
    this.industry,
    this.size,
    this.location,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      size: json['size'] as String?,
      location: json['location'] as String?,
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
  };
}
