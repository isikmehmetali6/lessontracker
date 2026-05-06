import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/e2e_key_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/e2e_migration_service.dart';
import 'settings_shared.dart';

class SettingsE2ESection extends StatefulWidget {
  const SettingsE2ESection({super.key});

  @override
  State<SettingsE2ESection> createState() => _SettingsE2ESectionState();
}

class _SettingsE2ESectionState extends State<SettingsE2ESection> {
  bool _isE2EEnabled = false;
  bool _isBiometricEnabled = false;
  bool _biometricAvailable = false;
  String _biometricType = 'Biometric';
  bool _isLoading = true;
  bool _isMigrating = false;
  double _migrationProgress = 0.0;
  String _migrationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final keyService = E2EKeyService();
    final biometricService = BiometricService();

    final e2eEnabled = await keyService.isE2EEnabled();
    final biometricEnabled = await keyService.isBiometricEnabled();
    final biometricAvailable = await biometricService.isAvailable();
    final biometricType = await biometricService.getBiometricTypeName();

    if (mounted) {
      setState(() {
        _isE2EEnabled = e2eEnabled;
        _isBiometricEnabled = biometricEnabled;
        _biometricAvailable = biometricAvailable;
        _biometricType = biometricType;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (value) {
      final biometricService = BiometricService();
      final authenticated = await biometricService.authenticate(
        reason: l10n.biometricAuthReason(_biometricType),
      );

      if (authenticated) {
        await E2EKeyService().setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          _showSnackBar(l10n.biometricEnabled(_biometricType), Colors.green);
        }
      }
    } else {
      await E2EKeyService().setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
      if (mounted) {
        _showSnackBar(l10n.biometricDisabled(_biometricType), Colors.orange);
      }
    }
  }

  Future<void> _startMigration() async {
    final l10n = AppLocalizations.of(context)!;
    final migrationService = E2EMigrationService();

    final needsMigration = await migrationService.isMigrationNeeded();
    if (!needsMigration) {
      _showSnackBar(l10n.alreadyEncrypted, Colors.green);
      return;
    }

    setState(() {
      _isMigrating = true;
      _migrationProgress = 0.0;
      _migrationMessage = l10n.startingMigration;
    });

    migrationService.onProgress = (message, progress) {
      if (mounted) {
        setState(() {
          _migrationMessage = message;
          _migrationProgress = progress;
        });
      }
    };

    try {
      await migrationService.migrateLegacyFiles();
      if (mounted) {
        setState(() {
          _isMigrating = false;
          _migrationMessage = l10n.migrationComplete;
          _migrationProgress = 1.0;
        });
        _showSnackBar(l10n.allEncrypted, Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMigrating = false;
          _migrationMessage = l10n.migrationFailed;
        });
        _showSnackBar(l10n.migrationFailedDetail('$e'), Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.emerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Security & Encryption',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildE2EStatusTile(isDark),
            SettingsDivider(isDark: isDark),
            if (_isE2EEnabled) ...[
              _buildBiometricTile(isDark),
              SettingsDivider(isDark: isDark),
              _buildSecurityQuestionsTile(isDark),
              SettingsDivider(isDark: isDark),
              _buildMigrationTile(isDark),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildE2EStatusTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.shield_outlined,
      iconColor: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
      title: l10n.e2eEncryption,
      subtitle: _isE2EEnabled
          ? l10n.e2eDescription
          : l10n.e2eDescription,
      isDark: isDark,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isE2EEnabled
              ? AppColors.emerald.withValues(alpha: 0.15)
              : AppColors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isE2EEnabled ? Icons.check_circle : Icons.warning_amber,
              size: 16,
              color: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              _isE2EEnabled ? l10n.active : l10n.inactive,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
              ),
            ),
          ],
        ),
      ),
      onTap: () => _showE2EInfoDialog(isDark),
    );
  }

  Widget _buildBiometricTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.fingerprint,
      iconColor: AppColors.blue,
      title: _biometricType,
      subtitle: _biometricAvailable
          ? (_isBiometricEnabled ? l10n.enabled : l10n.faceIdSubtitle)
          : l10n.notAvailableOnDevice,
      isDark: isDark,
      trailing: Switch(
        value: _isBiometricEnabled,
        onChanged: _biometricAvailable ? _toggleBiometric : null,
        activeThumbColor: AppColors.blue,
      ),
    );
  }

  Widget _buildSecurityQuestionsTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      icon: Icons.help_outline,
      iconColor: AppColors.purple,
      title: l10n.securityQuestions,
      subtitle: l10n.setUpSecurityQuestions,
      isDark: isDark,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
      onTap: () => _showSecurityQuestionsDialog(isDark),
    );
  }

  Widget _buildMigrationTile(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.encryptExistingFiles,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _migrationMessage.isNotEmpty
                          ? _migrationMessage
                          : l10n.backupFilesToCloud,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isMigrating)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: _migrationProgress > 0 ? _migrationProgress : null,
                    strokeWidth: 2,
                    color: AppColors.blue,
                  ),
                )
              else
                TextButton(
                  onPressed: _startMigration,
                  child: Text(l10n.start),
                ),
            ],
          ),
          if (_isMigrating && _migrationProgress > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _migrationProgress,
                backgroundColor: AppColors.blue.withValues(alpha: 0.2),
                color: AppColors.blue,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(_migrationProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showE2EInfoDialog(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.emerald),
            const SizedBox(width: 8),
            Text(
              l10n.e2eEncryption,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1F36),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.e2eDescription,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.key, l10n.encryptionKey, l10n.aes256, isDark),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.lock, l10n.keyStorage, l10n.deviceKeychain, isDark),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.cloud_off,
              l10n.cloudAccess,
              l10n.encryptedOnly,
              isDark,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.emerald,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.evenDevCantAccess,
                      style: TextStyle(fontSize: 12, color: AppColors.emerald),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showSecurityQuestionsDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SecurityQuestionsSheet(isDark: isDark),
    );
  }
}

