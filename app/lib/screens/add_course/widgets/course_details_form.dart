import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class CourseDetailsForm extends StatelessWidget {
  final int absenceLimit;
  final VoidCallback onIncrementAbsence;
  final VoidCallback onDecrementAbsence;
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;
  final bool isDark;
  final TextEditingController? professorEmailController;
  final TextEditingController? professorPhoneController;
  final TextEditingController? professorOfficeController;
  final TextEditingController? officeHoursController;
  final TextEditingController? assistantNameController;

  const CourseDetailsForm({
    super.key,
    required this.absenceLimit,
    required this.onIncrementAbsence,
    required this.onDecrementAbsence,
    required this.selectedColorIndex,
    required this.onColorSelected,
    this.professorEmailController,
    this.professorPhoneController,
    this.professorOfficeController,
    this.officeHoursController,
    this.assistantNameController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAbsenceSection(context),
        const SizedBox(height: 24),
        _buildColorPicker(context),
        if (professorEmailController != null) ...[
          const SizedBox(height: 24),
          _buildProfessorSection(context),
        ],
      ],
    );
  }

  Widget _buildAbsenceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy,
              color: AppColors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.absenceLimit,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.maxAllowedPerSemester,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onTap: onDecrementAbsence,
                  isPrimary: false,
                  isDark: isDark,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$absenceLimit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add,
                  onTap: onIncrementAbsence,
                  isPrimary: true,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessorSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                child: const Icon(Icons.person, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizations.of(context)!.professorDetailsSection,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(context, professorEmailController!, AppLocalizations.of(context)!.emailLabel, Icons.email_outlined),
          const SizedBox(height: 12),
          _buildTextField(context, professorPhoneController!, AppLocalizations.of(context)!.phoneLabel, Icons.phone_outlined),
          const SizedBox(height: 12),
          _buildTextField(context, professorOfficeController!, AppLocalizations.of(context)!.officeRoom, Icons.meeting_room_outlined),
          const SizedBox(height: 12),
          _buildTextField(context, officeHoursController!, AppLocalizations.of(context)!.officeHoursLabel, Icons.schedule),
          const SizedBox(height: 12),
          _buildTextField(context, assistantNameController!, AppLocalizations.of(context)!.teachingAssistant, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.cardColor,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(AppColors.courseColors.length, (index) {
              final color = AppColors.courseColors[index];
              final isSelected = selectedColorIndex == index;
  
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onColorSelected(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: color, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                              width: 2,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDark;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary 
              ? AppColors.primary 
              : (isDark ? AppColors.surfaceDark : Colors.white),
          shape: BoxShape.circle,
          boxShadow: [
            if (!isPrimary)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary 
              ? Colors.white 
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      ),
    );
  }
}
