import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/moodle/moodle_assignment.dart';
import '../../../providers/moodle_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/moodle_utils.dart';
import '../../../../providers/language_provider.dart';

class MoodleAssignmentsTab extends StatelessWidget {
  const MoodleAssignmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodleProvider>();
    final overdue = provider.overdueAssignments;
    final thisWeek = provider.thisWeekAssignments;
    final upcoming = provider.upcomingAssignments;

    if (provider.allAssignments.isEmpty) {
      return _MoodleEmptyState(
        icon: Icons.assignment_rounded,
        message: 'Bekleyen ödev bulunamadı',
        sub: 'Harika! Hepsi tamamlanmış görünüyor.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdue.isNotEmpty) ...[
          _SectionHeader('Vadesi Geçmiş', overdue.length,
              color: AppColors.red),
          ...overdue.map((a) => _AssignmentCard(assignment: a)),
          const SizedBox(height: 12),
        ],
        if (thisWeek.isNotEmpty) ...[
          _SectionHeader('Bu Hafta', thisWeek.length,
              color: AppColors.blue),
          ...thisWeek.map((a) => _AssignmentCard(assignment: a)),
          const SizedBox(height: 12),
        ],
        if (upcoming.isNotEmpty) ...[
          _SectionHeader('Gelecek', upcoming.length),
          ...upcoming.map((a) => _AssignmentCard(assignment: a)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color? color;
  const _SectionHeader(this.title, this.count, {this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title,
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color ?? theme.colorScheme.onSurface)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: color ?? AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final MoodleAssignment assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.watch<LanguageProvider>().locale.languageCode;
    final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;
    final isToday = assignment.isDueToday;
    final isOverdue = assignment.isOverdue;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (assignment.submitted) {
      statusColor = AppColors.green;
      statusText = 'Teslim Edildi';
      statusIcon = Icons.check_circle_rounded;
    } else if (isOverdue) {
      statusColor = AppColors.red;
      statusText = 'Gecikmiş';
      statusIcon = Icons.warning_rounded;
    } else if (isToday) {
      statusColor = AppColors.orange;
      statusText = 'Bugün son gün!';
      statusIcon = Icons.timer_rounded;
    } else {
      statusColor = AppColors.primary;
      statusText = '$daysLeft gün kaldı';
      statusIcon = Icons.schedule_rounded;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      MoodleUtils.parseMultilang(
                        assignment.name,
                        langCode,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                      MoodleUtils.parseMultilang(
                        assignment.courseName,
                        langCode,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM, HH:mm', 'tr').format(assignment.dueDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(height: 4),
                Text(statusText,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Boş durum widget'ı — diğer sekmelerde de kullanılır
class _MoodleEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? sub;
  const _MoodleEmptyState(
      {required this.icon, required this.message, this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text(message,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outlineVariant)),
          ],
        ],
      ),
    );
  }
}
