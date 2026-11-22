import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_form_widgets.dart';

/// Şifre sıfırlama linkiyle uygulama açıldığında gösterilir
/// ([AuthProvider.isPasswordRecovery]). Kullanıcı yeni şifresini belirler.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();

    final result = await auth.completePasswordRecovery(_passwordController.text);
    if (!result.success) return; // hata AuthProvider.error ile gösterilir

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.e2eKeyPreserved
              ? l10n.passwordChanged
              : l10n.passwordChangedE2EWarning,
        ),
        backgroundColor:
            result.e2eKeyPreserved ? AppColors.green : AppColors.orange,
        duration: Duration(seconds: result.e2eKeyPreserved ? 3 : 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: auth.isLoading
                ? null
                : () => context.read<AuthProvider>().cancelPasswordRecovery(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  AuthScreenHeader(
                    title: l10n.setNewPasswordTitle,
                    subtitle: l10n.setNewPasswordDesc,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  if (auth.error != null) ...[
                    AuthErrorBox(message: auth.error!),
                    const SizedBox(height: 16),
                  ],
                  AuthTextField(
                    controller: _passwordController,
                    label: l10n.newPassword,
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    isPassword: true,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => (v == null || v.length < 6)
                        ? l10n.passwordTooShort
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _confirmController,
                    label: l10n.confirmPassword,
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    isPassword: true,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => v != _passwordController.text
                        ? l10n.passwordsDoNotMatch
                        : null,
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    text: l10n.save,
                    onPressed: _save,
                    isLoading: auth.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
