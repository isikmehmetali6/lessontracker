import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

/// Orange "you are offline" banner shown at the top of the home
/// screen when the device has no connectivity. Extracted per plan
/// 3.1.4 (home shell).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.youAreOffline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}