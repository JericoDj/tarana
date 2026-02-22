import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/local/local_storage_source.dart';
import '../../shared/enums/user_role.dart';
import '../../services/auth_service.dart';
import '../../core/constants/firestore_paths.dart';

/// Auth provider — manages authentication state and user data
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSub;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  UserRole get activeRole => _user?.activeRole ?? UserRole.rider;
  bool get isDriver => _user?.isDriver ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSub = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    await _loadUserData(firebaseUser.uid);
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();

      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);

        // Check if account is soft-deleted
        if (_user!.status == 'soft_deleted') {
          await _authService.signOut();
          _user = null;
          _error = 'This account has been deactivated.';
        } else {
          LocalStorageSource.activeRole = _user!.activeRole.toFirestore();
        }
      }
    } catch (e) {
      _error = 'Failed to load user data.';
    }
    notifyListeners();
  }

  /// Register a new user (defaults to rider role)
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    String? referralCode,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final userRefCode = const Uuid().v4().substring(0, 8).toUpperCase();

      final newUser = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        phone: phone,
        roles: [UserRole.rider],
        activeRole: UserRole.rider,
        referralCode: userRefCode,
        referredBy: referralCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .set(newUser.toFirestore());

      await _authService.updateDisplayName(displayName);
      _user = newUser;
      LocalStorageSource.activeRole = 'rider';

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with email & password
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to send reset email.';
      _setLoading(false);
      return false;
    }
  }

  /// Switch active role (rider ↔ driver)
  Future<void> switchRole(UserRole role) async {
    if (_user == null) return;
    if (!_user!.roles.contains(role)) return;

    _user = _user!.copyWith(activeRole: role);
    LocalStorageSource.activeRole = role.toFirestore();

    await _firestore.collection(FirestorePaths.users).doc(_user!.uid).update({
      'activeRole': role.toFirestore(),
    });

    notifyListeners();
  }

  /// Soft-delete account
  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    _setLoading(true);

    try {
      final now = DateTime.now();
      await _firestore.collection(FirestorePaths.users).doc(_user!.uid).update({
        'status': 'soft_deleted',
        'deletedAt': Timestamp.fromDate(now),
        'purgeScheduledAt': Timestamp.fromDate(
          now.add(const Duration(days: 30)),
        ),
      });

      await _authService.signOut();
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to delete account.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    LocalStorageSource.activeRole = null;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    if (_user == null) return false;
    _setLoading(true);

    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      if (displayName != null) updates['displayName'] = displayName;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection(FirestorePaths.users)
          .doc(_user!.uid)
          .update(updates);

      _user = _user!.copyWith(
        displayName: displayName,
        phone: phone,
        photoUrl: photoUrl,
      );

      if (displayName != null) {
        await _authService.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await _authService.updatePhotoUrl(photoUrl);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to update profile.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
