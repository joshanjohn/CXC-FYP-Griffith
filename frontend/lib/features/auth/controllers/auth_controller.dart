import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cxc/features/auth/services/auth_token_service.dart';

// Firebase Auth Controller
class AuthController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login 
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

  // sign up or register 
  Future<UserCredential> signup(
    String email,
    String password, [
    String? username,
  ]) async {
    dev.log('[AuthController] Signup attempt for email: $email');
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String displayName = (username != null && username.isNotEmpty)
          ? username
          : email.split('@').first;
      await userCredential.user?.updateDisplayName(displayName);

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

  // logout 
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await AuthTokenService().clearToken();
    dev.log('[AuthController] User logged out');
  }

  // delete auth from firebase
  Future<void> deleteCurrentUserAccount() async {
    final user = firebaseAuth.currentUser;

    // checking user exist 
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

  // current user 
  User? get currentUser => firebaseAuth.currentUser;

  // flag for auth status 
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}
