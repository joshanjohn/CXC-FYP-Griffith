import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cxc/core/services/auth_token_service.dart';

class AuthController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) async {
    dev.log('[AuthController] Login attempt for email: $email');
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      dev.log(
        '[AuthController] Login successful for user: ${userCredential.user?.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      dev.log(
        '[AuthController] FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw Exception(e.message ?? 'An unknown error occurred during login');
    } catch (e) {
      dev.log('[AuthController] Login error: $e');
      throw Exception('An error occurred during login');
    }
  }

  Future<UserCredential> signup(
    String email,
    String password,
    String username,
  ) async {
    dev.log('[AuthController] Signup attempt for email: $email');
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name with the username
      await userCredential.user?.updateDisplayName(username);

      dev.log(
        '[AuthController] Signup successful for user: ${userCredential.user?.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      dev.log(
        '[AuthController] FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw Exception(e.message ?? 'An unknown error occurred during signup');
    } catch (e) {
      dev.log('[AuthController] Signup error: $e');
      throw Exception('An error occurred during signup');
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
    await AuthTokenService().clearToken();
    dev.log('[AuthController] User logged out');
  }

  Future<void> deleteCurrentUserAccount() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user found.');
    }

    try {
      await user.delete();
      await AuthTokenService().clearToken();
      dev.log('[AuthController] User account deleted: ${user.uid}');
    } on FirebaseAuthException catch (e) {
      dev.log(
        '[AuthController] Delete account error: ${e.code} - ${e.message}',
      );
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'For security, please sign in again before deleting your account.',
        );
      }
      throw Exception(
        e.message ?? 'An unknown error occurred during account deletion',
      );
    } catch (e) {
      dev.log('[AuthController] Delete account error: $e');
      throw Exception('An error occurred during account deletion');
    }
  }

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}
