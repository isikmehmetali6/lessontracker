import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'sync_service.dart';
import '../database/database_helper.dart';

class AutoSyncService {
  static final AutoSyncService _instance = AutoSyncService._internal();
  factory AutoSyncService() => _instance;
  AutoSyncService._internal();

  Timer? _debounceTimer;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  int _pendingChangesCount = 0;

  void init() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        final pendingCount = _getPendingChangesCountSync();
        if (pendingCount > 0) {
          debugPrint(
            'AutoSync: Internet restored, processing $pendingCount pending changes...',
          );
          _performBackup();
        }
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

      if (FirebaseAuth.instance.currentUser == null) return;

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

      final pendingCount = await _getPendingChangesCount();
      if (pendingCount > 0) {
        debugPrint(
          'AutoSync: Processing $pendingCount pending changes before backup...',
        );
        await _processPendingChanges();
      }

      debugPrint('AutoSync: Triggering backup after data change...');
      await SyncService().backupData();
      await _clearPendingChanges();
      debugPrint('AutoSync: Backup complete.');
    } catch (e) {
      debugPrint('AutoSync: Error during backup: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> recordPendingChange(
    String tableName,
    String recordId,
    String operation,
  ) async {
    try {
      final db = await DatabaseHelper().database;
      await db.insert('pending_changes', {
        'tableName': tableName,
        'recordId': recordId,
        'operation': operation,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
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
      final count = Sqflite.firstIntValue(result) ?? 0;
      _pendingChangesCount = count;
      return count;
    } catch (e) {
      return 0;
    }
  }

  int _getPendingChangesCountSync() {
    return _pendingChangesCount;
  }

  Future<void> _processPendingChanges() async {
    try {
      final db = await DatabaseHelper().database;
      final pending = await db.query(
        'pending_changes',
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'timestamp ASC',
      );

      for (final change in pending) {
        await db.update(
          'pending_changes',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [change['id']],
        );
      }
    } catch (e) {
      debugPrint('AutoSync: Error processing pending changes: $e');
    }
  }

  Future<void> _clearPendingChanges() async {
    try {
      final db = await DatabaseHelper().database;
      await db.delete('pending_changes', where: 'synced = ?', whereArgs: [1]);
    } catch (e) {
      debugPrint('AutoSync: Error clearing pending changes: $e');
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
