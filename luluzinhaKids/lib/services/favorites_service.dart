import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luluzinhakids/models/productModels/product_model.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference get favRef =>
      _db.collection('users').doc(uid).collection('favorites');

  Stream<List<Product>> watchFavorites() {
    return favRef.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data["name"],
          costPrice: data["costPrice"]?.toDouble() ?? 0,
          salePrice: data["salePrice"]?.toDouble() ?? 0,
          description: data["description"] ?? "",
          category: data["category"] ?? "",
          imageUrl: data["imageUrl"],
          stock: Map<String, int>.from(data["stock"] ?? {}),
          highlight: data["highlight"] ?? false,
          createdAt: (data["createdAt"] as Timestamp).toDate(),
          searchKeywords: List<String>.from(data["searchKeywords"] ?? []),
        );
      }).toList();
    });
  }

  Future<void> toggleFavorite(Product product) async {
    final doc = favRef.doc(product.id);
    final snap = await doc.get();

    if (snap.exists) {
      await doc.delete();
    } else {
      await doc.set(product.toDatabase());
    }
  }

  Future<bool> isFavorite(String id) async {
    return (await favRef.doc(id).get()).exists;
  }
}
