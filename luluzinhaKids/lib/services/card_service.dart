import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  /// Caminho do cartão salvo
  CollectionReference get cardCollection =>
      _db.collection('users').doc(uid).collection('card');

  /// 🔥 Buscar cartão salvo (se existir)
  Future<Map<String, dynamic>?> getSavedCard() async {
    final snap = await cardCollection
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data() as Map<String, dynamic>;
  }

  /// 🔥 Remover cartão salvo
  Future<void> removeCard() async {
    final snap = await cardCollection.get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
