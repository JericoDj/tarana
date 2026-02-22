import '../models/driver_application_model.dart';
import '../datasources/remote/firestore_source.dart';

class DriverApplicationRepository {
  final FirestoreSource _firestoreSource;

  DriverApplicationRepository({FirestoreSource? firestoreSource})
    : _firestoreSource = firestoreSource ?? FirestoreSource();

  // The collection name
  static const String _collectionName = 'driver_applications';

  /// Fetch an application by UID
  Future<DriverApplicationModel?> getApplication(String uid) async {
    try {
      final snapshot = await _firestoreSource.queryCollection(
        _collectionName,
        (ref) => ref.where('uid', isEqualTo: uid).limit(1),
      );

      if (snapshot.docs.isNotEmpty) {
        return DriverApplicationModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get application: $e');
    }
  }

  /// Check if the user has an existing application
  Future<bool> hasApplication(String uid) async {
    final app = await getApplication(uid);
    return app != null;
  }

  /// Submit a new application
  Future<void> submitApplication(DriverApplicationModel application) async {
    try {
      await _firestoreSource.setDocument(
        _collectionName,
        application.uid, // Use UID as the document ID for 1-to-1 relationship
        application.toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Update an existing application (e.g. status)
  Future<void> updateApplication(String uid, Map<String, dynamic> data) async {
    try {
      await _firestoreSource.updateDocument(_collectionName, uid, data);
    } catch (e) {
      throw Exception('Failed to update application: $e');
    }
  }

  /// Fetch all pending applications (admin)
  Future<List<DriverApplicationModel>> getPendingApplications() async {
    try {
      final snapshot = await _firestoreSource.queryCollection(
        _collectionName,
        (ref) =>
            ref.where('status', isEqualTo: 'pending').orderBy('submittedAt'),
      );
      return snapshot.docs
          .map((doc) => DriverApplicationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending applications: $e');
    }
  }

  /// Admin approve/reject an application
  Future<void> reviewApplication({
    required String uid,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    try {
      await _firestoreSource.updateDocument(_collectionName, uid, {
        'status': status,
        'reviewedBy': reviewerUid,
        'reviewedAt': DateTime.now().toIso8601String(),
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      });
    } catch (e) {
      throw Exception('Failed to review application: $e');
    }
  }
}
