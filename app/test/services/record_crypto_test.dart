import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/services/record_crypto.dart';
import 'package:lesson_tracker/services/sync_encryption.dart';

import '../fakes/fakes.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> storage;

  setUp(() {
    storage = setupInMemorySecureStorage();
  });

  test('v2 seal/open roundtrip', () async {
    final rc = RecordCrypto(keyService: FakeE2EKeyService());
    final sealed = await rc.seal({'id': 'a', 'title': 'Ödev ğ'});
    expect(sealed['v'], 2);
    expect(RecordCrypto.isCurrent(sealed), isTrue);
    expect(await rc.open(sealed), {'id': 'a', 'title': 'Ödev ğ'});
  });

  test('aynı kayıt iki kez farklı şifreli metin üretir (sabit IV yok)', () async {
    final rc = RecordCrypto(keyService: FakeE2EKeyService());
    final a = await rc.seal({'x': 1});
    final b = await rc.seal({'x': 1});
    expect(a['encryptedData'], isNot(b['encryptedData']));
  });

  test('v2 kayıt aynı anahtarla başka cihazda açılır', () async {
    final keys = FakeE2EKeyService();
    final sealed = await RecordCrypto(keyService: keys).seal({'n': 42});
    // Farklı RecordCrypto örneği, aynı E2E anahtarı (parola ile açılmış)
    final other = RecordCrypto(keyService: FakeE2EKeyService(key: keys.key));
    expect(await other.open(sealed), {'n': 42});
  });

  test('anahtar yoksa seal RecordCryptoKeyMissing fırlatır', () async {
    final keys = FakeE2EKeyService()..key = null;
    final rc = RecordCrypto(keyService: keys);
    expect(await rc.isReady, isFalse);
    expect(() => rc.seal({'a': 1}), throwsA(isA<RecordCryptoKeyMissing>()));
  });

  test('legacy kayıt, legacy anahtar bu cihazdaysa açılır', () async {
    storage[SyncEncryption.keyName] = encrypt.Key.fromSecureRandom(32).base64;
    storage[SyncEncryption.ivName] = encrypt.IV.fromSecureRandom(16).base64;
    final legacy = SyncEncryption();
    final payload = await legacy.encryptLegacyForTesting({'id': 'old'});

    final rc = RecordCrypto(keyService: FakeE2EKeyService(), legacy: legacy);
    final envelope = {'encryptedData': payload};
    expect(RecordCrypto.isCurrent(envelope), isFalse);
    expect(await rc.open(envelope), {'id': 'old'});
  });

  test('legacy kayıt başka cihazda LegacyBackupKeyMissing verir', () async {
    final rc = RecordCrypto(keyService: FakeE2EKeyService());
    expect(
      () => rc.open({'encryptedData': 'AAAA'}),
      throwsA(isA<LegacyBackupKeyMissing>()),
    );
  });

  test('encryptedData alanı olmayan düz kayıt olduğu gibi döner', () async {
    final rc = RecordCrypto(keyService: FakeE2EKeyService());
    expect(
      await rc.open({'courseId': 'c', 'dates': ['2026-01-01']}),
      {'courseId': 'c', 'dates': ['2026-01-01']},
    );
  });
}
