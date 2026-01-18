import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of Auth Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get Current User ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Get Current User (for reload operations)
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create User in Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;

      if (user == null) return null;

      // 2. Create User Doc in Firestore
      final newUser = UserModel(
        id: user.uid,
        name: name,
        avatarUrl: 'https://i.imgur.com/K3Z3gM9.jpeg', // Default avatar
        isOnline: true,
        friendsCount: 0,
        bio: 'New User',
        details: [],
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      // 3. Send Verification Email & Sign Out
      await user.sendEmailVerification();
      await _auth.signOut();

      return newUser;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      rethrow;
    }
  }

  // Sign In
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      
      if (user != null) {
        // Reload user to get fresh emailVerified status
        await user.reload();
        final freshUser = _auth.currentUser;
        
        if (freshUser != null && !freshUser.emailVerified) {
          await freshUser.sendEmailVerification();
          await _auth.signOut();
          throw Exception('Email not verified. A new verification link has been sent to $email.');
        }
      }
      
      return _auth.currentUser;
    } catch (e) {
      debugPrint('SignIn Error: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
