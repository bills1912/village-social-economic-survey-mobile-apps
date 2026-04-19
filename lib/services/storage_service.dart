// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/questionnaire.dart';
import '../models/user.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;
  Database? _db;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _db = await _initDb();
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'suka_makmur_v2.db');
    return openDatabase(path, version: 2, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE questionnaires (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id TEXT,
          data      TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE draft_questionnaires (
          id           INTEGER PRIMARY KEY AUTOINCREMENT,
          data         TEXT NOT NULL,
          nama_petugas TEXT,
          dusun        TEXT,
          r_102        TEXT,
          updated_at   TEXT NOT NULL
        )
      ''');
    }, onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) {
        // Migrate server_id column dari INTEGER ke TEXT (MongoDB ObjectId)
        await db.execute('ALTER TABLE questionnaires ADD COLUMN server_id_text TEXT');
        await db.execute('UPDATE questionnaires SET server_id_text = CAST(server_id AS TEXT)');
      }
    });
  }

  // ─── Token ────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async =>
      _prefs?.setString('token', token);
  Future<String?> getToken() async => _prefs?.getString('token');
  Future<void> removeToken() async => _prefs?.remove('token');

  // ─── User ─────────────────────────────────────────────────────────────────
  Future<void> saveUser(User user) async =>
      _prefs?.setString('user', jsonEncode(user.toJson()));
  Future<User?> getUser() async {
    final s = _prefs?.getString('user');
    return s != null ? User.fromJson(jsonDecode(s)) : null;
  }
  Future<void> removeUser() async => _prefs?.remove('user');

  // ─── Questionnaires (offline queue) ─────────────────────────────────────
  Future<int> saveQuestionnaire(Questionnaire q, {bool isSynced = false}) async {
    return await _db!.insert('questionnaires', {
      'server_id': q.id,                        // String (ObjectId) atau null
      'data': jsonEncode(q.toJson()),
      'is_synced': isSynced ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingQuestionnaires() async {
    return await _db!.query('questionnaires', where: 'is_synced = 0');
  }

  Future<List<Questionnaire>> getAllLocalQuestionnaires() async {
    final rows = await _db!.query('questionnaires', orderBy: 'created_at DESC');
    return rows
        .map((r) => Questionnaire.fromJson(
        jsonDecode(r['data'] as String)))
        .toList();
  }

  Future<void> markSynced(int localId, String serverId) async {
    await _db!.update(
      'questionnaires',
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> cacheQuestionnaires(List<Questionnaire> list) async {
    _prefs?.setString(
      'questionnaires_cache',
      jsonEncode(list.map((q) => q.toJson()).toList()),
    );
  }

  // ─── Drafts ───────────────────────────────────────────────────────────────
  Future<int> saveDraft(Questionnaire q) async {
    final existing = await _db!.query('draft_questionnaires',
        where: 'r_102 = ? AND dusun = ?', whereArgs: [q.r102, q.dusun]);
    if (existing.isNotEmpty) {
      await _db!.update(
        'draft_questionnaires',
        {
          'data': jsonEncode(q.toJson()),
          'nama_petugas': q.namaPetugas,
          'dusun': q.dusun,
          'r_102': q.r102,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
      return existing.first['id'] as int;
    }
    return await _db!.insert('draft_questionnaires', {
      'data': jsonEncode(q.toJson()),
      'nama_petugas': q.namaPetugas,
      'dusun': q.dusun,
      'r_102': q.r102,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllDrafts() async {
    return await _db!.query('draft_questionnaires', orderBy: 'updated_at DESC');
  }

  Future<Questionnaire?> getDraft(int id) async {
    final rows = await _db!.query('draft_questionnaires',
        where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Questionnaire.fromJson(jsonDecode(rows.first['data'] as String));
  }

  Future<void> deleteDraft(int id) async {
    await _db!.delete('draft_questionnaires', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Cache ────────────────────────────────────────────────────────────────
  Future<void> cacheStats(Map<String, dynamic> stats) async =>
      _prefs?.setString('stats_cache', jsonEncode(stats));
  Future<Map<String, dynamic>?> getCachedStats() async {
    final s = _prefs?.getString('stats_cache');
    return s != null ? Map<String, dynamic>.from(jsonDecode(s)) : null;
  }

  Future<void> cacheSurveys(List<Map<String, dynamic>> surveys) async =>
      _prefs?.setString('surveys_cache', jsonEncode(surveys));
  Future<List<Map<String, dynamic>>> getCachedSurveys() async {
    final s = _prefs?.getString('surveys_cache');
    if (s == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(s));
  }

  Future<int> getPendingCount() async {
    final result = await _db!.rawQuery(
        'SELECT COUNT(*) as count FROM questionnaires WHERE is_synced = 0');
    return result.first['count'] as int;
  }
}