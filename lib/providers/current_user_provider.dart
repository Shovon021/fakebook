import 'package:flutter/material.dart';
import 'dart:async';
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
  StreamSubscription? _userSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get userId => _authService.currentUserId;

  /// Initialize and listen to auth state changes
  void init() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _listenToCurrentUser(user.uid);
      } else {
        // User logged out - clean up properly
        _userSubscription?.cancel();
        _userSubscription = null;
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToCurrentUser(String uid) {
    _isLoading = true;
    notifyListeners();

    // CRITICAL: Cancel any existing subscription before creating new one
    _userSubscription?.cancel();
    _userSubscription = _userService.getUserStream(uid).listen(
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ User stream error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Refresh current user data (re-subscribes to stream)
  void refresh() {
    final uid = _authService.currentUserId;
    if (uid != null) {
      _listenToCurrentUser(uid);
    }
  }

  /// Clear user data (for logout/account deletion)
  void clearUser() {
    _userSubscription?.cancel();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
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
