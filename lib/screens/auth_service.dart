import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Define _auth here

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // No error, successful login
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message if login fails
    }
  }

  // Sign Up
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // No error, successful sign-up
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message if sign-up fails
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
