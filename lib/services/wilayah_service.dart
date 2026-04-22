// lib/services/wilayah_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wilayah.dart';
import '../utils/app_theme.dart';
import 'storage_service.dart';

class WilayahService {
  static WilayahService? _instance;
  static WilayahService get instance => _instance ??= WilayahService._();
  WilayahService._();

  static const Duration _timeout = Duration(seconds: 15);

  String get _base => AppConstants.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Fetch helpers ────────────────────────────────────────────────────────

  Future<List<WilayahItem>> fetchProvinsi() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/wilayah/provinsi'), headers: await _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return _parse(res.body);
      }
    } catch (e) {
      debugPrint('fetchProvinsi error: $e');
    }
    return [];
  }

  Future<List<WilayahItem>> fetchKabupaten(String kodeProvinsi) async {
    try {
      final uri = Uri.parse('$_base/wilayah/kabupaten')
          .replace(queryParameters: {'kode_provinsi': kodeProvinsi});
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) return _parse(res.body);
    } catch (e) {
      debugPrint('fetchKabupaten error: $e');
    }
    return [];
  }

  Future<List<WilayahItem>> fetchKecamatan(String kodeKabupaten) async {
    try {
      final uri = Uri.parse('$_base/wilayah/kecamatan')
          .replace(queryParameters: {'kode_kabupaten': kodeKabupaten});
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) return _parse(res.body);
    } catch (e) {
      debugPrint('fetchKecamatan error: $e');
    }
    return [];
  }

  Future<List<WilayahItem>> fetchDesa(String kodeKecamatan) async {
    try {
      final uri = Uri.parse('$_base/wilayah/desa')
          .replace(queryParameters: {'kode_kecamatan': kodeKecamatan});
      final res = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);
      if (res.statusCode == 200) return _parse(res.body);
    } catch (e) {
      debugPrint('fetchDesa error: $e');
    }
    return [];
  }

  List<WilayahItem> _parse(String body) {
    final list = jsonDecode(body) as List;
    return list.map((e) => WilayahItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}