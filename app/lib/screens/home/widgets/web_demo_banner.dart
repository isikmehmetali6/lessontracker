import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Web'de veriler yalnızca bellekte tutulur (sqflite web'de yok) ve sayfa
/// yenilenince kaybolur. Kullanıcıyı bu konuda açıkça uyarır
/// (UI_FIX_PLAN U15). Yalnızca `kIsWeb` iken gösterilir.
class WebDemoBanner extends StatelessWidget {
  const WebDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.blueGrey.shade700,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.webDemoBanner,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
