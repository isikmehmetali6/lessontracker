import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestInfrastructure();
    setupSecureStorageMock();
    setupSqlCipherMock();
  });

  test('v17 DB v18\'e yükselir: pending_changes.payload ve course_files.cloudPath (B21)', () async {
    const name = 'test_migration_v18.db';
    final path = join(await databaseFactory.getDatabasesPath(), name);
    await databaseFactory.deleteDatabase(path);

    // v17'de _onCreate ile oluşturulmuş bir DB'nin ilgili tabloları
    final old = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 17,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE courses (id TEXT PRIMARY KEY)');
          await db.execute('''
            CREATE TABLE course_files (
              id TEXT PRIMARY KEY, courseId TEXT NOT NULL, path TEXT NOT NULL,
              name TEXT NOT NULL, type TEXT NOT NULL, createdAt TEXT NOT NULL,
              url TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE pending_changes (
              id INTEGER PRIMARY KEY AUTOINCREMENT, tableName TEXT NOT NULL,
              recordId TEXT NOT NULL, operation TEXT NOT NULL,
              timestamp TEXT NOT NULL, synced INTEGER DEFAULT 0
            )
          ''');
        },
      ),
    );
    await old.close();

    await DatabaseHelper().close();
    DatabaseHelper.dbName = name;
    final db = await DatabaseHelper().database;

    expect(await db.getVersion(), 18);
    final pendingCols = (await db.rawQuery('PRAGMA table_info(pending_changes)'))
        .map((r) => r['name'])
        .toList();
    final fileCols = (await db.rawQuery('PRAGMA table_info(course_files)'))
        .map((r) => r['name'])
        .toList();
    expect(pendingCols, contains('payload'));
    expect(fileCols, contains('cloudPath'));
  });

  test('sıfırdan kurulumda course_files.cloudPath vardır', () async {
    await DatabaseHelper().close();
    DatabaseHelper.dbName = 'test_fresh_v18.db';
    await databaseFactory.deleteDatabase(
      join(await databaseFactory.getDatabasesPath(), DatabaseHelper.dbName),
    );
    final db = await DatabaseHelper().database;
    final fileCols = (await db.rawQuery('PRAGMA table_info(course_files)'))
        .map((r) => r['name'])
        .toList();
    expect(fileCols, contains('cloudPath'));
  });
}
