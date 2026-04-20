import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/deadline.dart';
import '../repositories/deadline_repository.dart';
import '../core/services/calendar_service.dart';

class DeadlineProvider with ChangeNotifier {
  final DeadlineRepository _deadlineRepo = DeadlineRepository();
  
  List<Deadline> _deadlines = [];
  bool _isLoading = false;
  String? _error;

  List<Deadline> get deadlines => List.unmodifiable(_deadlines);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Deadline> get upcomingDeadlines {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _deadlines.where((d) => d.date.isAfter(today) || d.date.isAtSameMomentAs(today)).toList();
  }

  Future<void> loadDeadlines() async {
    _isLoading = true;
    notifyListeners();

    try {
      _deadlines = await _deadlineRepo.getAllDeadlines();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading deadlines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeadline(Deadline deadline) async {
    try {
      await _deadlineRepo.insertDeadline(deadline);
      _deadlines.add(deadline);
      _deadlines.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding deadline: $e');
    }
  }

  Future<bool> updateDeadline(Deadline deadline) async {
    try {
      await _deadlineRepo.updateDeadline(deadline);
      await loadDeadlines();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating deadline: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDeadline(String id) async {
    try {
      await _deadlineRepo.deleteDeadline(id);
      _deadlines.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting deadline: $e');
      return false;
    }
  }
  
  // Calculate days left
  int getDaysLeft(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }
  
  final CalendarService _calendarService = CalendarService();
  
  // ... (existing code)

  // Create a new deadline helper
  Future<bool> createDeadline({
    required String courseId,
    required String title,
    required DateTime date,
    required DeadlineType type,
    bool reminder = true,
    bool addToCalendar = false,
  }) async {
    final id = const Uuid().v4();
    final deadline = Deadline(
      id: id,
      courseId: courseId,
      title: title,
      date: date,
      type: type,
      reminder: reminder,
    );
    
    await addDeadline(deadline);

    if (addToCalendar) {
      try {
        final endDate = date.add(const Duration(hours: 1));
        await _calendarService.addEvent(
          title: '${type.name.toUpperCase()}: $title',
          description: 'Deadline for course',
          startDate: date,
          endDate: endDate,
          allDay: false,
        );
      } catch (e) {
        debugPrint('Error adding to calendar: $e');
      }
    }
    
    return true;
  }

  /// Tüm in-memory verileri sıfırla — kullanıcı çıkışında çağrılır
  void clear() {
    _deadlines = [];
    _isLoading = false;
    notifyListeners();
  }
}
