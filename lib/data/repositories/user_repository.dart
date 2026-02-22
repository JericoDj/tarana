import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../datasources/remote/firestore_source.dart';
import '../../../core/constants/firestore_paths.dart';

class UserRepository {
  final FirestoreSource _firestoreSource;

  UserRepository({FirestoreSource? firestoreSource})
    : _firestoreSource = firestoreSource ?? FirestoreSource();

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestoreSource.getDocument(FirestorePaths.users, uid);
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _firestoreSource.setDocument(
        FirestorePaths.users,
        user.uid,
        user.toFirestore(),
        options: SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Error saving user profile: $e');
    }
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestoreSource.updateDocument(FirestorePaths.users, uid, data);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }
}
