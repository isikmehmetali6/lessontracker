import 'package:url_launcher/url_launcher.dart';

/// Opens an external URL in the default browser via `url_launcher`.
/// Extracted from `_MoodleCourseDetailScreenState._handleTap` per
/// plan 3.1.3.
Future<bool> openExternalUrl(String urlStr) async {
  if (urlStr.isEmpty) return false;
  final uri = Uri.tryParse(urlStr);
  if (uri == null) return false;
  if (!await canLaunchUrl(uri)) return false;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
  return true;
}