import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/saved_place_model.dart';
import '../../data/repositories/place_repository.dart';
import '../../presentation/providers/auth_provider.dart';

class PlaceProvider with ChangeNotifier {
  final PlaceRepository _placeRepository;
  final AuthProvider _authProvider;

  PlaceProvider({
    PlaceRepository? placeRepository,
    required AuthProvider authProvider,
  }) : _placeRepository = placeRepository ?? PlaceRepository(),
       _authProvider = authProvider {
    _init();
  }

  List<SavedPlaceModel> _savedPlaces = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<SavedPlaceModel>>? _placesSubscription;

  List<SavedPlaceModel> get savedPlaces => _savedPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    final user = _authProvider.user;
    if (user != null) {
      _listenToSavedPlaces(user.uid);
    } else {
      _placesSubscription?.cancel();
      _savedPlaces = [];
      notifyListeners();
    }
  }

  void _listenToSavedPlaces(String uid) {
    _placesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _placesSubscription = _placeRepository
        .getSavedPlacesStream(uid)
        .listen(
          (places) {
            _savedPlaces = places;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _isLoading = false;
            _error = 'Failed to load places: $e';
            notifyListeners();
          },
        );
  }

  Future<void> addSavedPlace({
    required String label,
    required String address,
    required double lat,
    required double lng,
    String? googlePlaceId,
  }) async {
    final uid = _authProvider.user?.uid;
    if (uid == null) return;

    try {
      final place = SavedPlaceModel(
        id: '', // Firestore generates this
        label: label,
        address: address,
        lat: lat,
        lng: lng,
        googlePlaceId: googlePlaceId,
        createdAt: DateTime.now(),
      );
      await _placeRepository.addSavedPlace(uid, place);
    } catch (e) {
      _error = 'Failed to add place: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSavedPlace(
    String placeId,
    Map<String, dynamic> data,
  ) async {
    final uid = _authProvider.user?.uid;
    if (uid == null) return;

    try {
      await _placeRepository.updateSavedPlace(uid, placeId, data);
    } catch (e) {
      _error = 'Failed to update place: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSavedPlace(String placeId) async {
    final uid = _authProvider.user?.uid;
    if (uid == null) return;

    try {
      await _placeRepository.deleteSavedPlace(uid, placeId);
    } catch (e) {
      _error = 'Failed to delete place: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    _placesSubscription?.cancel();
    super.dispose();
  }
}
