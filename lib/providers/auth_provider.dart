import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../main.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  static const String _loggedInUserIdKey = 'loggedInUserId';

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider(this._authService) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_loggedInUserIdKey);
    if (userId == null) {
      return;
    }
    final userBox = Hive.box<UserModel>(usersBoxName);
    _currentUser = userBox.get(userId);
    if (_currentUser != null) {
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    String? email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      UserModel? user = await _authService.registerUser(
          username: username, password: password, email: email);
      _currentUser = user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_loggedInUserIdKey, user.userId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      UserModel? user = await _authService.loginUser(username: username, password: password);
      _currentUser = user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_loggedInUserIdKey, user.userId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserIdKey);
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    String? newUsername,
    String? newEmail,
    String? currentPassword,
    String? newPassword,
    String? newProfileImagePath,
  }) async {
    if (_currentUser == null) {
      _error = "Profil güncellemek için önce giriş yapmalısınız.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserModel? updatedUser = await _authService.updateUserProfile(
        userId: _currentUser!.userId,
        newUsername: newUsername,
        newEmail: newEmail,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newProfileImagePath: newProfileImagePath,
      );
      if (updatedUser != null) {
        _currentUser = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}