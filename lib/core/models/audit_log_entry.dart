class AuditLogEntry {
  final String id;
  final String action;
  final String? ipAddress;
  final String? userAgent;
  final DateTime? createdAt;

  AuditLogEntry({
    required this.id,
    required this.action,
    this.ipAddress,
    this.userAgent,
    this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id']?.toString() ?? '',
      action: json['action'] as String? ?? 'Unknown',
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])?.toLocal()
          : null,
    );
  }
}
