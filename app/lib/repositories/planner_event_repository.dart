import '../models/planner_event.dart';
import '../core/database/database_helper.dart';
import '../services/auto_sync_service.dart';

/// Stateless — no in-memory web fallback cache to preserve (web reads/writes
/// simply no-op below), so plain (non-singleton) construction is intentional
/// (bkz. 4a.3, docs/REFACTORING_PLAN.md).
class PlannerEventRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<PlannerEvent>> getAllEvents() async {
    if (_dbHelper.isWeb) return [];
    
    final db = await _dbHelper.database;
    final maps = await db.query('planner_events');
    return maps.map((map) => PlannerEvent.fromMap(map)).toList();
  }

  Future<PlannerEvent?> getEventById(String id) async {
    if (_dbHelper.isWeb) return null;

    final db = await _dbHelper.database;
    final maps = await db.query(
      'planner_events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PlannerEvent.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertEvent(PlannerEvent event) async {
    if (_dbHelper.isWeb) return;

    final db = await _dbHelper.database;
    await db.insert('planner_events', event.toMap());
    AutoSyncService().triggerBackup();
  }

  Future<void> updateEvent(PlannerEvent event) async {
    if (_dbHelper.isWeb) return;

    final db = await _dbHelper.database;
    await db.update(
      'planner_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    AutoSyncService().triggerBackup();
  }

  Future<void> deleteEvent(String id) async {
    if (_dbHelper.isWeb) return;

    final db = await _dbHelper.database;
    await db.delete(
      'planner_events',
      where: 'id = ?',
      whereArgs: [id],
    );
    AutoSyncService().triggerBackup();
  }

  Future<void> clearAll() async {
    if (_dbHelper.isWeb) return;

    final db = await _dbHelper.database;
    await db.delete('planner_events');
  }
}
