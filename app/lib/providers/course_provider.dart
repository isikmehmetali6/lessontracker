import 'package:flutter/material.dart';
import '../repositories/course_repository.dart';
import '../repositories/absence_repository.dart';
import '../repositories/grade_repository.dart';
import '../repositories/file_repository.dart';
import '../models/course.dart';
import '../models/grade.dart';
import '../core/theme/app_colors.dart';
import '../core/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/course_file.dart';

/// Ders yönetimi provider
class CourseProvider extends ChangeNotifier {
  final CourseRepository _courseRepo = CourseRepository();
  final AbsenceRepository _absenceRepo = AbsenceRepository();
  final GradeRepository _gradeRepo = GradeRepository();
  final FileRepository _fileRepo = FileRepository();
  final _uuid = const Uuid();

  List<Course> _courses = [];
  List<Course> _todayCourses = [];
  List<Course> _priorityCourses = [];
  bool _isLoading = false;
  String? _error;
  String? _warning;

  // Getters
  List<Course> get courses => _courses;
  List<Course> get todayCourses => _todayCourses;
  List<Course> get priorityCourses => _priorityCourses;
  bool get isLoading => _isLoading;

  String? get error => _error;
  String? get warning => _warning;

  /// Uyarıyı temizle
  void clearWarning() {
    _warning = null;
    notifyListeners();
  }
  
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  int _reminderMinutes = 15;
  int get reminderMinutes => _reminderMinutes;

  void setReminderMinutes(int minutes) {
    _reminderMinutes = minutes;
    // Reschedule all with new time
    if (_notificationsEnabled) {
      _rescheduleAllNotifications();
    }
    notifyListeners();
  }

  void toggleNotifications(bool unabled) {
    _notificationsEnabled = unabled;
    if (_notificationsEnabled) {
      _rescheduleAllNotifications();
    } else {
      NotificationService().cancelAllNotifications();
    }
    notifyListeners();
  }

  Future<void> _rescheduleAllNotifications() async {
    await NotificationService().cancelAllNotifications();
    for (var course in _courses) {
      await _scheduleForCourse(course);
    }
  }

  Future<void> _scheduleForCourse(Course course) async {
    if (!_notificationsEnabled) return;
    
    // We want to notify BEFORE the class.
    // Logic: If class is at 10:00 and reminder is 15 mins, notify at 09:45.
    
    for (var day in course.scheduleDays) {
      // Calculate notification time
      // This is basic calculation assuming same day.
      // NotificationService usually takes hour/minute.
      
      int notifyHour = course.startTime.hour;
      int notifyMinute = course.startTime.minute - _reminderMinutes;
      
      // Handle underflow (e.g. 10:00 - 15m = 09:45)
      while (notifyMinute < 0) {
        notifyMinute += 60;
        notifyHour -= 1;
      }
      // Handle day wrap backward? (e.g. 00:10 - 20m = 23:50 prev day)
      // NotificationService typically schedules repeating weekly.
      // Complex logic needed if wrapping to previous day. 
      // For MVP, if hour < 0, we might skip or handle if service supports "dayOffset".
      // Assuming simple case for now or just clamp to 00:00 if needed, but wrapping is better.
      // If hour < 0, it means previous day. 
      int notifyDay = day;
      if (notifyHour < 0) {
        notifyHour += 24;
        notifyDay = (day - 1) < 0 ? 6 : (day - 1);
      }

      await NotificationService().scheduleClassNotification(
        courseId: course.id,
        courseName: course.name,
        location: course.location,
        dayOfWeek: notifyDay,
        hour: notifyHour,
        minute: notifyMinute,
      );
    }
  }

  Future<void> _cancelForCourse(Course course) async {
    for (var day in course.scheduleDays) {
      await NotificationService().cancelClassNotification(course.id, day);
    }
  }

  // ==================== ÇAKIŞMA KONTROLÜ ====================

