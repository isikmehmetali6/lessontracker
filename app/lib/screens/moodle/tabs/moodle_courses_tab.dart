import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/moodle_provider.dart';
import '../../../../models/moodle/moodle_course.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/moodle_utils.dart';
import '../../../../providers/language_provider.dart';
import '../moodle_course_detail_screen.dart';

class MoodleCoursesTab extends StatelessWidget {
  const MoodleCoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodleProvider>();
    final courses = provider.allCourses;

    if (courses.isEmpty) {
      return _emptyState(context);
    }

    // Hesap bazlı gruplama
    final grouped = <String, List<MoodleCourse>>{};
    for (final course in courses) {
      grouped.putIfAbsent(course.accountId, () => []).add(course);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final accountId in grouped.keys) ...[
          _AccountHeader(
            accountId: accountId,
            provider: provider,
          ),
          const SizedBox(height: 8),
          ...grouped[accountId]!.map((c) => _CourseCard(
                course: c,
                assignmentCount: provider
                    .assignmentsFor(accountId)
                    .where((a) => a.courseId == c.id && !a.submitted)
                    .length,
              )),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 56, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text('Ders bulunamadı',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Moodle hesabınız senkronize ediliyor...',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outlineVariant)),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  final String accountId;
  final MoodleProvider provider;
  const _AccountHeader({required this.accountId, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final account =
        provider.accounts.where((a) => a.id == accountId).firstOrNull;
    if (account == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (account.avatarUrl != null)
          CircleAvatar(
            radius: 14,
            backgroundImage: CachedNetworkImageProvider(account.avatarUrl!),
          )
        else
          CircleAvatar(
            radius: 14,
            child: Text(account.fullName[0],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  MoodleUtils.parseMultilang(
                    account.siteTitle,
                    langCode,
                  ),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                'Son sync: ${DateFormat('d MMM HH:mm', 'tr').format(account.lastSynced)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final MoodleCourse course;
  final int assignmentCount;
  const _CourseCard({required this.course, required this.assignmentCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => MoodleCourseDetailScreen(course: course),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Ders görseli (varsa)
          if (course.courseImageUrl != null)
            SizedBox(
              height: 80,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: course.courseImageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) =>
                    Container(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                placeholder: (_, _) =>
                    Container(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              MoodleUtils.parseMultilang(
                                course.shortName,
                                langCode,
                              ),
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                              MoodleUtils.parseMultilang(
                                course.fullName,
                                langCode,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (assignmentCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$assignmentCount ödev',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.red,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // İlerleme çubuğu
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: course.progress / 100,
                          minHeight: 6,
                          backgroundColor:
                              isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${course.progress}%',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
