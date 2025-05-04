import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String _error = '';
  bool _isAdmin = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _isAdmin;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        
        try {
          UserModel? userData = await _authService.getUserData();
          _user = userData;
          _isAdmin = await _authService.isAdmin();
        } catch (e) {
          _error = e.toString();
        }
        
        _isLoading = false;
        notifyListeners();
      } else {
        _user = null;
        _isAdmin = false;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      UserModel? result = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      
      _user = result;
      _isLoading = false;
      notifyListeners();
      
      if (result != null) {
        _isAdmin = await _authService.isAdmin();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      UserModel? result = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
      );
      
      _user = result;
      _isLoading = false;
      notifyListeners();
      
      return result != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _authService.updateUserProfile(updatedUser);
      _user = updatedUser;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}