class _SecurityQuestionsSheet extends StatefulWidget {
  final bool isDark;

  const _SecurityQuestionsSheet({required this.isDark});

  @override
  State<_SecurityQuestionsSheet> createState() =>
      _SecurityQuestionsSheetState();
}

class _SecurityQuestionsSheetState extends State<_SecurityQuestionsSheet> {
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  int _selectedQuestion1 = 0;
  int _selectedQuestion2 = 1;
  int _selectedQuestion3 = 2;
  bool _isSaving = false;
  bool _hasQuestions = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final hasQuestions = await _SecurityQService.hasSecurityQuestions();
      setState(() {
        _hasQuestions = hasQuestions;
      });
    } catch (e) {
      debugPrint('Error loading security questions status: $e');
    }
  }

  @override
  void dispose() {
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestions() async {
    final loc = AppLocalizations.of(context)!;
    for (final c in _answerControllers) {
      if (c.text.trim().isEmpty) {
        setState(() => _error = loc.allAnswersRequired);
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _SecurityQService.setupSecurityQuestions([
        _selectedQuestion1,
        _selectedQuestion2,
        _selectedQuestion3,
      ], _answerControllers.map((c) => c.text.trim()).toList());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.questionsSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = loc.questionsSaveFailed);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              loc.securityQuestions,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.setUpSecurityQuestions,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            if (_hasQuestions) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.emerald),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.questionsAlreadyConfigured,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1F36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _SecurityQService.deleteSecurityQuestions();
                    setState(() => _hasQuestions = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    loc.resetQuestions,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else ...[
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildQuestionDropdown(0),
              const SizedBox(height: 12),
              _buildAnswerField(0),
              const SizedBox(height: 16),
              _buildQuestionDropdown(1),
              const SizedBox(height: 12),
              _buildAnswerField(1),
              const SizedBox(height: 16),
              _buildQuestionDropdown(2),
              const SizedBox(height: 12),
              _buildAnswerField(2),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          loc.saveQuestions,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDropdown(int index) {
    final loc = AppLocalizations.of(context)!;
    final selectedIndex = index == 0
        ? _selectedQuestion1
        : (index == 1 ? _selectedQuestion2 : _selectedQuestion3);

    return DropdownButtonFormField<int>(
      initialValue: selectedIndex,
      decoration: InputDecoration(
        labelText: loc.questionLabel(index + 1),
        filled: true,
        fillColor: widget.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: _SecurityQService.availableQuestions(loc).asMap().entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          if (index == 0) {
            _selectedQuestion1 = value;
          } else if (index == 1) {
            _selectedQuestion2 = value;
          } else {
            _selectedQuestion3 = value;
          }
        });
      },
    );
  }

  Widget _buildAnswerField(int index) {
    final loc = AppLocalizations.of(context)!;
    return TextField(
      controller: _answerControllers[index],
      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: loc.yourAnswer,
        filled: true,
        fillColor: widget.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SecurityQService {
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

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('system')
          .doc('security_questions')
          .get();
      return doc.exists && doc.data() != null;
    } catch (e) {
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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('system')
        .doc('security_questions')
        .set({
          'questions': questionIndices,
          'answers': hashedAnswers,
          'createdAt': FieldValue.serverTimestamp(),
          'attempts': 0,
        });
  }

  static Future<void> deleteSecurityQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('system')
        .doc('security_questions')
        .delete();
  }

  static String _hashAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    return base64Encode(bytes);
  }
}
