import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for all remote Firestore operations.
/// Provides standardized error handling and common CRUD wrappers.
class FirestoreSource {
  final FirebaseFirestore firestore;

  FirestoreSource({FirebaseFirestore? firestoreInstance})
    : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  /// Generic GET document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String id,
  ) async {
    try {
      return await firestore.collection(collection).doc(id).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Generic GET collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection,
  ) async {
    try {
      return await firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  /// Generic GET with query
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection(
    String collection,
    Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>>,
    )
    queryBuilder,
  ) async {
    try {
      final ref = firestore.collection(collection);
      return await queryBuilder(ref).get();
    } catch (e) {
      throw Exception('Failed to query collection: $e');
    }
  }

  /// Generic SET document
  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data, {
    SetOptions? options,
  }) async {
    try {
      await firestore.collection(collection).doc(id).set(data, options);
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

  /// Generic ADD document (auto-generated ID)
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  /// Generic UPDATE document
  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Generic DELETE document
  Future<void> deleteDocument(String collection, String id) async {
    try {
      await firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
