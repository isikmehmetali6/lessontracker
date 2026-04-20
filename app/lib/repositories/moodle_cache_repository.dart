import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/app_constants.dart';

/// Moodle API yanıtlarını moodle_cache tablosunda saklar.
/// Ağ bağlantısı olmadığında son sync'teki veriler gösterilir.
class MoodleCacheRepository {
  final DatabaseHelper _db = DatabaseHelper();

  // Cache geçerlilik süresi — 2 saat (offline-first yaklaşım)
  static const Duration _ttl = Duration(hours: 2);

  /// Cache'e veri yaz (varsa üstüne yaz)
  Future<void> write({
    required String accountId,
    required String dataType,
    required dynamic payload,
  }) async {
    final db = await _db.database;
    final json = jsonEncode(payload);
    final now = DateTime.now().toIso8601String();

    await db.execute(
      '''
      INSERT OR REPLACE INTO moodle_cache (accountId, dataType, payload, cachedAt, accessedAt)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [accountId, dataType, json, now, now],
    );

    await _enforceMaxCacheSize();
  }

  /// Cache'den oku — süresi geçmişse null döner
  Future<dynamic> read({
    required String accountId,
    required String dataType,
    bool ignoreExpiry = false,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'moodle_cache',
      where: 'accountId = ? AND dataType = ?',
      whereArgs: [accountId, dataType],
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final cachedAt = DateTime.parse(row['cachedAt'] as String);

    if (!ignoreExpiry) {
      final age = DateTime.now().difference(cachedAt);
      if (age > _ttl) return null;
    }

    await db.update(
      'moodle_cache',
      {'accessedAt': DateTime.now().toIso8601String()},
      where: 'accountId = ? AND dataType = ?',
      whereArgs: [accountId, dataType],
    );

    return jsonDecode(row['payload'] as String);
  }

  /// Max cache boyutunu kontrol eder ve gerekirse LRU eviction yapar
  Future<void> _enforceMaxCacheSize() async {
    final db = await _db.database;
    final sizeResult = await db.rawQuery(
      'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()',
    );
    final sizeBytes = sizeResult.first['size'] as int? ?? 0;
    final sizeMB = sizeBytes ~/ (1024 * 1024);

    if (sizeMB > AppConstants.MAX_CACHE_SIZE_MB) {
      final deleteCount = await db.rawDelete(
        '''
        DELETE FROM moodle_cache 
        WHERE id IN (
          SELECT id FROM moodle_cache 
          ORDER BY accessedAt ASC 
          LIMIT (? / 2)
        )
      ''',
        [sizeBytes],
      );
      debugPrint(
        'MoodleCacheRepository: Cleaned $deleteCount entries, freed ~${sizeMB ~/ 2}MB',
      );
    }
  }

  /// Eski cache entry'lerini temizle (TTL süresi dolmuş)
  Future<void> cleanupOldCache() async {
    final db = await _db.database;
    final cutoff = DateTime.now().subtract(_ttl).toIso8601String();
    await db.delete('moodle_cache', where: 'cachedAt < ?', whereArgs: [cutoff]);
  }

  /// Belirli hesabın tüm cache'ini sil
  Future<void> clearForAccount(String accountId) async {
    final db = await _db.database;
    await db.delete(
      'moodle_cache',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
  }

  /// Tüm Moodle cache'ini sil
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('moodle_cache');
  }

  /// Cache'in ne zaman güncellendiğini döner
  Future<DateTime?> getLastUpdated({
    required String accountId,
    required String dataType,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'moodle_cache',
      columns: ['cachedAt'],
      where: 'accountId = ? AND dataType = ?',
      whereArgs: [accountId, dataType],
    );
    if (rows.isEmpty) return null;
    return DateTime.parse(rows.first['cachedAt'] as String);
  }
}
