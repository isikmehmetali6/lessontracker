import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import '../repositories/course_repository.dart';
import '../repositories/absence_repository.dart';
import '../repositories/grade_repository.dart';
import '../repositories/file_repository.dart';
import '../models/course.dart';
import '../models/grade.dart';
import '../core/theme/app_colors.dart';
import '../services/notification_service.dart';
import '../services/file_service.dart';
import '../services/course_file_service.dart';
import '../core/utils/absence_change_bus.dart';
import 'grade_provider.dart';
import 'attendance_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../repositories/note_repository.dart';
import '../services/sync_service.dart';
import '../services/auto_sync_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_file.dart';

/// Ders yönetimi provider
class CourseProvider extends ChangeNotifier {
  CourseProvider({
    CourseRepository? courseRepo,
    AbsenceRepository? absenceRepo,
    GradeRepository? gradeRepo,
    FileRepository? fileRepo,
    NotificationService? notificationService,
    CourseFileService? courseFileService,
  })  : _courseRepo = courseRepo ?? CourseRepository(),
        _absenceRepo = absenceRepo ?? AbsenceRepository(),
        _gradeRepo = gradeRepo ?? GradeRepository(),
        _fileRepo = fileRepo ?? FileRepository(),
        _notificationService = notificationService ?? NotificationService(),
        _fileService = courseFileService ?? CourseFileService() {
    _absenceBusSub = AbsenceChangeBus.instance.stream.listen(_onAbsenceChanged);
  }

  final CourseRepository _courseRepo;
  final AbsenceRepository _absenceRepo;
  final CourseFileService _fileService;
  final GradeRepository _gradeRepo;
  final FileRepository _fileRepo;
  final NotificationService _notificationService;
  final _uuid = const Uuid();
  StreamSubscription<String>? _absenceBusSub;

  List<Course> _courses = [];
  List<Course> _todayCourses = [];
  List<Course> _priorityCourses = [];
  bool _isLoading = false;
  String? _error;
  String? _warning;
  Set<String> _mutedCourseIds = {};

  Future<void> _onAbsenceChanged(String courseId) async {
    final idx = _courses.indexWhere((c) => c.id == courseId);
    if (idx < 0) return;
    final absences = await _absenceRepo.getAbsencesWithReasonByCourse(courseId);
    final dates = absences.map((a) {
      final d = a['date'];
      return d is DateTime ? d : DateTime.parse(d as String);
    }).toList();
    _courses[idx] = _courses[idx].copyWith(absenceDates: dates);
    notifyListeners();
  }

  /// Public read path used by AbsenceCalendarTab so it doesn't keep a
  /// private AbsenceRepository instance.
  Future<List<Map<String, dynamic>>> loadAbsencesForCourse(String courseId) {
    return _absenceRepo.getAbsencesWithReasonByCourse(courseId);
  }

  // Getters
  List<Course> get courses => List.unmodifiable(_courses);

  /// O(1) lookup by course id
  Map<String, Course> get coursesById =>
      _coursesByIdCache ??= {for (var c in _courses) c.id: c};

  Map<String, Course>? _coursesByIdCache;

  /// İsim bazlı gruplandırılmış dersler (Aynı isimli dersleri tek bir dersmiş gibi gösterir)
  List<Course> get uniqueCourses {
    final Map<String, Course> courseMap = {};
    for (var course in _courses) {
      if (!courseMap.containsKey(course.name)) {
        courseMap[course.name] = course;
      } else {
        final existing = courseMap[course.name]!;
        courseMap[course.name] = existing.copyWith(
          scheduleDays: {
            ...existing.scheduleDays,
            ...course.scheduleDays,
          }.toList(),
          currentAbsences: existing.currentAbsences + course.currentAbsences,
        );
      }
    }
    return courseMap.values.toList();
  }

  List<Course> get todayCourses => List.unmodifiable(_todayCourses);
  List<Course> get priorityCourses => List.unmodifiable(_priorityCourses);
  bool get isLoading => _isLoading;

  String? get error => _error;
  String? get warning => _warning;

  /// Uyarıyı temizle
  void clearWarning() {
    _warning = null;
    notifyListeners();
  }

  bool isCourseMuted(String courseId) => _mutedCourseIds.contains(courseId);

