import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double costPrice;
  final double salePrice;
  final String description;
  final String category;
  final String imageUrl;
  final Map<String, int> stock;
  final bool highlight;
  final DateTime createdAt;
  final List<String> searchKeywords;

  int quantity;
  String? selectedSize;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.salePrice,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.highlight,
    required this.createdAt,
    required this.searchKeywords,
    this.quantity = 1,
    this.selectedSize,
  });

  factory Product.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(",", ".")) ?? 0.0;
      }

      return 0.0;
    }

    return Product(
      id: doc.id,
      name: data["name"] ?? "",
      costPrice: parseDouble(data["costPrice"]),
      salePrice: parseDouble(data["salePrice"]),
      description: data["description"] ?? "",
      category: data["category"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      stock: Map<String, int>.from(data["stock"] ?? {}),
      highlight: data["highlight"] ?? false,
      createdAt: (data["createdAt"] as Timestamp).toDate(),
      searchKeywords: List<String>.from(data["searchKeywords"] ?? []),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      "name": name,
      "costPrice": costPrice,
      "salePrice": salePrice,
      "description": description,
      "category": category,
      "imageUrl": imageUrl,
      "stock": stock,
      "highlight": highlight,
      "createdAt": createdAt,
      "searchKeywords": generateKeywords(name),
    };
  }

  static List<String> generateKeywords(String text) {
    final split = text.toLowerCase().split(" ");
    final List<String> result = [];

    for (var word in split) {
      for (int i = 1; i <= word.length; i++) {
        result.add(word.substring(0, i)); // cam, cami, camisa ...
      }
    }
    return result.toSet().toList();
  }
}
