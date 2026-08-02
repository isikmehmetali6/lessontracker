import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/grade.dart';
import '../repositories/grade_repository.dart';

/// Grade state and CRUD.
///
/// Extracted from CourseProvider per plan 2.1b. The current
/// CourseProvider facade still exposes addGrade/updateGrade/deleteGrade
/// for backwards compatibility; UI migration is tracked separately.
class GradeProvider extends ChangeNotifier {
  GradeProvider({
    GradeRepository? gradeRepo,
    Uuid? uuid,
  })  : _gradeRepo = gradeRepo ?? GradeRepository(),
        _uuid = uuid ?? const Uuid();

  final GradeRepository _gradeRepo;
  final Uuid _uuid;

  bool _isLoading = false;
  String? _error;
  String? _warning;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get warning => _warning;

  Future<Grade?> addGrade({
    required String courseId,
    required String name,
    required double score,
    double maxScore = 100.0,
    required double weight,
    required double currentTotalWeight,
  }) async {
    _error = null;
    _warning = null;
    try {
      final newTotal = currentTotalWeight + weight;
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

  Future<bool> updateGrade(Grade grade) async {
    _error = null;
    try {
      await _gradeRepo.updateGrade(grade);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

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

  Future<List<Grade>> gradesForCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _gradeRepo.getGradesByCourse(courseId);
      return list;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> totalWeight(String courseId) async {
    try {
      final grades = await _gradeRepo.getGradesByCourse(courseId);
      return grades.fold<double>(0.0, (sum, g) => sum + g.weight);
    } catch (e) {
      return 0.0;
    }
  }
}