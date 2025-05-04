import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
        
        return newUser;
      }
      
      return null;
    } catch (e) {
      print('Error during registration: $e');
      throw e;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot doc = 
            await _firestore.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      
      return null;
    } catch (e) {
      print('Error during sign in: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      throw e;
    }
  }

  // Get user data
  Future<UserModel?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      
      if (user != null) {
        DocumentSnapshot doc = 
            await _firestore.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      throw e;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      throw e;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      UserModel? user = await getUserData();
      return user?.role == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}