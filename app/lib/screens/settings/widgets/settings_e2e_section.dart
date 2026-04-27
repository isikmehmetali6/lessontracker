import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    if (value) {
      final biometricService = BiometricService();
      final authenticated = await biometricService.authenticate(
        reason: 'Authenticate to enable $_biometricType',
      );

      if (authenticated) {
        await E2EKeyService().setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        if (mounted) {
          _showSnackBar('$_biometricType enabled successfully', Colors.green);
        }
      }
    } else {
      await E2EKeyService().setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
      if (mounted) {
        _showSnackBar('$_biometricType disabled', Colors.orange);
      }
    }
  }

  Future<void> _startMigration() async {
    final migrationService = E2EMigrationService();

    final needsMigration = await migrationService.isMigrationNeeded();
    if (!needsMigration) {
      _showSnackBar('All files are already encrypted', Colors.green);
      return;
    }

    setState(() {
      _isMigrating = true;
      _migrationProgress = 0.0;
      _migrationMessage = 'Starting migration...';
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
          _migrationMessage = 'Migration completed!';
          _migrationProgress = 1.0;
        });
        _showSnackBar('All files encrypted successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMigrating = false;
          _migrationMessage = 'Migration failed';
        });
        _showSnackBar('Migration failed: $e', Colors.red);
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
    return SettingsTile(
      icon: Icons.shield_outlined,
      iconColor: _isE2EEnabled ? AppColors.emerald : AppColors.orange,
      title: 'End-to-End Encryption',
      subtitle: _isE2EEnabled
          ? 'Your files are securely encrypted'
          : 'Enable to encrypt your files',
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
              _isE2EEnabled ? 'Active' : 'Inactive',
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
    return SettingsTile(
      icon: Icons.fingerprint,
      iconColor: AppColors.blue,
      title: _biometricType,
      subtitle: _biometricAvailable
          ? (_isBiometricEnabled ? 'Enabled' : 'Use $_biometricType to unlock')
          : 'Not available on this device',
      isDark: isDark,
      trailing: Switch(
        value: _isBiometricEnabled,
        onChanged: _biometricAvailable ? _toggleBiometric : null,
        activeThumbColor: AppColors.blue,
      ),
    );
  }

  Widget _buildSecurityQuestionsTile(bool isDark) {
    return SettingsTile(
      icon: Icons.help_outline,
      iconColor: AppColors.purple,
      title: 'Security Questions',
      subtitle: 'For password recovery',
      isDark: isDark,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
      onTap: () => _showSecurityQuestionsDialog(isDark),
    );
  }

  Widget _buildMigrationTile(bool isDark) {
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
                      'Encrypt Existing Files',
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
                          : 'Backup your files to cloud',
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
                  child: const Text('Start'),
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
              'End-to-End Encryption',
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
              'Your files are encrypted on your device before being uploaded to the cloud.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.key, 'Encryption Key', 'AES-256-CBC', isDark),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.lock, 'Key Storage', 'Device Keychain', isDark),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.cloud_off,
              'Cloud Access',
              'Only encrypted data',
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
                      'Even app developers cannot access your files',
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
            child: const Text('Close'),
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
    for (final c in _answerControllers) {
      if (c.text.trim().isEmpty) {
        setState(() => _error = 'All answers are required');
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
          const SnackBar(
            content: Text('Security questions saved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to save questions');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Security Questions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up 3 security questions to recover your account if you forget your password.',
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
                        'Security questions are already configured',
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
                  child: const Text(
                    'Reset Questions',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
                      : const Text(
                          'Save Questions',
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
    final selectedIndex = index == 0
        ? _selectedQuestion1
        : (index == 1 ? _selectedQuestion2 : _selectedQuestion3);

    return DropdownButtonFormField<int>(
      initialValue: selectedIndex,
      decoration: InputDecoration(
        labelText: 'Question ${index + 1}',
        filled: true,
        fillColor: widget.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: _SecurityQService.availableQuestions.asMap().entries.map((entry) {
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
    return TextField(
      controller: _answerControllers[index],
      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: 'Your Answer',
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
  static const List<String> availableQuestions = [
    'What is your pet\'s name?',
    'What was your first teacher\'s name?',
    'What city were you born in?',
    'What is your favorite movie?',
    'What was your first phone number?',
    'What is your mother\'s maiden name?',
    'What was the name of your first school?',
    'What is your favorite book?',
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
