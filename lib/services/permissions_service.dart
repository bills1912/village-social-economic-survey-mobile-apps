// lib/services/permissions_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';

/// Fitur-fitur yang bisa dikontrol dari web admin.
/// ID harus cocok dengan FEATURES di src/data/mockData.ts
class AppFeatures {
  static const String dashboard            = 'dashboard';
  static const String questionnaireView    = 'questionnaire_view';
  static const String questionnaireCreate  = 'questionnaire_create';
  static const String questionnaireEdit    = 'questionnaire_edit';
  static const String questionnaireDelete  = 'questionnaire_delete';
  static const String reports              = 'reports';
  static const String reportsExport        = 'reports_export';
  static const String userView             = 'user_view';
  static const String userCreate           = 'user_create';
  static const String userEdit             = 'user_edit';
  static const String featureManagement    = 'feature_management';
  static const String syncManage           = 'sync_manage';
  static const String offlineMode          = 'offline_mode';
  static const String gpsLocation          = 'gps_location';
}

class PermissionsService {
  static PermissionsService? _instance;
  static PermissionsService get instance => _instance ??= PermissionsService._();
  PermissionsService._();

  static const _cacheKey = 'user_permissions';
  static const _timeout  = Duration(seconds: 10);

  List<String> _permissions = [];

  /// Apakah permissions sudah di-load
  bool get isLoaded => _permissions.isNotEmpty;

  /// Fetch permissions dari server lalu cache ke SharedPreferences.
  /// Dipanggil saat login berhasil.
  Future<void> fetchAndCache(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/permissions/my'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = List<String>.from(body['permissions'] as List? ?? []);
        _permissions = list;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(list));
        debugPrint('✅ Permissions loaded (${list.length}): $list');
        return;
      }
    } catch (e) {
      debugPrint('⚠️  Fetch permissions failed: $e — using cache');
    }
    // Fallback: load dari cache
    await loadFromCache();
  }

  /// Load dari cache (untuk offline / restart app)
  Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        _permissions = List<String>.from(jsonDecode(raw) as List);
        debugPrint('📦 Permissions from cache: $_permissions');
      } else {
        _setDefaults();
      }
    } catch (_) {
      _setDefaults();
    }
  }

  /// Default permissions saat tidak ada cache (belum pernah online)
  void _setDefaults() {
    _permissions = [
      AppFeatures.dashboard,
      AppFeatures.questionnaireView,
      AppFeatures.questionnaireCreate,
      AppFeatures.questionnaireEdit,
      AppFeatures.reports,
      AppFeatures.offlineMode,
      AppFeatures.gpsLocation,
    ];
    debugPrint('🔧 Using default permissions');
  }

  /// Cek apakah user punya akses ke fitur tertentu
  bool can(String feature) => _permissions.contains(feature);

  /// Reset saat logout
  void clear() {
    _permissions = [];
    SharedPreferences.getInstance().then((p) => p.remove(_cacheKey));
  }
}