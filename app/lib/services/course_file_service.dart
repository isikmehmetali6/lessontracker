import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/course_file.dart';
import 'file_service.dart';

/// External file/URL opener for CourseFile entries.
///
/// Extracted from CourseProvider per plan 2.1d ('url_launcher/open_filex
/// dışarı'). UI calls a single [open] method; the implementation decides
/// whether to launch a URL or open a local file.
class CourseFileService {
  CourseFileService({FileService? fileService})
      : _fileService = fileService ?? FileService();

  final FileService _fileService;

  /// Open an external link (`https://...`) in the default browser.
  /// Returns true if the URL was parsed and handed to the platform.
  static bool openLinkUrl(String url) {
    var urlStr = url;
    if (!urlStr.startsWith('http://') && !urlStr.startsWith('https://')) {
      urlStr = 'https://$urlStr';
    }
    final uri = Uri.tryParse(urlStr);
    if (uri == null) return false;
    launchUrl(uri, mode: LaunchMode.externalApplication);
    return true;
  }

  /// Open a local file with the system default app.
  /// Returns true if the path was resolved and the open call was issued.
  static Future<bool> openLocalFile(String path) async {
    final resolved = await FileService().resolveFilePath(path);
    if (resolved == null) return false;
    await OpenFilex.open(resolved);
    return true;
  }

  /// Open [file] in the appropriate way. Returns an error message if
  /// the file/link could not be opened, or null on success.
  Future<String?> open(CourseFile file) async {
    if (file.url != null && file.url!.isNotEmpty) {
      return openLinkUrl(file.url!)
          ? null
          : 'Could not open link: ${file.name}';
    }
    final resolved = await _fileService.resolveFilePath(file.path);
    if (resolved == null) return 'File not found: ${file.name}';
    await OpenFilex.open(resolved);
    return null;
  }
}