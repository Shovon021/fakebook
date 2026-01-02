import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Provider to manage current logged-in user state across the app
class CurrentUserProvider extends ChangeNotifier {
  static final CurrentUserProvider _instance = CurrentUserProvider._internal();
  factory CurrentUserProvider() => _instance;
  CurrentUserProvider._internal();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get userId => _authService.currentUserId;

  /// Initialize and listen to auth state changes
  void init() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadCurrentUser(user.uid);
      } else {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _userService.getUserById(uid);
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh current user data
  Future<void> refresh() async {
    final uid = _authService.currentUserId;
    if (uid != null) {
      await _loadCurrentUser(uid);
    }
  }

  /// Get a default placeholder user when not logged in (for backwards compatibility)
  UserModel get currentUserOrDefault {
    return _currentUser ?? UserModel(
      id: 'guest',
      name: 'Guest User',
      avatarUrl: 'https://i.imgur.com/K3Z3gM9.jpeg',
    );
  }
}

// Global instance for easy access
final currentUserProvider = CurrentUserProvider();
