import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_form_widgets.dart';

/// "Şifremi unuttum": e-posta adresine Supabase şifre sıfırlama linki
/// gönderir. Link uygulamayı açar (lessontracker://auth-callback) ve
/// AuthWrapper yeni şifre ekranını ([ResetPasswordScreen]) gösterir.
///
/// Önceki sürümdeki "kod doğrula" ve "güvenlik soruları" adımları hiçbir şey
/// doğrulamıyordu (yalnızca bekleyip ekranı kapatıyordu); kaldırıldı.
class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _sentTo;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final ok = await context.read<AuthProvider>().resetPassword(email);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (ok) {
        _sentTo = email;
      } else {
        _error = l10n.failedToSendReset;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final sent = _sentTo != null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                AuthScreenHeader(
                  title: sent ? l10n.resetLinkSentTitle : l10n.resetPassword,
                  subtitle: sent
                      ? l10n.resetLinkSentDesc(_sentTo!)
                      : l10n.recoveryEmailDesc,
                  isDark: isDark,
                ),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  AuthErrorBox(message: _error!),
                  const SizedBox(height: 16),
                ],
                if (!sent) ...[
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.emailHint,
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.emailIsRequired;
                      }
                      if (!AuthProvider.isValidEmail(v.trim())) {
                        return l10n.enterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    text: l10n.sendResetLink,
                    onPressed: _sendResetLink,
                    isLoading: _isLoading,
                  ),
                ] else ...[
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 72,
                    color: AppColors.indigoAccent,
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    text: l10n.sendResetLink,
                    onPressed: _sendResetLink,
                    isLoading: _isLoading,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.continueAction),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
