class Country {
  final int id;
  final String name;
  final String iso2;
  final String phoneCode;
  final String flag;

  Country({
    required this.id,
    required this.name,
    required this.iso2,
    required this.phoneCode,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      iso2: json['iso2'] as String? ?? '',
      phoneCode: json['phone_code'] as String? ?? '',
      flag: json['flag'] as String? ?? '',
    );
  }
}
