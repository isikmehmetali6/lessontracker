import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/course_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/deadlines/add_deadline_dialog.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DeadlineProvider>().loadDeadlines());
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDeadlineDialog(
        onSave: (title, courseId, date, type, addToCalendar) {
          context.read<DeadlineProvider>().createDeadline(
            courseId: courseId,
            title: title,
            date: date,
            type: type,
            addToCalendar: addToCalendar,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<DeadlineProvider, CourseProvider>(
      builder: (context, deadlineProvider, courseProvider, _) {
        final deadlines = deadlineProvider.deadlines;

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.deadlinesHeader,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.deadlinesSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _showAddDialog,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (deadlineProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (deadlines.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 80,
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noUpcomingDeadlines,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showAddDialog,
                        child: Text(AppLocalizations.of(context)!.addFirstDeadline),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final deadline = deadlines[index];
                      // Find course info
                      final course = courseProvider.courses.firstWhere(
                        (c) => c.id == deadline.courseId,
                        orElse: () => courseProvider.courses.isNotEmpty 
                            ? courseProvider.courses.first 
                            : throw Exception('Course not found'), // Should check logic
                      );

                      final daysLeft = deadlineProvider.getDaysLeft(deadline.date);
                      
                      Color statusColor;
                      String statusText;
                      
                      if (daysLeft < 0) {
                        statusColor = Colors.grey;
                        statusText = AppLocalizations.of(context)!.deadlineOverdue;
                      } else if (daysLeft == 0) {
                        statusColor = AppColors.red;
                        statusText = AppLocalizations.of(context)!.deadlineToday;
                      } else if (daysLeft <= 3) {
                        statusColor = AppColors.orange;
                        statusText = AppLocalizations.of(context)!.daysLeft(daysLeft);
                      } else {
                         statusColor = AppColors.green;
                         statusText = AppLocalizations.of(context)!.daysLeft(daysLeft);
                      }

                      return Dismissible(
                        key: ValueKey(deadline.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          context.read<DeadlineProvider>().deleteDeadline(deadline.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border(
                              left: BorderSide(color: statusColor, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: course.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  deadline.date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: course.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deadline.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: deadlines.length,
                  ),
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
          ],
        );
      },
    );
  }
}
