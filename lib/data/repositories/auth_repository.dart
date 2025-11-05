import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await credential.user?.sendEmailVerification();

      // Create user document in Firestore
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification
      if (credential.user?.emailVerified == false) {
        throw Exception('Please verify your email before signing in');
      }

      // Get user data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }

      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await currentUser?.sendEmailVerification();
  }
}
