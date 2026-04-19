// lib/providers/questionnaire_provider.dart
import 'package:flutter/foundation.dart';
import '../models/questionnaire.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class QuestionnaireProvider with ChangeNotifier {
  List<Questionnaire> _questionnaires = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _filterDusun;
  int _pendingCount = 0;
  Map<String, dynamic> _stats = {};

  List<Questionnaire> get questionnaires => _questionnaires;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get filterDusun => _filterDusun;
  int get pendingCount => _pendingCount;
  Map<String, dynamic> get stats => _stats;

  // surveyId sekarang String? (MongoDB ObjectId)
  Future<void> loadQuestionnaires({String? dusun, String? surveyId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _questionnaires = await ApiService.instance.getQuestionnaires(
        dusun: dusun,
        surveyId: surveyId,
      );
      _pendingCount = await StorageService.instance.getPendingCount();
    } catch (e) {
      _error = e.toString();
      _questionnaires = await StorageService.instance.getAllLocalQuestionnaires();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats({String? dusun, String? surveyId}) async {
    try {
      _stats = await ApiService.instance.getStatistics(
        dusun: dusun,
        surveyId: surveyId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error load stats: $e');
    }
  }

  Future<bool> saveQuestionnaire(Questionnaire q,
      {bool offlineFirst = false}) async {
    // Jika ada id → route ke updateQuestionnaire
    if (q.id != null && q.id!.isNotEmpty) {
      return updateQuestionnaire(q, offlineFirst: offlineFirst);
    }
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final hasConn = await ApiService.instance.hasConnection();
      if (!hasConn || offlineFirst) {
        await StorageService.instance.saveQuestionnaire(q, isSynced: false);
        _pendingCount = await StorageService.instance.getPendingCount();
        // Refresh list dari local storage agar langsung muncul
        _questionnaires = await StorageService.instance.getAllLocalQuestionnaires();
        _isSaving = false;
        notifyListeners();
        return true;
      }
      final saved = await ApiService.instance.createQuestionnaire(q);
      await StorageService.instance.saveQuestionnaire(saved, isSynced: true);
      await loadQuestionnaires();
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback ke offline
      try {
        await StorageService.instance.saveQuestionnaire(q, isSynced: false);
        _pendingCount = await StorageService.instance.getPendingCount();
        _questionnaires = await StorageService.instance.getAllLocalQuestionnaires();
        _isSaving = false;
        notifyListeners();
        return true;
      } catch (e2) {
        _error = e2.toString();
        _isSaving = false;
        notifyListeners();
        return false;
      }
    }
  }

  /// Update kuesioner yang sudah ada (edit)
  Future<bool> updateQuestionnaire(Questionnaire q,
      {bool offlineFirst = false}) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final hasConn = await ApiService.instance.hasConnection();
      if (!hasConn || offlineFirst) {
        await StorageService.instance.saveQuestionnaire(q, isSynced: false);
        _pendingCount = await StorageService.instance.getPendingCount();
        // Update item di list in-memory agar langsung tampil
        final idx = _questionnaires.indexWhere((x) => x.id == q.id);
        if (idx != -1) _questionnaires[idx] = q;
        else _questionnaires.insert(0, q);
        _isSaving = false;
        notifyListeners();
        return true;
      }
      // FIX: pass q.id! explicitly as the first argument
      final updated = await ApiService.instance.updateQuestionnaire(q.id!, q);
      await StorageService.instance.saveQuestionnaire(updated, isSynced: true);
      // Update in-memory
      final idx = _questionnaires.indexWhere((x) => x.id == updated.id);
      if (idx != -1) _questionnaires[idx] = updated;
      else await loadQuestionnaires();
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback offline
      try {
        await StorageService.instance.saveQuestionnaire(q, isSynced: false);
        _pendingCount = await StorageService.instance.getPendingCount();
        final idx = _questionnaires.indexWhere((x) => x.id == q.id);
        if (idx != -1) _questionnaires[idx] = q;
        _isSaving = false;
        notifyListeners();
        return true;
      } catch (e2) {
        _error = e2.toString();
        _isSaving = false;
        notifyListeners();
        return false;
      }
    }
  }

  Future<void> syncPending() async {
    final result = await ApiService.instance.syncPendingData();
    _pendingCount = await StorageService.instance.getPendingCount();
    if (result.synced > 0) await loadQuestionnaires();
    notifyListeners();
  }

  void setFilterDusun(String? dusun) {
    _filterDusun = dusun;
    notifyListeners();
  }

  List<Questionnaire> get filteredQuestionnaires {
    if (_filterDusun == null || _filterDusun!.isEmpty) return _questionnaires;
    return _questionnaires.where((q) => q.dusun == _filterDusun).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  StatistikDesa computeLocalStats() {
    final all = _questionnaires;
    int totalPenduduk = 0, totalL = 0, totalP = 0;
    final perDusun = <String, int>{};
    final perPendidikan = <String, int>{};
    final perPetugas = <String, int>{};

    for (final q in all) {
      perDusun[q.dusunLabel] = (perDusun[q.dusunLabel] ?? 0) + 1;
      perPetugas[q.namaPetugas] = (perPetugas[q.namaPetugas] ?? 0) + 1;
      for (final a in q.r200) {
        totalPenduduk++;
        if (a.r205 == '1') totalL++;
        if (a.r205 == '2') totalP++;
        if (a.r212 != null) {
          final label = a.pendidikanLabel;
          perPendidikan[label] = (perPendidikan[label] ?? 0) + 1;
        }
      }
    }

    return StatistikDesa(
      totalKK: all.length,
      totalPenduduk: totalPenduduk,
      totalLakiLaki: totalL,
      totalPerempuan: totalP,
      perDusun: perDusun,
      perPendidikan: perPendidikan,
      perPekerjaan: {},
      perPetugas: perPetugas,
    );
  }
}