  Future<void> toggleCourseMute(String courseId) async {
    if (_mutedCourseIds.contains(courseId)) {
      _mutedCourseIds.remove(courseId);
    } else {
      _mutedCourseIds.add(courseId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('muted_course_ids', _mutedCourseIds.toList());

    // Cancel or reschedule notifications for this course
    final course = _courses.where((c) => c.id == courseId).firstOrNull;
    if (course != null) {
      if (_mutedCourseIds.contains(courseId)) {
        await _cancelForCourse(course);
      } else {
        await _scheduleForCourse(course);
      }
    }
  }

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  int _reminderMinutes = 15;
  int get reminderMinutes => _reminderMinutes;

  Future<void> setReminderMinutes(int minutes) async {
    _reminderMinutes = minutes;
    if (_notificationsEnabled) {
      await _rescheduleAllNotifications();
    }
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    if (_notificationsEnabled) {
      await _rescheduleAllNotifications();
    } else {
      await _notificationService.cancelAllNotifications();
    }
    notifyListeners();
  }

  Future<void> _rescheduleAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    for (var course in _courses) {
      await _scheduleForCourse(course);
    }
  }

  Future<void> _scheduleForCourse(Course course) async {
    if (!_notificationsEnabled) return;
    if (_mutedCourseIds.contains(course.id)) return;

    try {
      for (var day in course.scheduleDays) {
        int notifyHour = course.startTime.hour;
        int notifyMinute = course.startTime.minute - _reminderMinutes;

        while (notifyMinute < 0) {
          notifyMinute += 60;
          notifyHour -= 1;
        }
        int notifyDay = day;
        if (notifyHour < 0) {
          notifyHour += 24;
          notifyDay = (day - 1) < 0 ? 6 : (day - 1);
        }

        await _notificationService.scheduleClassNotification(
          courseId: course.id,
          courseName: course.name,
          location: course.location,
          dayOfWeek: notifyDay,
          hour: notifyHour,
          minute: notifyMinute,
          reminderMinutes: _reminderMinutes,
        );
      }
    } catch (e) {
      debugPrint('NotificationService: Failed to schedule for course ${course.id}: $e');
    }
  }

  Future<void> _cancelForCourse(Course course) async {
    for (var day in course.scheduleDays) {
      await _notificationService.cancelClassNotification(course.id, day);
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
      final commonDays = days
          .where((d) => course.scheduleDays.contains(d))
          .toList();
      if (commonDays.isEmpty) continue;

      // Saat çakışması kontrolü
      final existingStartMin =
          course.startTime.hour * 60 + course.startTime.minute;
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
    final todayCourses = _courses
        .where((c) => c.scheduleDays.contains(todayWeekday))
        .toList();
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
      final prefs = await SharedPreferences.getInstance();
      _mutedCourseIds = (prefs.getStringList('muted_course_ids') ?? []).toSet();

      final activeCourses = await _courseRepo.getActiveCourses();
      _courses = activeCourses;

      final allAbsences = await _absenceRepo.getAllAbsences();
      for (int i = 0; i < _courses.length; i++) {
        final absences = allAbsences[_courses[i].id] ?? [];
        _courses[i] = _courses[i].copyWith(
          absenceDates: absences,
          currentAbsences: absences.length,
        );
      }

      // Re-filter for today and priority based on updated course data
      _todayCourses = _courses.where((c) => c.isScheduledToday).toList();
      _priorityCourses = _courses
          .where((c) => c.hasUpcomingExam || c.isBehind)
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _coursesByIdCache = null;
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
    String? professorEmail,
    String? professorPhone,
    String? professorOffice,
    String? officeHours,
    String? assistantName,
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
        professorEmail: professorEmail,
        professorPhone: professorPhone,
        professorOffice: professorOffice,
        officeHours: officeHours,
        assistantName: assistantName,
      );

      await _courseRepo.insertCourse(course);
      await loadCourses();
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

      // Cancel old notifications (use old course data for correct days)
      final oldCourse = _courses.where((c) => c.id == course.id).firstOrNull;
      if (oldCourse != null) {
        await _cancelForCourse(oldCourse);
      }

      await _courseRepo.updateCourse(course);
      await loadCourses();
      await _scheduleForCourse(course);

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Direct course ekleme (çakışma kontrolü yok - Moodle senkron için)
  Future<bool> addCourseDirect(Course course) async {
    _error = null;
    try {
      final courseWithId = course.copyWith(id: _uuid.v4());
      await _courseRepo.insertCourse(courseWithId);
      await loadCourses();
      await _scheduleForCourse(courseWithId);

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Ders sil
  Future<bool> deleteCourse(String id) async {
    if (kIsWeb) return false;
    try {
      // Find course to get ID/Days for cancellation?
      // Actually we have ID. But we need days to generate IDs.
      // We should fetch course first or rely on loadCourses having it?
      // Better to get it from _courses list before deleting.

      // Safer:
      Course? course;
      try {
        course = _courses.firstWhere(
          (c) => c.id == id,
          orElse: () => throw StateError('Course not found: $id'),
        );
      } catch (e, stackTrace) {
        debugPrint('Error finding course $id: $e\nStack: $stackTrace');
      }

      if (course != null) {
        await _cancelForCourse(course);
      }

      // 1. Delete local media files to prevent device storage leaks
      try {
        final fileService = FileService();
        final NoteRepository noteRepo = NoteRepository();
        final FileRepository fileRepo = FileRepository();

        final courseNotes = await noteRepo.getNotesByCourse(id);
        for (final note in courseNotes) {
          if (note.filePath != null) {
            final path = await fileService.resolveFilePath(note.filePath!);
            if (path != null) {
              final f = File(path);
              if (await f.exists()) await f.delete();
            }
          }
          if (note.thumbnailPath != null) {
            final path = await fileService.resolveFilePath(note.thumbnailPath!);
            if (path != null) {
              final f = File(path);
              if (await f.exists()) await f.delete();
            }
          }
        }

        final courseFiles = await fileRepo.getFilesByCourse(id);
        for (final file in courseFiles) {
          if (file.path.isNotEmpty) {
            final path = await fileService.resolveFilePath(file.path);
            if (path != null) {
              final f = File(path);
              if (await f.exists()) await f.delete();
            }
          }
        }
      } catch (e) {
        debugPrint('Error cleaning up local files for course $id: $e');
      }

      // 2. Delete local DB record (cascades)
      await _courseRepo.deleteCourse(id);

      // 3. Buluttan da sil (tamamen)
      try {
        final SyncService syncService = SyncService();
        await syncService.deleteCourseCloud(id);
      } catch (e) {
        debugPrint('Error triggering cloud delete for course $id: $e');
        await AutoSyncService().recordPendingChange('courses', id, 'delete');
        _warning =
            'Silme işlemi yerel olarak tamamlandı. Bulut senkronizasyonu daha sonra tamamlanacak.';
      }

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
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (e, stackTrace) {
      debugPrint('Error getting course from memory: $e\nStack: $stackTrace');
      return await _courseRepo.getCourseById(id);
    }
  }

  /// İlerlemeyi güncelle
  Future<void> updateProgress(String courseId, double progress) async {
    final course = await getCourseById(courseId);
    if (course != null) {
      await updateCourse(course.copyWith(progress: progress.clamp(0, 100)));
    }
  }

  /// Devamsızlık ekle
  Future<void> addAbsence(
    String courseId, {
    String reason = 'unexcused',
  }) {
    return addAbsenceAt(courseId, DateTime.now(), reason: reason);
  }

  /// Tarihli devamsızlık ekle (takvim sekmesi için)
  /// Mevcut `addAbsence` (DateTime.now()) kullanımını bozmamak için ayrı metod.
  /// AttendanceProvider'a delege eder; local state mutasyonu kalır.
  Future<void> addAbsenceAt(
    String courseId,
    DateTime date, {
    String reason = 'unexcused',
  }) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) return;

    final course = _courses[courseIndex];
    final newDate = date;

    await AttendanceProvider(absenceRepo: _absenceRepo).addAbsenceAt(
      courseId,
      newDate,
      reason: reason,
    );

    final updatedDates = List<DateTime>.from(course.absenceDates)
      ..add(newDate);
    updatedDates.sort((a, b) => b.compareTo(a));

    final updatedCourse = course.copyWith(
      absenceDates: updatedDates,
      currentAbsences: updatedDates.length,
    );

    await _courseRepo.updateCourse(updatedCourse);

    _courses[courseIndex] = updatedCourse;
    _coursesByIdCache = null;
    notifyListeners();
  }

  /// ID ile devamsızlık sil (takvim sekmesi için)
  /// AttendanceProvider'a delege eder; local state mutasyonu kalır.
  Future<void> removeAbsenceById(String courseId, String absenceId) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) return;

    final course = _courses[courseIndex];

    await AttendanceProvider(absenceRepo: _absenceRepo).removeAbsenceById(
      courseId,
      absenceId,
    );

    final allAbsences = await _absenceRepo.getAbsencesWithReasonByCourse(courseId);
    final updatedDates = allAbsences.map((a) {
      final dateStr = a['date'];
      return dateStr is DateTime ? dateStr : DateTime.parse(dateStr as String);
    }).toList();
    updatedDates.sort((a, b) => b.compareTo(a));

    final updatedCourse = course.copyWith(
      absenceDates: updatedDates,
      currentAbsences: updatedDates.length,
    );

    await _courseRepo.updateCourse(updatedCourse);

    _courses[courseIndex] = updatedCourse;
    _coursesByIdCache = null;
    notifyListeners();
  }

  /// Devamsızlık sebebini güncelle (takvim sekmesi için)
  /// AttendanceProvider'a delege eder.
  Future<void> updateAbsenceReasonById(String absenceId, String reason) async {
    await AttendanceProvider(absenceRepo: _absenceRepo)
        .updateAbsenceReasonById('', absenceId, reason);
    notifyListeners();
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
      _coursesByIdCache = null;
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

  /// Puan ekle (facade). Asıl iş GradeProvider'da; local state
  /// mutasyonu CourseProvider'da kalır (Course.absenceDates/grades burada).
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
      await GradeProvider(
        gradeRepo: _gradeRepo,
        uuid: _uuid,
      ).addGrade(
        courseId: courseId,
        name: name,
        score: score,
        maxScore: maxScore,
        weight: weight,
        currentTotalWeight: currentTotal,
      );
      // _warning'i GradeProvider'dan okumak yerine yerel hesap korunur.
      if (newTotal > 100) {
        _warning =
            'Total weight is ${newTotal.toStringAsFixed(0)}% (exceeds 100%). '
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

  /// Puan güncelle (facade).
  Future<bool> updateGrade(Grade grade) async {
    _error = null;
    try {
      await GradeProvider(gradeRepo: _gradeRepo).updateGrade(grade);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Puan sil (facade).
  Future<bool> deleteGrade(String gradeId) async {
    try {
      await GradeProvider(gradeRepo: _gradeRepo).deleteGrade(gradeId);
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
  /// Weight 100% aştığında normalize edilir.
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

    if (totalWeight > 100) {
      final factor = 100.0 / totalWeight;
      totalWeightedScore *= factor;
      totalWeight = 100.0;
    }

    return totalWeightedScore / totalWeight;
  }

  // ==================== DOSYA İŞLEMLERİ ====================

  /// Ders dosyalarını getir
  Future<List<CourseFile>> loadCourseFiles(String courseId) async {
    return await _fileRepo.getFilesByCourse(courseId);
  }

  /// Dosya ekle (Picker açar)
  /// Göreceli yol kullanır — iOS sandbox değişince dosyalar kaybolmasın
  Future<bool> addFile(String courseId) async {
    if (kIsWeb) return false;
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final originalName = result.files.single.name;
        final ext = p.extension(originalName);
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}$ext';

        final appDir = await getApplicationDocumentsDirectory();
        final courseDir = Directory(
          p.join(appDir.path, 'course_materials', courseId),
        );

        if (!await courseDir.exists()) {
          await courseDir.create(recursive: true);
        }

        final destinationPath = p.join(courseDir.path, uniqueFileName);
        final sourceFile = File(originalPath);
        if (!await sourceFile.exists()) {
          _error = 'Source file no longer available';
          notifyListeners();
          return false;
        }
        await sourceFile.copy(destinationPath);

        final destFile = File(destinationPath);
        if (!await destFile.exists()) {
          _error = 'Failed to save file';
          notifyListeners();
          return false;
        }

        final extLower = ext.toLowerCase();
        String type = 'other';
        if (['.pdf'].contains(extLower)) type = 'pdf';
        if (['.jpg', '.jpeg', '.png', '.heic', '.webp'].contains(extLower)) {
          type = 'image';
        }
        if (['.doc', '.docx', '.txt'].contains(extLower)) type = 'doc';

        final relativePath = 'course_materials/$courseId/$uniqueFileName';

        final courseFile = CourseFile(
          id: _uuid.v4(),
          courseId: courseId,
          path: relativePath,
          name: originalName,
          type: type,
          createdAt: DateTime.now(),
        );

        await _fileRepo.insertFileWithUpload(courseFile, sourceFile);
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

  Future<bool> addLink(String courseId, String name, String url) async {
    try {
      final fileId = _uuid.v4();
      String type = 'link';
      if (url.endsWith('.pdf')) {
        type = 'pdf';
      } else if (url.contains('youtube') || url.contains('vimeo')) {
        type = 'video';
      }

      final courseFile = CourseFile(
        id: fileId,
        courseId: courseId,
        path: '',
        name: name,
        type: type,
        createdAt: DateTime.now(),
        url: url,
      );
      await _fileRepo.insertFile(courseFile);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add link: $e';
      notifyListeners();
      return false;
    }
  }

  /// Dosya sil
  Future<bool> deleteFile(CourseFile file) async {
    try {
      await _fileRepo.deleteFile(file.id);

      if (file.path.isNotEmpty && file.url == null) {
        final resolvedPath = await FileService().resolveFilePath(file.path);
        if (resolvedPath != null) {
          final fileObj = File(resolvedPath);
          if (await fileObj.exists()) {
            await fileObj.delete();
          }
        }
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
    try {
      final error = await _fileService.open(file);
      if (error != null) {
        _error = error;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Could not open file: ${file.name}';
      notifyListeners();
    }
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
    _mutedCourseIds = {};
    _coursesByIdCache = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _absenceBusSub?.cancel();
    _notificationService.cancelAllNotifications();
    super.dispose();
  }
}
