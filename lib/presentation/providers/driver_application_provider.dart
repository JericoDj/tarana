import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/driver_application_model.dart';
import '../../data/repositories/driver_application_repository.dart';
import '../../services/storage_service.dart';
import '../../presentation/providers/auth_provider.dart';

class DriverApplicationProvider extends ChangeNotifier {
  final DriverApplicationRepository _repository;
  final StorageService _storageService;
  final AuthProvider _authProvider;

  DriverApplicationProvider({
    required AuthProvider authProvider,
    DriverApplicationRepository? repository,
    StorageService? storageService,
  }) : _authProvider = authProvider,
       _repository = repository ?? DriverApplicationRepository(),
       _storageService = storageService ?? StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DriverApplicationModel? _application;
  DriverApplicationModel? get application => _application;

  /// Fetch the current user application
  Future<void> fetchApplication() async {
    final uid = _authProvider.user?.uid;
    if (uid == null) return;

    _setLoading(true);
    _error = null;

    try {
      _application = await _repository.getApplication(uid);
    } catch (e) {
      _error = 'Failed to load application history.';
    } finally {
      _setLoading(false);
    }
  }

  /// Submit an entire application including photos
  Future<bool> submitApplication({
    required Map<String, dynamic> vehicleInfo,
    required File licenseFile,
    required File registrationFile,
  }) async {
    final uid = _authProvider.user?.uid;
    if (uid == null) {
      _error = 'Please log in to submit an application';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      // 1. Check if an application already exists.
      final exists = await _repository.hasApplication(uid);
      if (exists) {
        throw Exception('You have already submitted an application.');
      }

      // 2. Upload Documents to Firebase Storage
      final licenseUrl = await _storageService.uploadDriverDocument(
        uid: uid,
        docType: 'license',
        file: licenseFile,
      );

      final registrationUrl = await _storageService.uploadDriverDocument(
        uid: uid,
        docType: 'registration',
        file: registrationFile,
      );

      // 3. Create the Database Document
      final application = DriverApplicationModel(
        id: uid, // Can be same as user id
        uid: uid,
        vehicleInfo: vehicleInfo,
        documents: {'license': licenseUrl, 'registration': registrationUrl},
        submittedAt: DateTime.now(),
      );

      // 4. Save to firestore
      await _repository.submitApplication(application);

      // 5. Update state
      _application = application;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
