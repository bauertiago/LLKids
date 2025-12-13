import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String paymentMethod;
  final double amount;
  final String status;
  final String transactionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.transactionId,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      paymentMethod: data['paymentMethod'] as String,
      amount: (data['amount'] as num).toDouble(),
      status: data['status'] as String,
      transactionId: data['transactionId'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
