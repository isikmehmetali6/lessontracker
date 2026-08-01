import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/moodle/moodle_account.dart';
import '../models/moodle/moodle_announcement.dart';
import '../models/moodle/moodle_assignment.dart';
import '../models/moodle/moodle_calendar_event.dart';
import '../models/moodle/moodle_course.dart';
import '../models/moodle/moodle_grade.dart';
import '../models/moodle/moodle_message.dart';
import '../repositories/moodle_account_repository.dart';
import '../services/moodle/moodle_api_service.dart';
import '../services/moodle/moodle_sync_service.dart';
import '../services/moodle/moodle_token_storage.dart';

/// Bir hesabın senkronizasyon durumu
enum MoodleSyncStatus { idle, syncing, error, success }

/// MoodleProvider — Tüm Moodle state'ini yönetir.
/// Birden fazla hesabı destekler; her hesabın verisi ayrı tutulur.
/// Aggregated getter'lar tüm hesapların verilerini birleştirir.
class MoodleProvider extends ChangeNotifier {
  MoodleProvider({
    MoodleAccountRepository? accountRepo,
    MoodleSyncService? syncService,
    MoodleApiService? api,
    MoodleTokenStorage? tokenStorage,
  })  : _accountRepo = accountRepo ?? MoodleAccountRepository(),
        _syncService = syncService ?? MoodleSyncService(),
        _api = api ?? MoodleApiService(),
        _tokenStorage = tokenStorage ?? MoodleTokenStorage();

  final MoodleAccountRepository _accountRepo;
  final MoodleSyncService _syncService;
  final MoodleApiService _api;
  final MoodleTokenStorage _tokenStorage;
  final _uuid = const Uuid();

  // ==================== STATE ====================

  List<MoodleAccount> _accounts = [];
  final Map<String, MoodleSyncStatus> _syncStatuses = {};
  final Map<String, String?> _syncErrors = {};

  /// Hesap ID → courses
  final Map<String, List<MoodleCourse>> _courses = {};

  /// Hesap ID → assignments
  final Map<String, List<MoodleAssignment>> _assignments = {};

  /// Hesap ID → grades
  final Map<String, List<MoodleGrade>> _grades = {};

  /// Hesap ID → announcements
  final Map<String, List<MoodleAnnouncement>> _announcements = {};

  /// Hesap ID → calendar events
  final Map<String, List<MoodleCalendarEvent>> _events = {};

  /// Hesap ID → messages
  final Map<String, List<MoodleMessage>> _messages = {};

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isSyncing = false;

  // ==================== GETTERS ====================

  List<MoodleAccount> get accounts => List.unmodifiable(_accounts);
  bool get hasAccounts => _accounts.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  MoodleSyncStatus syncStatusFor(String accountId) =>
      _syncStatuses[accountId] ?? MoodleSyncStatus.idle;

  String? syncErrorFor(String accountId) => _syncErrors[accountId];

  bool get isAnySyncing =>
      _syncStatuses.values.any((s) => s == MoodleSyncStatus.syncing);

  // ---- Aggregated getters (tüm hesaplar birleşik) ----

  List<MoodleCourse> get allCourses =>
      _courses.values.expand((list) => list).toList();

  List<MoodleAssignment> get allAssignments =>
      _assignments.values.expand((list) => list).toList();

  /// Vadesi geçmiş ve teslim edilmemiş ödevler
  List<MoodleAssignment> get overdueAssignments =>
      allAssignments.where((a) => a.isOverdue).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  /// Bu hafta bitiş tarihi olan ödevler
  List<MoodleAssignment> get thisWeekAssignments =>
      allAssignments.where((a) => !a.submitted && a.isDueThisWeek).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  /// Gelecek ödevler (bu hafta sonrası)
  List<MoodleAssignment> get upcomingAssignments => allAssignments
      .where((a) =>
          !a.submitted &&
          !a.isOverdue &&
          !a.isDueThisWeek)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<MoodleGrade> get allGrades =>
      _grades.values.expand((list) => list).toList();

