import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class VeliConsentScreen extends StatefulWidget {
  final VoidCallback onConsentGiven;
  final VoidCallback onCancelled;

  const VeliConsentScreen({
    super.key,
    required this.onConsentGiven,
    required this.onCancelled,
  });

  @override
  State<VeliConsentScreen> createState() => _VeliConsentScreenState();
}

class _VeliConsentScreenState extends State<VeliConsentScreen> {
  final _veliEmailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _consentChecked = false;
  String? _verificationCode;
  bool _showVerificationStep = false;
  String? _pendingVeliEmail;

  @override
  void dispose() {
    _veliEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _showVerificationStep
                            ? Icons.verified
                            : Icons.family_restroom,
                        color: _showVerificationStep
                            ? AppColors.emerald
                            : AppColors.blue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _showVerificationStep
                          ? l10n.veliEmailVerification
                          : l10n.veliConsentTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showVerificationStep
                          ? l10n.veliEnterCode
                          : l10n.veliConsentDesc,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_showVerificationStep) ...[
                      _buildVerificationSection(isDark),
                    ] else ...[
                      _buildEmailSection(isDark),
                      const SizedBox(height: 20),
                      _buildConsentCheckbox(isDark),
                      const SizedBox(height: 24),
                      _buildSecurityInfo(isDark),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_showVerificationStep) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          disabledForegroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.veliVerifyAndApprove,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resendCode,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.veliResendCode,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _showVerificationStep = false;
                                  _verificationCode = null;
                                  _pendingVeliEmail = null;
                                });
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.veliChangeEmail,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canSubmit && !_isLoading
                            ? _handleSubmit
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          disabledForegroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.veliSendCode,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading ? null : widget.onCancelled,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.veliCancel,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSection(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.veliEmailLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _veliEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: l10n.veliEmailHint,
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(fontSize: 13, color: AppColors.red)),
          ],
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => setState(() => _consentChecked = !_consentChecked),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _consentChecked
              ? AppColors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _consentChecked
                ? AppColors.blue
                : (isDark ? Colors.white24 : Colors.black26),
            width: _consentChecked ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _consentChecked,
              onChanged: (v) => setState(() => _consentChecked = v ?? false),
              activeColor: AppColors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.veliConfirmCheck,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.veliKvkkCheck,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.emerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.veliInfoText,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mark_email_read, color: AppColors.emerald, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.veliCodeSent(_pendingVeliEmail ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _veliEmailController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '------',
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                letterSpacing: 8,
              ),
              counterText: '',
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.emerald,
                  width: 2,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(fontSize: 13, color: AppColors.red)),
          ],
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _veliEmailController.text.trim().isNotEmpty && _consentChecked;

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _veliEmailController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() => _error = l10n.veliValidEmail);
      return;
    }

    if (!_consentChecked) {
      setState(() => _error = l10n.veliCheckConsent);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    HapticFeedback.mediumImpact();

    final generatedCode = _generateVerificationCode();
    _verificationCode = generatedCode;
    _pendingVeliEmail = email;

    await _sendVerificationEmail(email, generatedCode);

    setState(() {
      _isLoading = false;
      _showVerificationStep = true;
      _consentChecked = false;
    });
  }

  String _generateVerificationCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }

  Future<void> _sendVerificationEmail(String email, String code) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('sendVeliVerificationEmail');

      final result = await callable.call({
        'email': email,
        'code': code,
        'veliName': 'Veli',
      });

      if (result.data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final pendingApproval = jsonEncode({
          'veli_email': email,
          'code': code,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'expires': DateTime.now()
              .add(const Duration(minutes: 30))
              .millisecondsSinceEpoch,
        });
        await prefs.setString('pending_veli_approval', pendingApproval);
      }
    } catch (e) {
      debugPrint('Cloud function error: $e');
      final prefs = await SharedPreferences.getInstance();
      final pendingApproval = jsonEncode({
        'veli_email': email,
        'code': code,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expires': DateTime.now()
            .add(const Duration(minutes: 30))
            .millisecondsSinceEpoch,
      });
      await prefs.setString('pending_veli_approval', pendingApproval);
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    final enteredCode = _veliEmailController.text.trim();

    if (enteredCode.length != 6) {
      setState(() => _error = l10n.veliCodeRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final pendingData = prefs.getString('pending_veli_approval');

    if (pendingData == null) {
      setState(() {
        _isLoading = false;
        _error = l10n.veliSessionNotFound;
      });
      return;
    }

    final pending = jsonDecode(pendingData) as Map<String, dynamic>;
    final storedCode = pending['code'] as String;
    final expires = pending['expires'] as int;

    if (DateTime.now().millisecondsSinceEpoch > expires) {
      setState(() {
        _isLoading = false;
        _error = l10n.veliCodeExpired;
      });
      prefs.remove('pending_veli_approval');
      return;
    }

    if (enteredCode != storedCode) {
      setState(() {
        _isLoading = false;
        _error = l10n.veliWrongCode;
      });
      return;
    }

    final veliEmail = pending['veli_email'] as String;
    final consentTimestamp = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(
      'veli_approval',
      jsonEncode({
        'veli_email': veliEmail,
        'consent_timestamp': consentTimestamp,
        ' consented': true,
      }),
    );
    await prefs.remove('pending_veli_approval');

    HapticFeedback.heavyImpact();

    if (mounted) {
      widget.onConsentGiven();
    }
  }

  Future<void> _resendCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pendingVeliEmail == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final generatedCode = _generateVerificationCode();
    _verificationCode = generatedCode;

    await _sendVerificationEmail(_pendingVeliEmail!, generatedCode);

    setState(() {
      _isLoading = false;
      _veliEmailController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.veliCodeSent(_pendingVeliEmail ?? ''),
          ),
          backgroundColor: AppColors.emerald,
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
