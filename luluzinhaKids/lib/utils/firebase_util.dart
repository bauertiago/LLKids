import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    await FirebaseFirestore.instance.collection("users").doc(uid).set(data);
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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);

      // 🔥 Se o usuário é novo, cria documento no Firestore
      final uid = userCredential.user!.uid;

      final exists = await firestore.collection("users").doc(uid).get();

      if (!exists.exists) {
        await firestore.collection("users").doc(uid).set({
          "name": userCredential.user!.displayName ?? "",
          "email": userCredential.user!.email ?? "",
          "phone": userCredential.user!.phoneNumber ?? "",
          "role": "user",
          "createdAt": DateTime.now().toIso8601String(),
        });
      }

      return userCredential;
    } catch (e) {
      print("Erro Google Sign-In: $e");
      return null;
    }
  }
}
