// lib/providers/connectivity_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;
  Timer? _syncTimer;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _initConnectivity();
    _startAutoSync();
  }

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();

    // Check initial state
    final result = await connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();

    // Listen for changes
    connectivity.onConnectivityChanged.listen((result) async {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();

      // Came back online → verify actual internet access
      if (wasOffline && _isOnline) {
        final hasNet = await ApiService.instance.hasConnection();
        _isOnline = hasNet;
        notifyListeners();
      }
    });
  }

  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      if (_isOnline) {
        await ApiService.instance.syncPendingData();
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
