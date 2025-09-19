import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile in Firestore
      await _updateUserProfile(result.user!);

      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user!.updateDisplayName(displayName);

      // Create user profile in Firestore
      await _createUserProfile(result.user!, displayName);

      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile in Firestore
  Future<void> _updateUserProfile(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.set({
      'email': user.email,
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user, String displayName) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.set({
      'email': user.email,
      'displayName': displayName,
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // Initialize user stats
      'totalChallengesCompleted': 0,
      'totalPoints': 0,
      'carbonFootprint': 0.0,
      'wasteReduced': 0.0,
    });
  }

  // Handle authentication errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Retrieves user data from Firestore.
  ///
  /// Fetches the user document from the 'users' collection using the provided UID.
  /// Returns null if the user doesn't exist or if an error occurs.
  ///
  /// Parameters:
  /// - [uid]: The unique identifier of the user. Must not be null or empty.
  ///
  /// Returns:
  /// A map containing the user's data, or null if not found or error occurs.
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    // Input validation
    if (uid.trim().isEmpty) {
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      // Check if document exists
      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      // Return null on any error to maintain original behavior
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
