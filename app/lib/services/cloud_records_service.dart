import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/backend/supabase_backend.dart';

/// Tek bir bulut kaydı (`user_records` satırı).
class CloudRecord {
  final String id;
  final String? courseId;
  final Map<String, dynamic> data;

  const CloudRecord({required this.id, this.courseId, required this.data});
}

/// `public.user_records` tablosu üzerinde kullanıcıya ait koleksiyon erişimi.
///
/// Firestore'daki `users/{uid}/{collection}/{id}` yapısının karşılığıdır:
/// her satır (user_id, collection, id) ile tekil, içerik `data` (jsonb)
/// sütununda durur. RLS yalnızca `user_id = auth.uid()` satırlarına izin verir.
class CloudRecordsService {
  static const String _table = 'user_records';
  static const int _pageSize = 1000;

  SupabaseClient get _client {
    final c = SupabaseBackend.client;
    if (c == null) throw Exception('Supabase is not configured');
    return c;
  }

  String get _uid {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    return user.id;
  }

  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data, {
    String? courseId,
  }) =>
      upsertMany(collection, [
        CloudRecord(id: id, courseId: courseId, data: data),
      ]);

  Future<void> upsertMany(String collection, List<CloudRecord> records) async {
    if (records.isEmpty) return;
    final uid = _uid;
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from(_table).upsert(
      records
          .map(
            (r) => {
              'user_id': uid,
              'collection': collection,
              'id': r.id,
              'course_id': r.courseId,
              'data': r.data,
              'updated_at': now,
            },
          )
          .toList(),
      onConflict: 'user_id,collection,id',
    );
  }

  Future<CloudRecord?> get(String collection, String id) async {
    final row = await _client
        .from(_table)
        .select('id, course_id, data')
        .eq('user_id', _uid)
        .eq('collection', collection)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _toRecord(row);
  }

  Future<List<CloudRecord>> getAll(String collection) async {
    final uid = _uid;
    final result = <CloudRecord>[];
    var from = 0;
    while (true) {
      final rows = await _client
          .from(_table)
          .select('id, course_id, data')
          .eq('user_id', uid)
          .eq('collection', collection)
          .order('id')
          .range(from, from + _pageSize - 1);
      result.addAll(rows.map(_toRecord));
      if (rows.length < _pageSize) break;
      from += _pageSize;
    }
    return result;
  }

  Future<int> count(String collection) async {
    final res = await _client
        .from(_table)
        .select('id')
        .eq('user_id', _uid)
        .eq('collection', collection)
        .count(CountOption.exact);
    return res.count;
  }

  Future<void> delete(String collection, String id) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', _uid)
        .eq('collection', collection)
        .eq('id', id);
  }

  Future<void> deleteByCourse(String collection, String courseId) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', _uid)
        .eq('collection', collection)
        .eq('course_id', courseId);
  }

  Future<void> deleteCollection(String collection) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', _uid)
        .eq('collection', collection);
  }

  Future<void> deleteAll() async {
    await _client.from(_table).delete().eq('user_id', _uid);
  }

  CloudRecord _toRecord(Map<String, dynamic> row) => CloudRecord(
        id: row['id'] as String,
        courseId: row['course_id'] as String?,
        data: Map<String, dynamic>.from(row['data'] as Map),
      );
}
