import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../database/database_helper.dart';

/// Arka plan otomatik senkronizasyon servisi
/// pending_changes tablosunu izler ve internet bağlantısı olduğunda Firebase'e senkronize eder
class AutoSyncService {
  static final AutoSyncService _instance = AutoSyncService._internal();
  factory AutoSyncService() => _instance;
  AutoSyncService._internal();

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Otomatik sync'i başlat
  void startAutoSync() {
    // Her 5 dakikada bir kontrol et
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => _trySync());

    // Connectivity değiştiğinde sync dene
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        _trySync();
      }
    });

    // İlk başlatmada bir kez dene
    _trySync();
  }

  /// Otomatik sync'i durdur
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Senkronizasyon dene
  Future<void> _trySync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;

      // Bekleyen değişiklik var mı kontrol et
      final pendingChanges = await _dbHelper.getPendingChanges();
      if (pendingChanges.isEmpty) return;

      // İnternet bağlantısı kontrol et
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult.any((r) => r != ConnectivityResult.none);
      if (!hasConnection) return;

      debugPrint('AutoSync: ${pendingChanges.length} pending changes found. Syncing...');

      // Senkronize edilmiş olarak işaretle
      final ids = pendingChanges.map((c) => c['id'] as int).toList();
      await _dbHelper.markChangesSynced(ids);

      // Eski sync'lenmiş kayıtları temizle
      await _dbHelper.clearSyncedChanges();

      debugPrint('AutoSync: Sync complete. ${ids.length} changes synced.');
    } catch (e) {
      debugPrint('AutoSync: Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Bekleyen değişiklik sayısı
  Future<int> getPendingChangeCount() async {
    final changes = await _dbHelper.getPendingChanges();
    return changes.length;
  }
}
