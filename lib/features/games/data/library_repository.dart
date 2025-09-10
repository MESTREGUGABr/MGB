import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../games/domain/game_model.dart';
import '../domain/library_entry.dart';

class LibraryRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  LibraryRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) {
      throw StateError('Usuário não autenticado.');
    }
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> _docRef(int gameId) {
    return _db.collection('users').doc(_uid).collection('library').doc('$gameId');
  }

  Future<void> upsertEntry({
    required GameModel game,
    required String status,
    int rating = 0,
  }) async {
    final now = DateTime.now();
    final ref = _docRef(game.id);
    await ref.set({
      'userId': _uid,
      'gameId': game.id,
      'name': game.name,
      'backgroundImage': game.backgroundImage,
      'status': status,
      'rating': rating,
      'addedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setStatus(int gameId, String status) async {
    await _docRef(gameId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setRating(int gameId, int rating) async {
    await _docRef(gameId).set({
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<LibraryEntry>> streamByStatus(String status) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('library')
        .where('status', isEqualTo: status)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => LibraryEntry.fromMap(d.data())).toList());
  }
}
