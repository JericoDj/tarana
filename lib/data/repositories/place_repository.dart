import '../models/saved_place_model.dart';
import '../datasources/remote/firestore_source.dart';
import '../../core/constants/firestore_paths.dart';

class PlaceRepository {
  final FirestoreSource _firestoreSource;

  PlaceRepository({FirestoreSource? firestoreSource})
    : _firestoreSource = firestoreSource ?? FirestoreSource();

  String _userSavedPlacesPath(String uid) =>
      '${FirestorePaths.users}/$uid/saved_places';

  /// Add a saved place
  Future<void> addSavedPlace(String uid, SavedPlaceModel place) async {
    final ref = _firestoreSource.firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('saved_places');
    await ref.add(place.toFirestore());
  }

  /// Get stream of saved places
  Stream<List<SavedPlaceModel>> getSavedPlacesStream(String uid) {
    return _firestoreSource.firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('saved_places')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedPlaceModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Update a saved place
  Future<void> updateSavedPlace(
    String uid,
    String placeId,
    Map<String, dynamic> data,
  ) async {
    final path = _userSavedPlacesPath(uid);
    await _firestoreSource.updateDocument(path, placeId, data);
  }

  /// Delete a saved place
  Future<void> deleteSavedPlace(String uid, String placeId) async {
    final path = _userSavedPlacesPath(uid);
    await _firestoreSource.deleteDocument(path, placeId);
  }
}
