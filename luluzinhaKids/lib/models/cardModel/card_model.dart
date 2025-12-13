import 'package:cloud_firestore/cloud_firestore.dart';

class SavedCard {
  final String id;
  final String holder;
  final String last4;
  final String brand;
  final DateTime? createdAt;

  SavedCard({
    required this.id,
    required this.holder,
    required this.last4,
    required this.brand,
    this.createdAt,
  });

  factory SavedCard.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedCard(
      id: doc.id,
      holder: data['holder'] as String,
      last4: data['last4'] as String,
      brand: data['brand'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
