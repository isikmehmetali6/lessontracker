import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/moodle/moodle_course.dart';
import '../../models/moodle/moodle_course_content.dart';
import '../../providers/moodle_provider.dart';
import 'widgets/moodle_section_card.dart';
import '../../services/moodle/moodle_api_service.dart';
import '../../services/moodle/moodle_token_storage.dart';
import '../../core/utils/moodle_utils.dart';
import '../../providers/language_provider.dart';

/// Bir Moodle dersinin içeriğini gösteren detay ekranı.
/// PDF'ler, slaytlar, dosyalar, URL'ler — hepsi burada.
class MoodleCourseDetailScreen extends StatefulWidget {
  final MoodleCourse course;

  const MoodleCourseDetailScreen({super.key, required this.course});

  @override
  State<MoodleCourseDetailScreen> createState() =>
      _MoodleCourseDetailScreenState();
}

class _MoodleCourseDetailScreenState extends State<MoodleCourseDetailScreen> {
  final MoodleApiService _api = MoodleApiService();
  final MoodleTokenStorage _tokenStorage = MoodleTokenStorage();

  List<MoodleCourseSection> _sections = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _tokenStorage.getToken(widget.course.accountId);
      if (token == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.moodleTokenNotFound;
          _isLoading = false;
        });
        return;
      }

      _token = token;

      if (!mounted) return;
      if (!context.mounted) return;
      final account = context
          .read<MoodleProvider>()
          .accounts
          .where((a) => a.id == widget.course.accountId)
          .firstOrNull;

      if (account == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.moodleAccountNotFound;
          _isLoading = false;
        });
        return;
      }

      final sections = await _api.getCourseContents(
        baseUrl: account.baseUrl,
        token: token,
        courseId: widget.course.id,
      );

      setState(() {
        _sections = sections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.moodleContentError(e.toString());
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          MoodleUtils.parseMultilang(
            widget.course.shortName,
            langCode,
          ),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.moodleContentLoading),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)!.moodleTryAgain),
                onPressed: _loadContents,
              ),
            ],
          ),
        ),
      );
    }

    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 56, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.moodleContentNotFound,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Boş bölümleri filtrele
    final nonEmptySections =
        _sections.where((s) => s.modules.isNotEmpty).toList();

    return RefreshIndicator(
      onRefresh: _loadContents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nonEmptySections.length,
        itemBuilder: (context, index) {
          final section = nonEmptySections[index];
          return MoodleSectionCard(
            section: section,
            token: _token!,
            courseName: widget.course.shortName,
            theme: theme,
          );
        },
      ),
    );
  }
}
