// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/permissions_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _user = await StorageService.instance.getUser();
    if (_user != null) {
      // Load cached permissions saat app restart
      await PermissionsService.instance.loadFromCache();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.instance.login(email, password);
      final token = data['token'] ?? data['access_token'];
      if (token == null) throw Exception('Token tidak ditemukan');

      await StorageService.instance.saveToken(token.toString());

      final userData = data['user'] ?? data;
      _user = User.fromJson(Map<String, dynamic>.from(userData));
      _user = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        avatarUrl: _user!.avatarUrl,
        roles: _user!.roles,
        token: token.toString(),
      );
      await StorageService.instance.saveUser(_user!);

      // ── Fetch permissions dari server setelah login ──────────────────────
      await PermissionsService.instance.fetchAndCache(token.toString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.instance.logout();
    await StorageService.instance.removeToken();
    await StorageService.instance.removeUser();
    PermissionsService.instance.clear(); // ── Hapus permissions saat logout
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}