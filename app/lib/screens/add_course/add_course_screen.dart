import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/course_provider.dart';
import '../../widgets/common/common_widgets.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/utils/error_handler.dart';

import '../../models/course.dart';
import 'widgets/course_basic_info_form.dart';
import 'widgets/course_schedule_form.dart';
import 'widgets/course_details_form.dart';

/// Yeni ders ekleme sayfası
class AddCourseScreen extends StatefulWidget {
  final Course? courseToEdit;

  const AddCourseScreen({
    super.key,
    this.courseToEdit,
  });

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _nameController = TextEditingController();
  final _profEmailController = TextEditingController();
  final _profPhoneController = TextEditingController();
  final _profOfficeController = TextEditingController();
  final _officeHoursController = TextEditingController();
  final _assistantController = TextEditingController();

  // Çoklu zaman çizelgesi listesi
  final List<ScheduleItemData> _scheduleItems = [
    ScheduleItemData(
      day: 0, // Monday default
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 9, minute: 50),
    ),
  ];

  int _absenceLimit = 3;
  int _selectedColorIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      final course = widget.courseToEdit!;
      _nameController.text = course.name;
      _profEmailController.text = course.professorEmail ?? '';
      _profPhoneController.text = course.professorPhone ?? '';
      _profOfficeController.text = course.professorOffice ?? '';
      _officeHoursController.text = course.officeHours ?? '';
      _assistantController.text = course.assistantName ?? '';
      _absenceLimit = course.absenceLimit;
      
      // Find color index
      final colorIndex = AppColors.courseColors.indexWhere((c) => c.toARGB32() == course.color.toARGB32());
      _selectedColorIndex = colorIndex != -1 ? colorIndex : 0;

      // Populate schedule
      _scheduleItems.clear();
      for (final day in course.scheduleDays) {
        _scheduleItems.add(ScheduleItemData(
          day: day,
          startTime: course.startTime,
          endTime: course.endTime,
        )..location = course.location
         ..professor = course.professor);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _profEmailController.dispose();
    _profPhoneController.dispose();
    _profOfficeController.dispose();
    _officeHoursController.dispose();
    _assistantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(isDark),
            // İçerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Ders adı
                    CourseBasicInfoForm(
                      nameController: _nameController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    // Program
                    CourseScheduleForm(
                      scheduleItems: _scheduleItems,
                      isDark: isDark,
                      onAddSchedule: () {
                        setState(() {
                          _scheduleItems.add(ScheduleItemData(
                            day: 0,
                            startTime: const TimeOfDay(hour: 10, minute: 0),
                            endTime: const TimeOfDay(hour: 10, minute: 50),
                          ));
                        });
                      },
                      onRemoveSchedule: (index) {
                        setState(() {
                          _scheduleItems.removeAt(index);
                        });
                      },
                      onDayChanged: (index, val) {
                        setState(() {
                          _scheduleItems[index].day = val;
                        });
                      },
                      onStartTimeChanged: (index, val) {
                        setState(() {
                          _scheduleItems[index].startTime = val;
                        });
                      },
                      onEndTimeChanged: (index, val) {
                        setState(() {
                          _scheduleItems[index].endTime = val;
                        });
                      },
                      onLocationChanged: (index, val) {
                        _scheduleItems[index].location = val;
                      },
                      onProfessorChanged: (index, val) {
                        _scheduleItems[index].professor = val;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Devamsızlık limiti
                    CourseDetailsForm(
                      absenceLimit: _absenceLimit,
                      isDark: isDark,
                      selectedColorIndex: _selectedColorIndex,
                      professorEmailController: _profEmailController,
                      professorPhoneController: _profPhoneController,
                      professorOfficeController: _profOfficeController,
                      officeHoursController: _officeHoursController,
                      assistantNameController: _assistantController,
                      onColorSelected: (index) {
                        setState(() => _selectedColorIndex = index);
                      },
                      onIncrementAbsence: () {
                        if (_absenceLimit < 10) {
                          HapticFeedback.lightImpact();
                          setState(() => _absenceLimit++);
                        }
                      },
                      onDecrementAbsence: () {
                        if (_absenceLimit > 1) {
                          HapticFeedback.lightImpact();
                          setState(() => _absenceLimit--);
                        }
                      },
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Kaydet butonu
      bottomNavigationBar: _buildBottomButton(isDark),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
            showShadow: true,
          ),
          Expanded(
            child: Text(
              widget.courseToEdit != null 
                  ? 'Edit Course' // TODO: Localize 'Edit Course'
                  : AppLocalizations.of(context)!.addNewCourse,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 44), // Balance
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: PrimaryButton(
        text: widget.courseToEdit != null 
            ? 'Save Changes' // TODO: Localize
            : AppLocalizations.of(context)!.createCourse,
        icon: Icons.check,
        isLoading: _isLoading,
        onPressed: _saveCourse,
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterCourseName),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_scheduleItems.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseAddClassTime),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Bitiş saati > Başlangıç saati kontrolü (C2 fix)
    for (var item in _scheduleItems) {
      final startMin = item.startTime.hour * 60 + item.startTime.minute;
      final endMin = item.endTime.hour * 60 + item.endTime.minute;
      if (endMin <= startMin) {
        ErrorHandler.handleError(context, 'End time must be after start time.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final color = AppColors.courseColors[_selectedColorIndex];
      final provider = context.read<CourseProvider>();

      if (widget.courseToEdit != null) {
         // Düzenleme modu
         if (_scheduleItems.isNotEmpty) {
           final item = _scheduleItems[0];
           final updatedCourse = widget.courseToEdit!.copyWith(
              name: name,
              location: item.location,
              professor: item.professor,
              color: color,
              scheduleDays: [item.day],
              startTime: item.startTime,
              endTime: item.endTime,
              absenceLimit: _absenceLimit,
              professorEmail: _profEmailController.text.isNotEmpty ? _profEmailController.text : null,
              professorPhone: _profPhoneController.text.isNotEmpty ? _profPhoneController.text : null,
              professorOffice: _profOfficeController.text.isNotEmpty ? _profOfficeController.text : null,
              officeHours: _officeHoursController.text.isNotEmpty ? _officeHoursController.text : null,
              assistantName: _assistantController.text.isNotEmpty ? _assistantController.text : null,
           );
           
           final success = await provider.updateCourse(updatedCourse);
           
           if (!mounted) return;

           if (!success) {
             // Çakışma hatası göster
             ErrorHandler.handleError(context, provider.error ?? 'Failed to update course.');
             return;
           }

           // Ek schedule item'ları yeni ders olarak ekle
           for (int i = 1; i < _scheduleItems.length; i++) {
             if (!mounted) return;
             final newItem = _scheduleItems[i];
             final addSuccess = await provider.addCourse(
                name: name,
                location: newItem.location,
                professor: newItem.professor,
                color: color,
                scheduleDays: [newItem.day],
                startTime: newItem.startTime,
                endTime: newItem.endTime,
                absenceLimit: _absenceLimit,
                professorEmail: _profEmailController.text.isNotEmpty ? _profEmailController.text : null,
                professorPhone: _profPhoneController.text.isNotEmpty ? _profPhoneController.text : null,
                professorOffice: _profOfficeController.text.isNotEmpty ? _profOfficeController.text : null,
                officeHours: _officeHoursController.text.isNotEmpty ? _officeHoursController.text : null,
                assistantName: _assistantController.text.isNotEmpty ? _assistantController.text : null,
             );
             if (!addSuccess && mounted) {
               ErrorHandler.handleError(context, provider.error ?? 'Schedule conflict detected.');
               return;
             }
           }
        }
        
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        Navigator.pop(context);

      } else {
        // Yeni ders oluşturma
        int successCount = 0;
        
        for (var item in _scheduleItems) {
          if (!mounted) return;
          final success = await provider.addCourse(
            name: name,
            location: item.location,
            professor: item.professor,
            color: color,
            scheduleDays: [item.day],
            startTime: item.startTime,
            endTime: item.endTime,
            absenceLimit: _absenceLimit,
            professorEmail: _profEmailController.text.isNotEmpty ? _profEmailController.text : null,
            professorPhone: _profPhoneController.text.isNotEmpty ? _profPhoneController.text : null,
            professorOffice: _profOfficeController.text.isNotEmpty ? _profOfficeController.text : null,
            officeHours: _officeHoursController.text.isNotEmpty ? _officeHoursController.text : null,
            assistantName: _assistantController.text.isNotEmpty ? _assistantController.text : null,
          );
          if (success) {
            successCount++;
          } else {
            // Çakışma veya hata — kullanıcıya göster ve dur
            if (mounted) {
              ErrorHandler.handleError(context, provider.error ?? 'Failed to create course.');
            }
            return;
          }
        }

        if (!mounted) return;

        if (successCount == _scheduleItems.length) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.handleError(context, e, customMessage: 'An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
