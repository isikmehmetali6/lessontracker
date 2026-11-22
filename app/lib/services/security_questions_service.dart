import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../core/backend/supabase_backend.dart';
import 'cloud_records_service.dart';
import 'e2e_crypto_service.dart';

/// E2E security-questions persistence + question list.
///
/// Extracted from settings_e2e_section.dart per plan 3.1.5.
/// Stores salted PBKDF2-HMAC-SHA256 hashes of the answers in `user_records`
/// (collection `system`, id `security_questions`).
///
/// Kayıt biçimi v2: `{v: 2, questions, salts: [b64], answers: [b64 hash], ...}`.
/// v1 (eski) cevapları yalnızca base64'e çeviriyordu — geri çevrilebilir.
/// [migrateIfNeeded] v1 kaydı v2'ye taşır (FIX_PLAN B11).
class SecurityQuestionsService {
  SecurityQuestionsService._();

  static const String _collection = 'system';
  static const String _docId = 'security_questions';
  static const int _currentVersion = 2;

  @visibleForTesting
  static CloudRecordsService Function() cloudFactory = CloudRecordsService.new;

  @visibleForTesting
  static bool Function() isSignedIn =
      () => SupabaseBackend.currentUser != null;

  static final E2ECryptoService _crypto = E2ECryptoService();

  static List<String> availableQuestions(AppLocalizations l10n) => [
        l10n.securityQ1,
        l10n.securityQ2,
        l10n.securityQ3,
        l10n.securityQ4,
        l10n.securityQ5,
        l10n.securityQ6,
        l10n.securityQ7,
        l10n.securityQ8,
      ];

  static Future<bool> hasSecurityQuestions() async {
    try {
      if (!isSignedIn()) return false;
      return await cloudFactory().get(_collection, _docId) != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setupSecurityQuestions(
    List<int> questionIndices,
    List<String> answers,
  ) async {
    if (!isSignedIn()) {
      throw Exception('No authenticated user');
    }
    await cloudFactory().upsert(_collection, _docId, {
      'v': _currentVersion,
      'questions': questionIndices,
      ...await _hashAll(answers),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'attempts': 0,
    });
  }

  /// Cevapları doğrular. Kayıt yoksa ya da v1 ise `false` (önce
  /// [migrateIfNeeded] çağrılmalı).
  static Future<bool> verifyAnswers(List<String> answers) async {
    if (!isSignedIn()) return false;
    final record = await cloudFactory().get(_collection, _docId);
    if (record == null) return false;
    final data = record.data;
    if ((data['v'] as num?)?.toInt() != _currentVersion) return false;

    final salts = (data['salts'] as List).cast<String>();
    final hashes = (data['answers'] as List).cast<String>();
    if (salts.length != answers.length || hashes.length != answers.length) {
      return false;
    }
    var ok = true;
    for (var i = 0; i < answers.length; i++) {
      final derived = await _crypto.deriveKeyAsync(
        _normalize(answers[i]),
        base64Decode(salts[i]),
      );
      ok &= _constantTimeEquals(base64Encode(derived), hashes[i]);
    }
    return ok;
  }

  /// v1 kaydı (base64 düz cevap) varsa cevapları çözüp v2 hash ile yeniden
  /// yazar. Hata yutulur — bir sonraki açılışta tekrar denenir.
  static Future<void> migrateIfNeeded() async {
    try {
      if (!isSignedIn()) return;
      final cloud = cloudFactory();
      final record = await cloud.get(_collection, _docId);
      if (record == null) return;
      final data = record.data;
      if ((data['v'] as num?)?.toInt() == _currentVersion) return;

      final legacyAnswers = (data['answers'] as List)
          .cast<String>()
          .map((a) => utf8.decode(base64Decode(a)))
          .toList();

      await cloud.upsert(_collection, _docId, {
        ...data,
        'v': _currentVersion,
        ...await _hashAll(legacyAnswers),
        'migratedAt': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('SecurityQuestionsService: migrated to v2');
    } catch (e) {
      debugPrint('SecurityQuestionsService: migration failed - $e');
    }
  }

  static Future<void> deleteSecurityQuestions() async {
    if (!isSignedIn()) return;
    await cloudFactory().delete(_collection, _docId);
  }

  static String _normalize(String answer) => answer.trim().toLowerCase();

  static Future<Map<String, dynamic>> _hashAll(List<String> answers) async {
    final salts = <String>[];
    final hashes = <String>[];
    for (final answer in answers) {
      final salt = _crypto.generateSalt();
      final derived = await _crypto.deriveKeyAsync(_normalize(answer), salt);
      salts.add(base64Encode(salt));
      hashes.add(base64Encode(derived));
    }
    return {'salts': salts, 'answers': hashes};
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
