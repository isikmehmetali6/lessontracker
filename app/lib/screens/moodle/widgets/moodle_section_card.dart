import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/moodle_utils.dart';
import '../../../models/moodle/moodle_course_content.dart';
import '../../../providers/language_provider.dart';
import 'moodle_module_tile.dart';

/// A single Moodle course content section: its title plus its modules.
class MoodleSectionCard extends StatelessWidget {
  final MoodleCourseSection section;
  final String token;
  final String courseName;
  final ThemeData theme;

  const MoodleSectionCard({
    super.key,
    required this.section,
    required this.token,
    required this.courseName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            MoodleUtils.parseMultilang(
              section.name,
              langCode,
            ),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        // Modüller
        ...section.modules.map((module) => MoodleModuleTile(
              module: module,
              token: token,
              courseName: courseName,
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
