class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? phoneCode;
  final String? role; // 'employer' | 'job_seeker'
  final String? status;
  final bool twoFactorEnabled;
  final bool? verified;
  final String? verificationStatus;
  final String? accountStatus;
  final String? avatarUrl;
  final String? emailVerifiedAt;
  final String? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.phoneCode,
    this.role,
    this.status,
    this.twoFactorEnabled = false,
    this.verified,
    this.verificationStatus,
    this.accountStatus,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  bool get isVerified =>
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
    twoFactorEnabled: (json['two_factor_enabled'] ?? json['two_factor_authentication']) as bool? ?? false,
    verified: json['verified'] as bool?,
    verificationStatus: json['verification_status'] as String?,
    accountStatus: json['account_status'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    emailVerifiedAt: json['email_verified_at'] as String?,
    createdAt: json['created_at'] as String?,
  );

  User copyWith({
    String? role,
    String? status,
    bool? verified,
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
    twoFactorEnabled: twoFactorEnabled,
    verified: verified ?? this.verified,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    accountStatus: accountStatus ?? this.accountStatus,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    createdAt: createdAt ?? this.createdAt,
  );
}
