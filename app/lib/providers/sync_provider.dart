import 'package:flutter/material.dart';
import '../services/record_crypto.dart';
import '../services/sync_service.dart';
import 'course_provider.dart';
import 'note_provider.dart';
import 'deadline_provider.dart';

/// Restore çağrısının sonucu (UI'ın kullanıcıya ne göstereceği).
enum RestoreOutcome { success, needsPassword, failed }

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
  int _skippedRecords = 0;
  bool _keyMissing = false;

  bool get isSyncing => _isSyncing;
  double get progress => _progress;
  String? get statusMessage => _statusMessage;
  String? get error => _error;

  /// Son restore'da bu cihazda çözülemediği için atlanan kayıt sayısı.
  int get skippedRecords => _skippedRecords;

  /// Son backup E2E anahtarı olmadığı için yapılamadı.
  bool get keyMissing => _keyMissing;

  /// Restore sonrası diğer provider'ları yeniden yüklemek için callback'ler.
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
    _keyMissing = false;
    _progress = 0.0;
    notifyListeners();

    try {
      await _syncService.backupData();
      _statusMessage = 'Backup completed successfully!';
      _progress = 1.0;
    } on RecordCryptoKeyMissing catch (e) {
      _keyMissing = true;
      _error = e.toString();
      _statusMessage = 'Backup failed.';
    } catch (e) {
      _error = e.toString();
      _statusMessage = 'Backup failed.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<RestoreOutcome> restore() async {
    if (_isSyncing) return RestoreOutcome.failed;
    _isSyncing = true;
    _error = null;
    _skippedRecords = 0;
    _progress = 0.0;
    notifyListeners();

    try {
      final result = await _syncService.restoreData();
      _skippedRecords = result.skippedRecords;
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
      return RestoreOutcome.success;
    } on RestoreNeedsPassword {
      _statusMessage = null;
      return RestoreOutcome.needsPassword;
    } catch (e) {
      _error = e.toString();
      _statusMessage = 'Restore failed.';
      return RestoreOutcome.failed;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
