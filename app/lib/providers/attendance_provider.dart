import 'package:flutter/foundation.dart';
import '../repositories/absence_repository.dart';
import '../core/utils/absence_change_bus.dart';

/// Attendance state and CRUD, plus the event-driven reload on
/// AbsenceChangeBus events.
///
/// Extracted from CourseProvider per plan 2.1c. CourseProvider keeps a
/// facade for backwards compatibility until UI migrates.
class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider({
    AbsenceRepository? absenceRepo,
  }) : _absenceRepo = absenceRepo ?? AbsenceRepository();

  final AbsenceRepository _absenceRepo;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addAbsenceAt(
    String courseId,
    DateTime date, {
    String reason = 'unexcused',
  }) async {
    _error = null;
    try {
      await _absenceRepo.insertAbsence(
        '${courseId}_${date.toIso8601String().split('T')[0]}',
        courseId,
        date,
        reason: reason,
      );
      AbsenceChangeBus.instance.fire(courseId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeAbsenceById(String courseId, String absenceId) async {
    _error = null;
    try {
      await _absenceRepo.deleteAbsence(absenceId);
      AbsenceChangeBus.instance.fire(courseId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAbsenceReasonById(
    String courseId,
    String absenceId,
    String reason,
  ) async {
    _error = null;
    try {
      await _absenceRepo.updateAbsenceReason(absenceId, reason);
      AbsenceChangeBus.instance.fire(courseId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getAbsencesWithReasonForCourse(
    String courseId,
  ) {
    return _absenceRepo.getAbsencesWithReasonByCourse(courseId);
  }

  /// Read-only dates for a course (matches Course.absenceDates getter).
  Future<List<DateTime>> datesForCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _absenceRepo.getAbsencesWithReasonByCourse(courseId);
      return list.map((a) {
        final d = a['date'];
        return d is DateTime ? d : DateTime.parse(d as String);
      }).toList();
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}