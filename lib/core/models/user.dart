class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? phoneCode;
  final String? role; // 'employer' | 'job_seeker'
  final String? status; // 'active' | 'suspended' | 'inactive' | 'pending'
  final String? verificationStatus; // 'verified' | 'unverified'
  final String? accountStatus; // 'verified' | 'unverified'
  final bool twoFactorEnabled;
  final String? avatarUrl;
  final String? emailVerifiedAt;
  final String? createdAt;
  final int? profileCompleted;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.phoneCode,
    this.role,
    this.status,
    this.verificationStatus,
    this.accountStatus,
    this.twoFactorEnabled = false,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.createdAt,
    this.profileCompleted,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  bool get isVerifiedBadge =>
      verificationStatus == 'verified' && accountStatus == 'verified';

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    email: json['email'] as String? ?? '',
    firstName: (json['firstName'] ?? json['first_name'] ?? '') as String,
    lastName: (json['lastName'] ?? json['last_name'] ?? '') as String,
    phone: json['phone'] as String?,
    phoneCode: json['phone_code'] as String?,
    role: json['role'] as String?,
    status: json['status'] as String?,
    verificationStatus: json['verification_status'] as String?,
    accountStatus: json['account_status'] as String?,
    twoFactorEnabled: (json['two_factor_enabled'] ?? json['two_factor_authentication']) as bool? ?? false,
    avatarUrl: json['avatar_url'] as String?,
    emailVerifiedAt: json['email_verified_at'] as String?,
    createdAt: json['created_at'] as String?,
    profileCompleted: json['profile_completed'] is int
        ? json['profile_completed'] as int
        : int.tryParse(json['profile_completed']?.toString() ?? ''),
  );

  User copyWith({
    String? role,
    String? status,
    String? verificationStatus,
    String? accountStatus,
    String? avatarUrl,
    String? phoneCode,
    String? emailVerifiedAt,
    String? createdAt,
  }) => User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    phoneCode: phoneCode ?? this.phoneCode,
    role: role ?? this.role,
    status: status ?? this.status,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    accountStatus: accountStatus ?? this.accountStatus,
    twoFactorEnabled: twoFactorEnabled,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    createdAt: createdAt ?? this.createdAt,
  );
}
