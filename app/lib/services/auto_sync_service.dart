import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../core/backend/supabase_backend.dart';
import '../core/database/database_helper.dart';
import 'sync_service.dart';

/// Veri değişikliklerinden sonra otomatik yedek + çevrimdışı silme kuyruğu.
///
/// Silmeler `pending_changes` tablosuna (operation = 'delete', payload =
/// bulut dosya yolları) yazılır; bağlantı varken önce bu kuyruk buluta
/// uygulanır, ardından tam backup alınır. Bir kuyruk satırı yalnızca bulut
/// silmesi başarılı olduğunda kaldırılır (bkz. docs/FIX_PLAN_2026-11-23.md K3).
class AutoSyncService {
  static final AutoSyncService _instance = AutoSyncService._internal();
  factory AutoSyncService() => _instance;
  AutoSyncService._internal();

  Timer? _debounceTimer;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void init() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (!hasConnection) return;
      final pendingCount = await _getPendingChangesCount();
      if (pendingCount > 0) {
        debugPrint(
          'AutoSync: Internet restored, processing $pendingCount pending changes...',
        );
        _performBackup();
      }
    });
  }

  void triggerBackup() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), _performBackup);
  }

  Future<void> _performBackup() async {
    if (_isSyncing) return;
    try {
      _isSyncing = true;
      if (SupabaseBackend.currentUser == null) return;

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult.any(
        (r) => r != ConnectivityResult.none,
      );
      if (!hasConnection) {
        debugPrint(
          'AutoSync: No internet connection, pending changes saved locally.',
        );
        return;
      }

      final syncService = SyncService();
      await processPendingDeletes(syncService);

      if (!await syncService.isCloudBackupEnabled()) return;

      debugPrint('AutoSync: Triggering backup after data change...');
      await syncService.backupData();
      debugPrint('AutoSync: Backup complete.');
    } catch (e) {
      debugPrint('AutoSync: Error during backup: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Silmeyi kuyruğa ekler. [payload] buluttaki ilgili dosya yollarını
  /// (`cloudPath`, `thumbnailCloudPath`) taşır; yerel satır silindikten
  /// sonra bu bilgiye başka yerden ulaşılamaz.
  Future<void> recordPendingChange(
    String tableName,
    String recordId,
    String operation, {
    Map<String, dynamic>? payload,
  }) async {
    try {
      final db = await DatabaseHelper().database;
      await db.insert('pending_changes', {
        'tableName': tableName,
        'recordId': recordId,
        'operation': operation,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
        'payload': payload == null ? null : jsonEncode(payload),
      });
    } catch (e) {
      debugPrint('AutoSync: Error recording pending change: $e');
    }
  }

  Future<int> _getPendingChangesCount() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM pending_changes WHERE synced = 0',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Kuyruktaki silmeleri buluta uygular. Başarılı satırlar kuyruktan
  /// kaldırılır; başarısız olanlar bir sonraki denemeye kalır.
  @visibleForTesting
  Future<int> processPendingDeletes(SyncService syncService) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'pending_changes',
      where: 'synced = ? AND operation = ?',
      whereArgs: [0, 'delete'],
      orderBy: 'id ASC',
    );

    var applied = 0;
    for (final row in rows) {
      final rowId = row['id'] as int;
      final rawPayload = row['payload'] as String?;
      Map<String, dynamic>? payload;
      if (rawPayload != null) {
        try {
          payload = jsonDecode(rawPayload) as Map<String, dynamic>;
        } catch (_) {
          payload = null;
        }
      }
      try {
        await syncService.applyCloudDelete(
          row['tableName'] as String,
          row['recordId'] as String,
          payload,
        );
        await db.delete(
          'pending_changes',
          where: 'id = ?',
          whereArgs: [rowId],
        );
        applied++;
      } catch (e) {
        debugPrint(
          'AutoSync: Pending delete ${row['tableName']}/${row['recordId']} failed: $e',
        );
      }
    }
    if (applied > 0) {
      debugPrint('AutoSync: Applied $applied pending cloud deletes.');
    }
    return applied;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
