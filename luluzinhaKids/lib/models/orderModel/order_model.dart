import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id; // productId
  final String name;
  final double price;
  final int quantity;
  final String selectedSize;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.selectedSize,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'selectedSize': selectedSize,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    id: map['id'] as String,
    name: map['name'] as String,
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'] as int,
    selectedSize: map['selectedSize'] as String,
  );
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'items': items.map((e) => e.toMap()).toList(),
    'total': total,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Order.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    return Order(
      id: doc.id,
      userId: data['userId'] as String,
      items:
          itemsData
              .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList(),
      total: (data['total'] as num).toDouble(),
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
