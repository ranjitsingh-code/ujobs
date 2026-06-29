class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? role; // 'employer' | 'job_seeker'
  final String? status;
  final bool twoFactorEnabled;
  final bool? verified;
  final int? profileCompleted;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role,
    this.status,
    this.twoFactorEnabled = false,
    this.verified,
    this.profileCompleted,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    email: json['email'] as String? ?? '',
    firstName: (json['firstName'] ?? json['first_name'] ?? '') as String,
    lastName: (json['lastName'] ?? json['last_name'] ?? '') as String,
    phone: json['phone'] as String?,
    role: json['role'] as String?,
    status: json['status'] as String?,
    twoFactorEnabled: (json['two_factor_enabled'] ?? json['two_factor_authentication']) as bool? ?? false,
    verified: json['verified'] as bool?,
    profileCompleted: json['profile_completed'] as int?,
  );

  User copyWith({String? role, String? status, bool? verified, int? profileCompleted}) => User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    role: role ?? this.role,
    status: status ?? this.status,
    twoFactorEnabled: twoFactorEnabled,
    verified: verified ?? this.verified,
    profileCompleted: profileCompleted ?? this.profileCompleted,
  );
}
