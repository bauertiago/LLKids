import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/customerModels/customer_model.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;

  CustomerService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Customer? _currentCustomer;

  Future<Customer?> loadCustomer() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection("users").doc(user.uid).get();
    if (!doc.exists) return null;

    _currentCustomer = Customer.fromMap(doc.data()!, doc.id);
    return _currentCustomer;
  }

  Customer? get currentCustomer => _currentCustomer;

  Future<void> updateCustomer(Customer updated) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("users").doc(user.uid).update(updated.toMap());
    _currentCustomer = updated;
  }

  Future<void> updateImage(String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null || _currentCustomer == null) return;

    _currentCustomer = _currentCustomer!.copyWith(imageUrl: imageUrl);

    await _firestore.collection("users").doc(user.uid).update({
      "imageUrl": imageUrl,
    });
  }
}
