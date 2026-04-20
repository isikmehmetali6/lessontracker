import 'package:flutter/material.dart';
import '../models/planner_event.dart';
import '../repositories/planner_event_repository.dart';

class PlannerEventProvider extends ChangeNotifier {
  final PlannerEventRepository _repository = PlannerEventRepository();
  List<PlannerEvent> _events = [];

  List<PlannerEvent> get events => _events;

  Future<void> loadEvents() async {
    _events = await _repository.getAllEvents();
    notifyListeners();
  }

  Future<void> addEvent(PlannerEvent event) async {
    await _repository.insertEvent(event);
    _events.add(event);
    notifyListeners();
  }

  Future<void> updateEvent(PlannerEvent event) async {
    await _repository.updateEvent(event);
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    await _repository.deleteEvent(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _events.clear();
    notifyListeners();
  }
}
