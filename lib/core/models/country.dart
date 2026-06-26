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

  static String _generateFlag(String? flag, String? iso2) {
    if (flag != null && flag.isNotEmpty) return flag;
    if (iso2 == null || iso2.length != 2) return '';
    final code = iso2.toUpperCase();
    return String.fromCharCodes([
      code.codeUnitAt(0) + 127397,
      code.codeUnitAt(1) + 127397,
    ]);
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      iso2: json['iso2'] as String? ?? '',
      phoneCode: json['phone_code'] as String? ?? '',
      flag: _generateFlag(json['flag'] as String?, json['iso2'] as String?),
    );
  }
}