  List<MoodleAnnouncement> get allAnnouncements =>
      _announcements.values.expand((list) => list).toList()
        ..sort((a, b) => b.created.compareTo(a.created));

  List<MoodleAnnouncement> get unreadAnnouncements =>
      allAnnouncements.where((a) => !a.isRead).toList();

  int get unreadCount => unreadAnnouncements.length;

  List<MoodleCalendarEvent> get allEvents =>
      _events.values.expand((list) => list).toList()
        ..sort((a, b) => a.timeStart.compareTo(b.timeStart));

  List<MoodleCalendarEvent> get todayEvents =>
      allEvents.where((e) => e.isToday).toList();

  List<MoodleCalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    return allEvents
        .where((e) => e.timeStart.isAfter(now))
        .take(10)
        .toList();
  }

  List<MoodleMessage> get allMessages =>
      _messages.values.expand((list) => list).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  int get unreadMessageCount =>
      allMessages.where((m) => !m.isRead).length;

  // Belirli bir hesabın verilerini getir
  List<MoodleCourse> coursesFor(String accountId) =>
      _courses[accountId] ?? [];
  List<MoodleAssignment> assignmentsFor(String accountId) =>
      _assignments[accountId] ?? [];
  List<MoodleGrade> gradesFor(String accountId) =>
      _grades[accountId] ?? [];
  List<MoodleAnnouncement> announcementsFor(String accountId) =>
      _announcements[accountId] ?? [];
  List<MoodleCalendarEvent> eventsFor(String accountId) =>
      _events[accountId] ?? [];
  List<MoodleMessage> messagesFor(String accountId) =>
      _messages[accountId] ?? [];

  // ==================== BAŞLATMA ====================

  /// Uygulama başlangıcında kayıtlı hesapları yükle ve sync et
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Web'de SQLite kullanılamaz, moodle provider atlanır
      if (kIsWeb) {
        _isInitialized = true;
        return;
      }
      
      _accounts = await _accountRepo.getAll();
      _isInitialized = true;

      // Arka planda tüm hesapları sync et
      if (_accounts.isNotEmpty) {
        _syncAll(silent: true);
      }
    } catch (e) {
      debugPrint('[MoodleProvider] Init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== HESAP YÖNETİMİ ====================

  /// Yeni bir Moodle hesabı ekle.
  /// Döner: (success: bool, error: String?)
  Future<({bool success, String? error})> addAccount({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    // Web'de SQLite kullanılamaz
    if (kIsWeb) {
      return (
        success: false,
        error: 'Moodle entegrasyonu şu an web\'de desteklenmiyor. Mobil uygulamayı kullanın.',
      );
    }

    // Duplikat kontrolü
    final alreadyExists = await _accountRepo.exists(baseUrl, username);
    if (alreadyExists) {
      return (
        success: false,
        error: 'Bu hesap zaten bağlı — $username @ $baseUrl',
      );
    }

    try {
      // 1. Token al
      final token = await _api.login(
        baseUrl: baseUrl,
        username: username,
        password: password,
      );

      // 2. Site bilgisi + kullanıcı profili
      final siteInfo = await _api.getSiteInfo(baseUrl: baseUrl, token: token);
      final fullName = siteInfo['fullname'] as String? ?? username;
      final siteTitle = siteInfo['sitename'] as String? ?? baseUrl;
      final avatarUrl = siteInfo['userpictureurl'] as String?;

      // 3. Hesap oluştur ve kaydet
      final account = MoodleAccount(
        id: _uuid.v4(),
        baseUrl: baseUrl,
        siteTitle: siteTitle,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
        lastSynced: DateTime.now(),
      );

      await _accountRepo.insert(account);
      await _tokenStorage.saveToken(account.id, token);

      _accounts.add(account);
      notifyListeners();

      // 4. İlk sync (arka planda)
      _syncAccount(account.id);

      return (success: true, error: null);
    } on MoodleAuthException catch (e) {
      return (success: false, error: e.message);
    } on MoodleNetworkException catch (e) {
      return (success: false, error: e.message);
    } on MoodleServiceException catch (e) {
      return (success: false, error: e.message);
    } catch (e) {
      debugPrint('[MoodleProvider.addAccount] Unexpected: $e');
      return (success: false, error: 'Beklenmedik bir hata oluştu');
    }
  }

  /// Bir hesabı kaldır — token + cache + DB kaydı silinir
  Future<void> removeAccount(String accountId) async {
    await _accountRepo.delete(accountId); // CASCADE: cache de silinir
    await _tokenStorage.deleteToken(accountId);

    _accounts.removeWhere((a) => a.id == accountId);
    _syncStatuses.remove(accountId);
    _syncErrors.remove(accountId);
    _courses.remove(accountId);
    _assignments.remove(accountId);
    _grades.remove(accountId);
    _announcements.remove(accountId);
    _events.remove(accountId);
    _messages.remove(accountId);

    notifyListeners();
  }

  // ==================== SYNC ====================

  /// Tek bir hesabı senkronize et
  Future<void> syncAccount(String accountId) async {
    await _syncAccount(accountId);
  }

  /// Tüm hesapları senkronize et
  Future<void> syncAll() async {
    await _syncAll();
  }

  Future<void> _syncAll({bool silent = false}) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      for (final account in _accounts) {
        await _syncAccount(account.id, silent: silent);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncAccount(String accountId, {bool silent = false}) async {
    if (_isSyncing) return;
    final account = _accounts.where((a) => a.id == accountId).firstOrNull;
    if (account == null) return;

    _syncStatuses[accountId] = MoodleSyncStatus.syncing;
    _syncErrors[accountId] = null;
    if (!silent) notifyListeners();

    final result = await _syncService.syncAccount(account);

    // Hesap listesindeki lastSynced güncelle
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      _accounts[idx] = result.account;
    }

    // Verileri güncelle
    _courses[accountId] = result.courses;
    _assignments[accountId] = result.assignments;
    _grades[accountId] = result.grades;
    _announcements[accountId] = result.announcements;
    _events[accountId] = result.events;

    if (result.isSuccess) {
      _syncStatuses[accountId] = MoodleSyncStatus.success;
      _syncErrors[accountId] = null;
    } else {
      _syncStatuses[accountId] = result.courses.isNotEmpty
          ? MoodleSyncStatus.success // Cache'den yüklendi
          : MoodleSyncStatus.error;
      _syncErrors[accountId] = result.error;
    }

    notifyListeners();
  }

  // ==================== DUYURU ====================

  /// Duyuruyu okundu olarak işaretle (local state)
  void markAnnouncementRead(int announcementId) {
    for (final accountId in _announcements.keys) {
      final list = _announcements[accountId]!;
      final idx = list.indexWhere((a) => a.id == announcementId);
      if (idx != -1) {
        _announcements[accountId]![idx] = list[idx].markAsRead();
        notifyListeners();
        break;
      }
    }
  }

  // ==================== MESAJLAR ====================

  /// Mesajı okundu olarak işaretle (local state)
  void markMessageRead(int messageId) {
    for (final accountId in _messages.keys) {
      final list = _messages[accountId]!;
      final idx = list.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        _messages[accountId]![idx] = list[idx].markAsRead();
        notifyListeners();
        break;
      }
    }
  }

  // ==================== TEMİZLE ====================

  /// Tüm Moodle verilerini sil (hesap çıkışı veya uygulama sıfırlama)
  Future<void> clearAll() async {
    for (final account in _accounts) {
      await _tokenStorage.deleteToken(account.id);
    }
    _accounts.clear();
    _syncStatuses.clear();
    _syncErrors.clear();
    _courses.clear();
    _assignments.clear();
    _grades.clear();
    _announcements.clear();
    _events.clear();
    _messages.clear();
    _isInitialized = false;
    notifyListeners();
  }
}
