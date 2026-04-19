// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/questionnaire.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import 'storage_service.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  static const Duration _timeout = Duration(seconds: 30);

  String get _base => AppConstants.apiBaseUrl;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await StorageService.instance.getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ─── Connectivity ────────────────────────────────────────────────────────
  Future<bool> hasConnection() async {
    try {
      final r = await http
          .get(Uri.parse('${_base.replaceAll('/api', '')}/health'))
          .timeout(const Duration(seconds: 6));
      return r.statusCode == 200;
    } catch (_) {
      try {
        final r = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        return r.isNotEmpty && r[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  // ─── Error handling ───────────────────────────────────────────────────────
  Never _throw(http.Response res, String fallback) {
    try {
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? body['message'] ?? fallback);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(fallback);
    }
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http
        .post(
      Uri.parse('$_base/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    )
        .timeout(_timeout);

    if (res.statusCode == 200) return jsonDecode(res.body);
    _throw(res, 'Login gagal. Periksa email dan password.');
  }

  Future<void> logout() async {
    try {
      await http
          .post(Uri.parse('$_base/logout'), headers: await _headers())
          .timeout(_timeout);
    } catch (_) {}
  }

  // ─── Surveys ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getSurveys() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/surveys'), headers: await _headers())
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        await StorageService.instance.cacheSurveys(data);
        return data;
      }
      throw Exception('Gagal memuat survei');
    } catch (_) {
      return StorageService.instance.getCachedSurveys();
    }
  }

  // ─── Questionnaires ───────────────────────────────────────────────────────
  Future<List<Questionnaire>> getQuestionnaires({
    String? dusun,
    String? surveyId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, String>{
        'page': '$page',
        'limit': '$limit',
      };
      if (dusun != null) params['dusun'] = dusun;
      if (surveyId != null) params['survey_id'] = surveyId;

      final uri = Uri.parse('$_base/questionnaires')
          .replace(queryParameters: params);
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Support both paginated {data: [...]} and plain list
        final list = body is List
            ? body
            : (body['data'] ?? body['items'] ?? []);
        final result = (list as List)
            .map((e) => Questionnaire.fromJson(e as Map<String, dynamic>))
            .toList();
        // Cache locally
        await StorageService.instance.cacheQuestionnaires(result);
        return result;
      }
      throw Exception('Gagal memuat kuesioner (${res.statusCode})');
    } catch (e) {
      debugPrint('getQuestionnaires error: $e');
      return StorageService.instance.getAllLocalQuestionnaires();
    }
  }

  Future<Questionnaire> createQuestionnaire(Questionnaire q) async {
    final res = await http
        .post(
      Uri.parse('$_base/questionnaires'),
      headers: await _headers(),
      body: jsonEncode(q.toJson()),
    )
        .timeout(_timeout);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Questionnaire.fromJson(jsonDecode(res.body));
    }
    _throw(res, 'Gagal menyimpan kuesioner');
  }

  Future<Questionnaire> updateQuestionnaire(String id, Questionnaire q) async {
    final res = await http
        .put(
      Uri.parse('$_base/questionnaires/$id'),
      headers: await _headers(),
      body: jsonEncode(q.toJson()),
    )
        .timeout(_timeout);

    if (res.statusCode == 200) {
      return Questionnaire.fromJson(jsonDecode(res.body));
    }
    _throw(res, 'Gagal memperbarui kuesioner');
  }

  Future<void> deleteQuestionnaire(String id) async {
    final res = await http
        .delete(
      Uri.parse('$_base/questionnaires/$id'),
      headers: await _headers(),
    )
        .timeout(_timeout);
    if (res.statusCode != 200) _throw(res, 'Gagal menghapus kuesioner');
  }

  // ─── Statistics ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStatistics({
    String? dusun,
    String? surveyId,
  }) async {
    try {
      final params = <String, String>{};
      if (dusun != null) params['dusun'] = dusun;
      if (surveyId != null) params['survey_id'] = surveyId;

      final uri = Uri.parse('$_base/statistics')
          .replace(queryParameters: params.isEmpty ? null : params);
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(res.body));
        await StorageService.instance.cacheStats(data);
        return data;
      }
      throw Exception('Gagal memuat statistik');
    } catch (_) {
      return await StorageService.instance.getCachedStats() ?? {};
    }
  }

  // ─── Sync offline data ────────────────────────────────────────────────────
  Future<SyncResult> syncPendingData() async {
    if (!await hasConnection()) {
      return SyncResult(
        success: false,
        message: 'Tidak ada koneksi internet',
      );
    }

    final pending =
    await StorageService.instance.getPendingQuestionnaires();
    int synced = 0;
    final errors = <String>[];

    for (final row in pending) {
      try {
        final q = Questionnaire.fromJson(
            jsonDecode(row['data'] as String));
        final saved = await createQuestionnaire(q);
        await StorageService.instance.markSynced(
          row['id'] as int,
          saved.id ?? '0',
        );
        synced++;
      } catch (e) {
        errors.add('$e');
        debugPrint('Sync error: $e');
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      message: 'Sinkronisasi $synced dari ${pending.length} data',
      synced: synced,
      total: pending.length,
      errors: errors,
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int synced;
  final int total;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    this.synced = 0,
    this.total = 0,
    this.errors = const [],
  });
}