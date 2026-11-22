import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lesson_tracker/core/database/database_helper.dart';

void setupTestInfrastructure() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testOpenDatabaseOverride = (
    String path,
    int version, {
    required Future<void> Function(Database) onConfigure,
    required Future<void> Function(Database, int) onCreate,
    required Future<void> Function(Database, int, int) onUpgrade,
  }) async {
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: onConfigure,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      ),
    );
  };

  SharedPreferences.setMockInitialValues({});
}

void setupSecureStorageMock() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'read':
        return '';
      case 'write':
        return null;
      case 'delete':
        return null;
      case 'deleteAll':
        return null;
      case 'containsKey':
        return false;
      case 'readAll':
        return <String, String>{};
      default:
        return null;
    }
  });
}

void setupSqlCipherMock() {
  const channel = MethodChannel('com.davidmartos96.sqflite_sqlcipher');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'openDatabase':
        return 1;
      case 'deleteDatabase':
        return true;
      case 'execute':
        return <dynamic>[];
      case 'rawQuery':
        return <Map<String, dynamic>>[];
      case 'insert':
        return 1;
      case 'update':
        return 1;
      case 'delete':
        return 1;
      case 'closeDatabase':
        return null;
      default:
        return null;
    }
  });
}
