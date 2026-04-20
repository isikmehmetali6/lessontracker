import '../../models/moodle/moodle_account.dart';
import '../../core/database/database_helper.dart';

/// moodle_accounts tablosu üzerinde CRUD işlemleri
class MoodleAccountRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Tüm kayıtlı Moodle hesaplarını getir
  Future<List<MoodleAccount>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('moodle_accounts', orderBy: 'lastSynced DESC');
    return rows.map(MoodleAccount.fromMap).toList();
  }

  /// ID'ye göre tek hesap getir
  Future<MoodleAccount?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      'moodle_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return MoodleAccount.fromMap(rows.first);
  }

  /// Yeni Moodle hesabı kaydet
  Future<void> insert(MoodleAccount account) async {
    final db = await _db.database;
    await db.insert('moodle_accounts', account.toMap());
  }

  /// Mevcut hesabı güncelle (lastSynced güncellemesi gibi)
  Future<void> update(MoodleAccount account) async {
    final db = await _db.database;
    await db.update(
      'moodle_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Hesabı sil — ON DELETE CASCADE ile ilgili cache de silinir
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      'moodle_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Belirli bir baseUrl + username kombinasyonu zaten kayıtlı mı?
  Future<bool> exists(String baseUrl, String username) async {
    final db = await _db.database;
    final rows = await db.query(
      'moodle_accounts',
      where: 'baseUrl = ? AND username = ?',
      whereArgs: [baseUrl, username],
    );
    return rows.isNotEmpty;
  }
}
