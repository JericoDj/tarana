import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/app_constants.dart';

/// Firebase Storage service for file uploads
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile photo and return download URL
  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    final ref = _storage
        .ref()
        .child(AppConstants.storageProfilePhotos)
        .child('$uid.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload driver document and return download URL
  Future<String> uploadDriverDocument({
    required String uid,
    required String docType,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final ref = _storage
        .ref()
        .child(AppConstants.storageDriverDocs)
        .child(uid)
        .child('$docType.$ext');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload vehicle photo and return download URL
  Future<String> uploadVehiclePhoto({
    required String uid,
    required File file,
    required String photoName,
  }) async {
    final ref = _storage
        .ref()
        .child(AppConstants.storageVehiclePhotos)
        .child(uid)
        .child('$photoName.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Delete file from storage
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // File may not exist, ignore
    }
  }
}
