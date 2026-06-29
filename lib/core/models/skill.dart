class Skill {
  final int id;
  final String name;

  const Skill({
    required this.id,
    required this.name,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}
