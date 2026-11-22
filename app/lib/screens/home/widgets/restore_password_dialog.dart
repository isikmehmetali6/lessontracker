import 'package:flutter/material.dart';
import 'package:lesson_tracker/core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Bulut verisi uçtan uca şifreli ve E2E anahtarı bu cihazda yoksa hesap
/// parolasını ister. Vazgeçilirse `null` döner.
Future<String?> showRestorePasswordDialog({
  required BuildContext context,
  bool showWrongPassword = false,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _RestorePasswordDialog(
      showWrongPassword: showWrongPassword,
    ),
  );
}

class _RestorePasswordDialog extends StatefulWidget {
  const _RestorePasswordDialog({required this.showWrongPassword});

  final bool showWrongPassword;

  @override
  State<_RestorePasswordDialog> createState() => _RestorePasswordDialogState();
}

class _RestorePasswordDialogState extends State<_RestorePasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text;
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.restorePasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.restorePasswordDescription),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            autofocus: true,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              errorText:
                  widget.showWrongPassword ? l10n.restorePasswordWrong : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.continueAction),
        ),
      ],
    );
  }
}
