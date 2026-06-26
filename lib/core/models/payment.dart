class Payment {
  final int id;
  final double amount;
  final String currency;
  final String status;
  final String planName;
  final String invoiceRef;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.planName,
    required this.invoiceRef,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'GBP',
      status: json['status']?.toString() ?? 'unknown',
      planName: json['plan_name']?.toString() ?? '',
      invoiceRef: json['invoice_ref']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])?.toLocal() ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}
