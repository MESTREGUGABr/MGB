import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mgb/user/domain/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> search(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

    } catch (e) {
      print("Erro ao buscar usuários: $e");
      // Retorna uma lista vazia em caso de erro para não quebrar a UI
      return [];
    }
  }
}