  /// Ders programı çakışma kontrolü
  /// Verilen gün ve saat aralığında çakışan ders var mı kontrol eder.
  /// [excludeId] düzenleme sırasında mevcut dersi hariç tutmak için kullanılır.
  Course? hasScheduleConflict({
    required List<int> days,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? excludeId,
  }) {
    final newStartMin = startTime.hour * 60 + startTime.minute;
    final newEndMin = endTime.hour * 60 + endTime.minute;

    for (final course in _courses) {
      // Düzenlenen dersi atla
      if (excludeId != null && course.id == excludeId) continue;

      // Ortak gün var mı?
      final commonDays = days.where((d) => course.scheduleDays.contains(d)).toList();
      if (commonDays.isEmpty) continue;

      // Saat çakışması kontrolü
      final existingStartMin = course.startTime.hour * 60 + course.startTime.minute;
      final existingEndMin = course.endTime.hour * 60 + course.endTime.minute;

      // Overlap: newStart < existingEnd && newEnd > existingStart
      if (newStartMin < existingEndMin && newEndMin > existingStartMin) {
        return course; // Çakışan dersi döndür
      }
    }
    return null; // Çakışma yok
  }

  /// Sıradaki (veya şu anki) dersi bul
  Course? findUpcomingCourse() {
    if (_courses.isEmpty) return null;
    
    final now = DateTime.now();
    final todayWeekday = now.weekday - 1; // 0=Mon
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // 1. Check classes for today that haven't ended yet
    final todayCourses = _courses.where((c) => c.scheduleDays.contains(todayWeekday)).toList();
    todayCourses.sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });
    
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    for (var course in todayCourses) {
      final endMinutes = course.endTime.hour * 60 + course.endTime.minute;
      if (endMinutes > currentMinutes) {
        return course; // Return the first one that ends in the future (could be ongoing or slightly upcoming)
      }
    }
    
    // 2. If no more classes today, find first class tomorrow? 
    // Usually widgets show "No upcoming classes" or "See you tomorrow", but let's return null for now 
    // or maybe the first class of tomorrow if we want to be smart.
    return null;
  }

  /// Dersleri yükle
  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activeCourses = await _courseRepo.getActiveCourses();
      _courses = activeCourses;
      
      // Populate absences
      for (int i = 0; i < _courses.length; i++) {
        final absences = await _absenceRepo.getAbsencesByCourse(_courses[i].id);
        _courses[i] = _courses[i].copyWith(absenceDates: absences, currentAbsences: absences.length);
      }

      // Re-filter for today and priority based on updated course data
      _todayCourses = _courses.where((c) => c.isScheduledToday).toList();
      _priorityCourses = _courses.where((c) => c.hasUpcomingExam || c.isBehind).toList();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ders ekle
  Future<bool> addCourse({
    required String name,
    String? subtitle,
    String? professor,
    String? location,
    required Color color,
    required List<int> scheduleDays,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    int absenceLimit = 3,
    int credits = 3,
    DateTime? nextExamDate,
  }) async {
    _error = null;
    try {
      // Çakışma kontrolü
      final conflict = hasScheduleConflict(
        days: scheduleDays,
        startTime: startTime,
        endTime: endTime,
      );
      if (conflict != null) {
        _error = 'Schedule conflict with "${conflict.name}"';
        notifyListeners();
        return false;
      }

      final course = Course(
        id: _uuid.v4(),
        name: name,
        subtitle: subtitle,
        professor: professor,
        location: location,
        color: color,
        scheduleDays: scheduleDays,
        startTime: startTime,
        endTime: endTime,
        absenceLimit: absenceLimit,
        credits: credits,
        nextExamDate: nextExamDate,
      );

      await _courseRepo.insertCourse(course);
      await loadCourses();
      
      // Schedule Notification
      await _scheduleForCourse(course);
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ders güncelle
  Future<bool> updateCourse(Course course) async {
    _error = null;
    try {
      // Çakışma kontrolü (kendi ID'sini hariç tut)
      final conflict = hasScheduleConflict(
        days: course.scheduleDays,
        startTime: course.startTime,
        endTime: course.endTime,
        excludeId: course.id,
      );
      if (conflict != null) {
        _error = 'Schedule conflict with "${conflict.name}"';
        notifyListeners();
        return false;
      }

      // Cancel old notifications first (days/times might change)
      await _cancelForCourse(course);
      
      await _courseRepo.updateCourse(course);
      await loadCourses();
      
      // Schedule new
      await _scheduleForCourse(course);
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ders sil
  Future<bool> deleteCourse(String id) async {
    try {
      // Find course to get ID/Days for cancellation? 
      // Actually we have ID. But we need days to generate IDs.
      // We should fetch course first or rely on loadCourses having it?
      // Better to get it from _courses list before deleting.
      
      // Safer:
      Course? course;
      try {
        course = _courses.firstWhere((c) => c.id == id);
      } catch (_) {}
      
      if (course != null) {
        await _cancelForCourse(course);
      }

      await _courseRepo.deleteCourse(id);
      await loadCourses();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ders getir
  Future<Course?> getCourseById(String id) async {
    return await _courseRepo.getCourseById(id);
  }

  /// İlerlemeyi güncelle
  Future<void> updateProgress(String courseId, double progress) async {
    final course = await getCourseById(courseId);
    if (course != null) {
      await updateCourse(course.copyWith(progress: progress.clamp(0, 100)));
    }
  }

  /// Devamsızlık ekle
  Future<void> addAbsence(String courseId) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      final newDate = DateTime.now();
      
      // DB Insert
      await _absenceRepo.insertAbsence(_uuid.v4(), courseId, newDate);
      
      // Local Update
      final updatedDates = List<DateTime>.from(course.absenceDates)..add(newDate);
      // Sort: Newest first usually better for history, but typically lists are oldest first?
      // Let's keep internal list sorted by date if needed, but DB query does DESC.
      // Let's stick to what DB returns or valid logic.
      updatedDates.sort((a, b) => b.compareTo(a)); // Descending

      final updatedCourse = course.copyWith(
        absenceDates: updatedDates,
        currentAbsences: updatedDates.length, // Always sync count with list
      );
      
      // Also update course record for legacy support / redundancy if needed, or just rely on list.
      // We still update the course record in DB to keep 'currentAbsences' column in sync just in case
      await _courseRepo.updateCourse(updatedCourse); 

      _courses[courseIndex] = updatedCourse;
      notifyListeners();
    }
  }

  /// Son devamsızlığı sil
  Future<void> removeLastAbsence(String courseId) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      final course = _courses[courseIndex];
      if (course.absenceDates.isEmpty) return;

      // DB Delete
      await _absenceRepo.deleteLastAbsence(courseId);

      // Local Update
      // We assume the DB deletes the latest one.
      // Locally we should remove the Max date.
      final updatedDates = List<DateTime>.from(course.absenceDates);
      if (updatedDates.isNotEmpty) {
         // Sort descending to find latest
         updatedDates.sort((a, b) => b.compareTo(a));
         updatedDates.removeAt(0); // Remove latest
      }

      final updatedCourse = course.copyWith(
        absenceDates: updatedDates,
        currentAbsences: updatedDates.length,
      );

      await _courseRepo.updateCourse(updatedCourse);
      
      _courses[courseIndex] = updatedCourse;
      notifyListeners();
    }
  }

  // ==================== NOT/PUAN İŞLEMLERİ ====================

  /// Ders notlarını (puanlarını) getir
  Future<List<Grade>> loadCourseGrades(String courseId) async {
    return await _gradeRepo.getGradesByCourse(courseId);
  }

  /// Tüm derslerin notlarını getir (İstatistik için)
  Future<Map<String, List<Grade>>> loadAllGrades() async {
    final Map<String, List<Grade>> allGrades = {};
    for (final course in _courses) {
      final grades = await _gradeRepo.getGradesByCourse(course.id);
      allGrades[course.id] = grades;
    }
    return allGrades;
  }

  /// Toplam ağırlığı hesapla (mevcut puanlar üzerinden)
  Future<double> getTotalWeight(String courseId) async {
    final grades = await _gradeRepo.getGradesByCourse(courseId);
    double total = 0.0;
    for (final g in grades) {
      total += g.weight;
    }
    return total;
  }

  /// Puan ekle
  Future<Grade?> addGrade({
    required String courseId,
    required String name,
    required double score,
    double maxScore = 100.0,
    required double weight,
  }) async {
    _error = null;
    _warning = null;
    try {
      // Toplam ağırlık kontrolü — bilgilendirme amaçlı, engelleme yok
      final currentTotal = await getTotalWeight(courseId);
      final newTotal = currentTotal + weight;

      final grade = Grade(
        id: _uuid.v4(),
        courseId: courseId,
        name: name,
        score: score,
        maxScore: maxScore,
        weight: weight,
        createdAt: DateTime.now(),
      );

      await _gradeRepo.insertGrade(grade);

      if (newTotal > 100) {
        _warning = 'Total weight is ${newTotal.toStringAsFixed(0)}% (exceeds 100%). '
            'This may affect weighted average calculation.';
      }

      notifyListeners();
      return grade;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Puan sil
  Future<bool> deleteGrade(String gradeId) async {
    try {
      await _gradeRepo.deleteGrade(gradeId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ağırlıklı ortalama hesapla
  /// Puanlar 100 tabanına normalize edilir, sonra ağırlıklarla çarpılarak ortalaması alınır.
  double calculateWeightedAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0.0;

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (final grade in grades) {
      final normalizedScore = (grade.score / grade.maxScore) * 100.0;
      totalWeightedScore += normalizedScore * grade.weight;
      totalWeight += grade.weight;
    }

    if (totalWeight == 0) return 0.0;

    return totalWeightedScore / totalWeight;
  }

  // ==================== DOSYA İŞLEMLERİ ====================

  /// Ders dosyalarını getir
  Future<List<CourseFile>> loadCourseFiles(String courseId) async {
    return await _fileRepo.getFilesByCourse(courseId);
  }

  /// Dosya ekle (Picker açar)
  Future<bool> addFile(String courseId) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        // App Documents Directory
        final appDir = await getApplicationDocumentsDirectory();
        final courseDir = Directory(p.join(appDir.path, 'course_materials', courseId));
        
        if (!await courseDir.exists()) {
          await courseDir.create(recursive: true);
        }
        
        final destinationPath = p.join(courseDir.path, fileName);
        await File(originalPath).copy(destinationPath);
        
        // Determine type (simple extension check)
        final ext = p.extension(fileName).toLowerCase();
        String type = 'other';
        if (['.pdf'].contains(ext)) type = 'pdf';
        if (['.jpg', '.jpeg', '.png'].contains(ext)) type = 'image';
        if (['.doc', '.docx', '.txt'].contains(ext)) type = 'doc';
        
        final courseFile = CourseFile(
          id: _uuid.v4(),
          courseId: courseId,
          path: destinationPath,
          name: fileName,
          type: type,
          createdAt: DateTime.now(),
        );

        await _fileRepo.insertFile(courseFile);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Dosya sil
  Future<bool> deleteFile(CourseFile file) async {
    try {
      // 1. Delete from DB
      await _fileRepo.deleteFile(file.id);
      
      // 2. Delete from Filesystem
      final fileObj = File(file.path);
      if (await fileObj.exists()) {
        await fileObj.delete();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Dosyayı aç
  Future<void> openFile(CourseFile file) async {
    await OpenFilex.open(file.path);
  }

  /// Örnek veriler ekle
  Future<void> addSampleData() async {
    final sampleCourses = [
      Course(
        id: _uuid.v4(),
        name: 'Mathematics',
        subtitle: 'Calculus II - Integration',
        professor: 'Prof. H. Al-Jibouri',
        location: 'Room 302',
        color: AppColors.orange,
        scheduleDays: [0, 2, 4], // Mon, Wed, Fri
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        progress: 75.0,
        credits: 4,
        nextExamDate: DateTime.now().add(const Duration(days: 4)),
      ),
      Course(
        id: _uuid.v4(),
        name: 'History',
        subtitle: 'The Industrial Revolution',
        professor: 'Dr. Smith',
        location: 'Art Hall B',
        color: AppColors.purple,
        scheduleDays: [1, 3], // Tue, Thu
        startTime: const TimeOfDay(hour: 13, minute: 0),
        endTime: const TimeOfDay(hour: 14, minute: 30),
        progress: 40.0,
        credits: 3,
      ),
      Course(
        id: _uuid.v4(),
        name: 'Biology',
        subtitle: 'Cellular Respiration',
        professor: 'Prof. Johnson',
        location: 'Lab 4',
        color: AppColors.emerald,
        scheduleDays: [0, 2], // Mon, Wed
        startTime: const TimeOfDay(hour: 15, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        progress: 60.0,
        credits: 4,
      ),
      Course(
        id: _uuid.v4(),
        name: 'Linear Algebra',
        subtitle: 'Chapter 4: Matrices',
        professor: 'Dr. Miller',
        location: 'Room 302',
        color: AppColors.blue,
        scheduleDays: [0, 2, 4], // Mon, Wed, Fri
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        progress: 55.0,
        credits: 3,
      ),
    ];

    for (final course in sampleCourses) {
      await _courseRepo.insertCourse(course);
    }

    await loadCourses();
  }

  /// Tüm in-memory verileri sıfırla — kullanıcı çıkışında çağrılır
  void clear() {
    _courses = [];
    _todayCourses = [];
    _priorityCourses = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
