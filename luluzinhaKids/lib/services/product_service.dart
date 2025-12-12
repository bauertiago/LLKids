import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luluzinhakids/models/productModel/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;

  Future<List<Product>> getAllProducts() async {
    final results = await _db
        .collection("products")
        .orderBy("createdAt", descending: true)
        .get();
    return results.docs.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getLatestHighlights() async {
    final results = await _db
        .collection("products")
        .orderBy("createdAt", descending: true)
        .limit(3)
        .get();

    return results.docs.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryName) async {
    final results = await _db
        .collection("products")
        .where("category", isEqualTo: categoryName)
        .get();

    return results.docs.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<String>> getCategories() async {
    final results = await _db.collection("products").get();

    return results.docs.map((e) => e["category"] as String).toSet().toList();
  }

  Future<List<Product>> searchProducts(String text) async {
    if (text.isEmpty) {
      return [];
    }
    final results = await _db
        .collection("products")
        .where("searchKeywords", arrayContains: text.toLowerCase())
        .get();

    return results.docs.map((e) => Product.fromMap(e)).toList();
  }
}
