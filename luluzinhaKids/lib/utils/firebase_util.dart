import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtil {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential> register(String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.sendEmailVerification();

    return credential;
  }

  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await firestore.collection("users").doc(uid).set(data);
  }

  Future<void> addAdress(String uid, Map<String, dynamic> address) async {
    await firestore
        .collection("users")
        .doc(uid)
        .collection("addresses")
        .add(address);
  }

  Future<List<Map<String, dynamic>>> loadAddresses(String uid) async {
    final snap =
        await firestore
            .collection("users")
            .doc(uid)
            .collection("addresses")
            .get();
    return snap.docs.map((doc) => {...doc.data(), "id": doc.id}).toList();
  }
}
