import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/addressModel/address_model.dart';

class AddressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _addressCollection() {
    final uid = _uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently logged in.',
      );
    }
    return _firestore.collection("users").doc(_uid).collection("addresses");
  }

  Future<List<Address>> loadAddresses() async {
    final snapshot =
        await _addressCollection()
            .orderBy("createdAt", descending: false)
            .get();

    return snapshot.docs
        .map((doc) => Address.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<Address> addAddress(Address address) async {
    final data = address.toMap()..["createdAt"] = FieldValue.serverTimestamp();

    final doc = await _addressCollection().add(data);

    return address.copyWith(id: doc.id);
  }

  Future<void> deleteAddress(String id) async {
    await _addressCollection().doc(id).delete();
  }
}
