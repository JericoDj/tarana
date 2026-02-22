import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth service wrapper
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Whether a user is currently signed in
  bool get isSignedIn => currentUser != null;

  /// Register with email & password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email & password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete auth account (for hard deletion after retention period)
  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    await currentUser?.updateDisplayName(name);
  }

  /// Update photo URL
  Future<void> updatePhotoUrl(String url) async {
    await currentUser?.updatePhotoURL(url);
  }
}
