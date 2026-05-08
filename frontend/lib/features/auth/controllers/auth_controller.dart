import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth firebase_auth = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) async {
    dev.log('[AuthController] Login attempt for email: $email');
    try {
      final UserCredential userCredential = await firebase_auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      dev.log('[AuthController] Login successful for user: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      dev.log('[AuthController] FirebaseAuthException: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'An unknown error occurred during login');
    } catch (e) {
      dev.log('[AuthController] Login error: $e');
      throw Exception('An error occurred during login');
    }
  }

  Future<UserCredential> signup(String email, String password, String username) async {
    dev.log('[AuthController] Signup attempt for email: $email');
    try {
      final UserCredential userCredential = await firebase_auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name with the username
      await userCredential.user?.updateDisplayName(username);
      
      dev.log('[AuthController] Signup successful for user: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      dev.log('[AuthController] FirebaseAuthException: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'An unknown error occurred during signup');
    } catch (e) {
      dev.log('[AuthController] Signup error: $e');
      throw Exception('An error occurred during signup');
    }
  }

  Future<void> logout() async {
    await firebase_auth.signOut();
    dev.log('[AuthController] User logged out');
  }

  User? get currentUser => firebase_auth.currentUser;

  Stream<User?> get authStateChanges => firebase_auth.authStateChanges();
}
