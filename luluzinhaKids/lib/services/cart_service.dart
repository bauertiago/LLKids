import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/productModels/product_model.dart';

class CartService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference get cartRef =>
      _db.collection('users').doc(uid).collection('cart');
  Future<List<Product>> loadCart() async {
    final data = await cartRef.get();
    return data.docs.map((doc) {
      final map = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id,
        name: map["name"],
        costPrice: 0,
        salePrice: map["salePrice"]?.toDouble() ?? 0.0,
        description: "",
        category: "",
        imageUrl: map["imageUrl"],
        stock: {},
        highlight: false,
        createdAt: DateTime.now(),
        searchKeywords: [],
        quantity: map["quantity"],
        selectedSize: map["selectedSize"],
      );
    }).toList();
  }

  Future<void> addToCart(Product product) async {
    final doc = cartRef.doc(product.id);
    final item = await doc.get();

    if (item.exists) {
      await doc.update({"quantity": item["quantity"] + 1});
    } else {
      await doc.set({
        "name": product.name,
        "imageUrl": product.imageUrl,
        "salePrice": product.salePrice,
        "quantity": product.quantity,
        "selectedSize": product.selectedSize,
      });
    }
  }

  Future<void> removeFromCart(Product product) async =>
      await cartRef.doc(product.id).delete();

  Future<void> addQuantity(Product product) async {
    await cartRef.doc(product.id).update({"quantity": product.quantity + 1});
  }

  Future<void> decreaseQuantity(Product product) async {
    final doc = cartRef.doc(product.id);
    final item = await doc.get();
    if (item.exists && item["quantity"] > 1) {
      await doc.update({"quantity": item["quantity"] - 1});
    } else {
      removeFromCart(product);
    }
  }

  Stream<List<Product>> watchCart() => cartRef.snapshots().map(
    (snap) =>
        snap.docs.map((d) {
          final map = d.data() as Map<String, dynamic>;
          return Product(
            id: d.id,
            name: map["name"],
            costPrice: 0,
            salePrice: map["salePrice"],
            description: "",
            category: "",
            imageUrl: map["imageUrl"],
            stock: {},
            highlight: false,
            createdAt: DateTime.now(),
            searchKeywords: [],
            quantity: map["quantity"],
            selectedSize: map["selectedSize"],
          );
        }).toList(),
  );

  double getTotal(List<Product> cart) =>
      cart.fold<double>(0.0, (t, p) => t + (p.salePrice * p.quantity));

  Future<void> clearCart() async {
    final batch = _db.batch();
    final items = await cartRef.get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> exportCartItems() async {
    final snap = await cartRef.get();
    final items = <Map<String, dynamic>>[];

    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final productId = doc.id;
      final productDoc =
          await FirebaseFirestore.instance
              .collection("products")
              .doc(productId)
              .get();

      double costPrice = 0;
      if (productDoc.exists) {
        final productData = productDoc.data()!;
        costPrice = (productData["costPrice"] ?? 0).toDouble();
      }

      items.add({
        "id": productId,
        "name": data["name"],
        "quantity": data["quantity"],
        "price": data["salePrice"],
        "selectedSize": data["selectedSize"],
        "costPrice": costPrice,
      });
    }
    return items;
  }
}
