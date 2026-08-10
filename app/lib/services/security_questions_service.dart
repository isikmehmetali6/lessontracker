import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// E2E security-questions persistence + question list.
///
/// Extracted from settings_e2e_section.dart per plan 3.1.5.
/// Stores hashed answers under `users/{uid}/system/security_questions`.
class SecurityQuestionsService {
  SecurityQuestionsService._();

  static DocumentReference<Map<String, dynamic>> _questionsDoc(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('system')
        .doc('security_questions');
  }

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final doc = await _questionsDoc(user.uid).get();
      return doc.exists && doc.data() != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setupSecurityQuestions(
    List<int> questionIndices,
    List<String> answers,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final hashedAnswers = answers.map((a) => _hashAnswer(a)).toList();

    await _questionsDoc(user.uid).set({
      'questions': questionIndices,
      'answers': hashedAnswers,
      'createdAt': FieldValue.serverTimestamp(),
      'attempts': 0,
    });
  }

  static Future<void> deleteSecurityQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _questionsDoc(user.uid).delete();
  }

  static String _hashAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    return base64Encode(bytes);
  }
}