import 'dart:convert';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../core/backend/supabase_backend.dart';
import 'cloud_records_service.dart';

/// E2E security-questions persistence + question list.
///
/// Extracted from settings_e2e_section.dart per plan 3.1.5.
/// Stores hashed answers in `user_records` (collection `system`,
/// id `security_questions`).
class SecurityQuestionsService {
  SecurityQuestionsService._();

  static const String _collection = 'system';
  static const String _docId = 'security_questions';

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
      if (SupabaseBackend.currentUser == null) return false;
      return await CloudRecordsService().get(_collection, _docId) != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setupSecurityQuestions(
    List<int> questionIndices,
    List<String> answers,
  ) async {
    if (SupabaseBackend.currentUser == null) {
      throw Exception('No authenticated user');
    }

    final hashedAnswers = answers.map((a) => _hashAnswer(a)).toList();

    await CloudRecordsService().upsert(_collection, _docId, {
      'questions': questionIndices,
      'answers': hashedAnswers,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'attempts': 0,
    });
  }

  static Future<void> deleteSecurityQuestions() async {
    if (SupabaseBackend.currentUser == null) return;
    await CloudRecordsService().delete(_collection, _docId);
  }

  static String _hashAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    return base64Encode(bytes);
  }
}