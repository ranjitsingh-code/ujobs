class WalletTransaction {
  final int id;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'credit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])?.toLocal() ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}

class Wallet {
  final double balance;
  final List<WalletTransaction> recentTransactions;

  Wallet({
    required this.balance,
    required this.recentTransactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: (json['transactions'] as List?)
          ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
