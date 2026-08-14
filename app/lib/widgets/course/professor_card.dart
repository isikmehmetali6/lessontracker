import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';

class ProfessorCard extends StatelessWidget {
  final Course course;
  final bool isDark;

  const ProfessorCard({
    super.key,
    required this.course,
    required this.isDark,
  });

  bool get _hasAnyInfo =>
      course.professorEmail != null ||
      course.professorPhone != null ||
      course.professorOffice != null ||
      course.officeHours != null ||
      course.assistantName != null;

  @override
  Widget build(BuildContext context) {
    if (course.professor == null && !_hasAnyInfo) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.professor ?? 'Professor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (course.assistantName != null)
                      Text(
                        'TA: ${course.assistantName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_hasAnyInfo) ...[
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 8),
          ],
          if (course.professorEmail != null)
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: course.professorEmail!,
              color: Colors.blue,
              onTap: () => _copyToClipboard(context, course.professorEmail!, 'Email copied'),
            ),
          if (course.professorPhone != null)
            _buildInfoRow(
              context,
              icon: Icons.phone_outlined,
              label: course.professorPhone!,
              color: AppColors.emerald,
              onTap: () => _copyToClipboard(context, course.professorPhone!, 'Phone copied'),
            ),
          if (course.professorOffice != null)
            _buildInfoRow(
              context,
              icon: Icons.meeting_room_outlined,
              label: course.professorOffice!,
              color: AppColors.orange,
            ),
          if (course.officeHours != null)
            _buildInfoRow(
              context,
              icon: Icons.schedule,
              label: course.officeHours!,
              color: AppColors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (onTap != null)
            Icon(Icons.copy, size: 16, color: isDark ? Colors.white38 : Colors.black26),
        ],
      ),
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        label: 'Copy $label',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: row,
        ),
      );
    }
    return row;
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
