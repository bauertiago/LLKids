import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  /// Caminho do cartão salvo
  DocumentReference get cardRef =>
      _db.collection('users').doc(uid).collection('payment').doc('card');

  /// 🔥 Salvar cartão no Firestore
  Future<void> saveCard({
    required String number,
    required String holder,
  }) async {
    await cardRef.set({
      'holder': holder,
      'last4': number.substring(number.length - 4),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// 🔥 Buscar cartão salvo (se existir)
  Future<Map<String, dynamic>?> getSavedCard() async {
    final snap = await cardRef.get();
    return snap.exists ? snap.data() as Map<String, dynamic> : null;
  }

  /// 🔥 Remover cartão salvo
  Future<void> removeCard() async {
    await cardRef.delete();
  }
}
