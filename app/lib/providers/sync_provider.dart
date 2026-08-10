import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import 'course_provider.dart';
import 'note_provider.dart';
import 'deadline_provider.dart';

/// B2 fix: restore() sonrası tüm data provider'ları yeniden yükleyen sync provider.
/// [reloadCallbacks] restore sonrası çağrılarak kurs, not ve deadline
/// verilerinin UI'a yansımasını sağlar.
class SyncProvider extends ChangeNotifier {
  SyncProvider({SyncService? syncService})
      : _syncService = syncService ?? SyncService() {
    _syncService.onProgress = (msg, val) {
      _statusMessage = msg;
      _progress = val;
      notifyListeners();
    };
  }

  final SyncService _syncService;

  bool _isSyncing = false;
  double _progress = 0.0;
  String? _statusMessage;
  String? _error;

  bool get isSyncing => _isSyncing;
  double get progress => _progress;
  String? get statusMessage => _statusMessage;
  String? get error => _error;

  /// Restore sonrası diğer provider'ları yeniden yüklemek için callback'ler.
  /// main.dart'ta veya settings ekranında set edilir.
  List<Future<void> Function()> reloadCallbacks = [];

  void registerProviders(CourseProvider courseProvider, NoteProvider noteProvider, DeadlineProvider deadlineProvider) {
    reloadCallbacks = [
      () => courseProvider.loadCourses(),
      () => noteProvider.loadNotes(),
      () => deadlineProvider.loadDeadlines(),
    ];
  }

  Future<void> backup() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _error = null;
    _progress = 0.0;
    notifyListeners();

    try {
      await _syncService.backupData();
      _statusMessage = 'Backup completed successfully!';
      _progress = 1.0;
    } catch (e) {
      _error = e.toString();
      _statusMessage = 'Backup failed.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _error = null;
    _progress = 0.0;
    notifyListeners();

    try {
      await _syncService.restoreData();
      _statusMessage = 'Restore completed successfully!';
      _progress = 1.0;
      
      // B2 fix: Restore sonrası tüm provider'ları yeniden yükle
      for (final reload in reloadCallbacks) {
        try {
          await reload();
        } catch (e) {
          debugPrint('Provider reload error: $e');
        }
      }
    } catch (e) {
      _error = e.toString();
      _statusMessage = 'Restore failed.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
