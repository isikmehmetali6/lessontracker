import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/course.dart';
import '../../../../widgets/common/common_widgets.dart';

class CourseDetailAppBar extends StatelessWidget {
  final Course course;
  final VoidCallback onOptionsTap;
  final VoidCallback? onAddDeadlineTap;

  const CourseDetailAppBar({
    super.key,
    required this.course,
    required this.onOptionsTap,
    this.onAddDeadlineTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
            showShadow: false,
          ),
          Expanded(
            child: Hero(
              tag: 'course_${course.id}',
              child: Text(
                course.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          if (onAddDeadlineTap != null)
            CircleIconButton(
              icon: Icons.event_available,
              onTap: onAddDeadlineTap!,
              showShadow: false,
            ),
          CircleIconButton(
            icon: Icons.more_horiz,
            onTap: onOptionsTap,
            showShadow: false,
          ),
        ],
      ),
    );
  }
}
