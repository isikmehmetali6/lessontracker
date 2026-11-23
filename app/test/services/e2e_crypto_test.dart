import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/services/e2e_crypto_service.dart';
import 'package:lesson_tracker/services/e2e_key_service.dart';

import '../fakes/fakes.dart';
import '../test_helpers.dart';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final crypto = E2ECryptoService();

  group('PBKDF2-HMAC-SHA256 (RFC 7914 §11 / bilinen vektörler)', () {
    test('password/salt, c=1', () {
      final out = pbkdf2HmacSha256(
        utf8.encode('password'),
        utf8.encode('salt'),
        1,
        32,
      );
      expect(
        _hex(out),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
    });

    test('password/salt, c=4096', () {
      final out = pbkdf2HmacSha256(
        utf8.encode('password'),
        utf8.encode('salt'),
        4096,
        32,
      );
      expect(
        _hex(out),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });

    test('deriveKeyAsync Türkçe karakterli parolada deterministik', () async {
      final salt = crypto.generateSalt();
      final a = await crypto.deriveKeyAsync('şifreĞüİ', salt);
      final b = await crypto.deriveKeyAsync('şifreĞüİ', salt);
      final c = await crypto.deriveKeyAsync('sifreGuI', salt);
      expect(a, b);
      expect(a, isNot(c));
      expect(a.length, 32);
    });
  });

  group('AES-GCM', () {
    test('roundtrip', () {
      final key = crypto.generateKey();
      final data = Uint8List.fromList(utf8.encode('merhaba dünya'));
      expect(crypto.decryptGcm(crypto.encryptGcm(data, key), key), data);
    });

    test('her şifreleme farklı nonce kullanır', () {
      final key = crypto.generateKey();
      final data = Uint8List.fromList([1, 2, 3]);
      expect(
        crypto.encryptGcm(data, key),
        isNot(crypto.encryptGcm(data, key)),
      );
    });

    test('bozulmuş veri reddedilir', () {
      final key = crypto.generateKey();
      final sealed = crypto.encryptGcm(Uint8List.fromList([1, 2, 3, 4]), key);
      sealed[sealed.length - 1] ^= 0xFF;
      expect(() => crypto.decryptGcm(sealed, key), throwsA(anything));
    });

    test('yanlış anahtar reddedilir', () {
      final sealed = crypto.encryptGcm(
        Uint8List.fromList([1, 2, 3]),
        crypto.generateKey(),
      );
      expect(
        () => crypto.decryptGcm(sealed, crypto.generateKey()),
        throwsA(anything),
      );
    });

    test('encryptString UTF-8 ile çalışır', () {
      final key = crypto.generateKey();
      const text = 'Çalışma notları — ğüşıöç İ';
      expect(crypto.decryptToString(crypto.encryptString(text, key), key), text);
    });
  });

  group('Dosya biçimi', () {
    test('v2 dosyası LTG2 öneki taşır ve çözülür', () {
      final key = crypto.generateKey();
      final data = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      final enc = crypto.encryptFile(data, key);
      expect(enc.sublist(0, 4), E2ECryptoService.fileMagicV2);
      expect(crypto.decryptFile(enc, key), data);
    });

    test('legacy CBC dosyası hâlâ çözülür', () {
      final key = crypto.generateKey();
      final data = Uint8List.fromList([9, 8, 7, 6, 5]);
      final legacy = crypto.encryptLegacyCbc(data, key);
      expect(crypto.decryptFile(legacy, key), data);
    });
  });

  group('E2EKeyService sarma', () {
    late FakeCloudRecordsService cloud;
    late Map<String, String> storage;
    late E2EKeyService service;

    setUp(() {
      storage = setupInMemorySecureStorage();
      cloud = FakeCloudRecordsService();
      service = E2EKeyService.overrideForTesting(
        cloud: cloud,
        currentUserId: () => 'user-1',
      );
    });

    tearDown(E2EKeyService.resetForTesting);

    test('v2 anahtar başka cihazda parola ile açılır', () async {
      await service.initializeUserKey('Parola123ğ');
      final original = await service.getLocalKey();
      expect(cloud.store['system']!['e2e_key']!.data['kdfVersion'], 2);

      // "Yeni cihaz"
      storage.clear();
      service.clearCache();
      expect(await service.getLocalKey(), isNull);

      expect(await service.loadKeyFromCloud('yanlış'), isFalse);
      expect(await service.loadKeyFromCloud('Parola123ğ'), isTrue);
      expect(await service.getLocalKey(), original);
    });

    test('legacy sarılmış anahtar açılır ve v2 ile yeniden sarılır', () async {
      final userKey = crypto.generateKey();
      final salt = crypto.generateSalt();
      final legacyDerived = await crypto.deriveKeyLegacyAsync('eski', salt);
      await cloud.upsert('system', 'e2e_key', {
        'encryptedKey': base64Encode(
          crypto.encryptLegacyCbc(userKey, legacyDerived),
        ),
        'salt': base64Encode(salt),
        'keyVersion': 1,
      });

      expect(await service.loadKeyFromCloud('eski'), isTrue);
      expect(await service.getLocalKey(), userKey);
      expect(cloud.store['system']!['e2e_key']!.data['kdfVersion'], 2);

      // Yeniden sarılmış kayıt da aynı parolayla açılmalı
      storage.clear();
      service.clearCache();
      expect(await service.loadKeyFromCloud('eski'), isTrue);
      expect(await service.getLocalKey(), userKey);
    });

    test('parola değişimi sonrası yeni parola açar, eskisi açmaz', () async {
      await service.initializeUserKey('eski');
      final key = await service.getLocalKey();
      await service.changePassword('eski', 'yeni');

      storage.clear();
      service.clearCache();
      expect(await service.loadKeyFromCloud('eski'), isFalse);
      expect(await service.loadKeyFromCloud('yeni'), isTrue);
      expect(await service.getLocalKey(), key);
    });

    test('e-postayla şifre sıfırlamada yerel anahtar yeni şifreye sarılır', () async {
      await service.initializeUserKey('unutulan');
      final key = await service.getLocalKey();

      // Eski şifre bilinmeden, yerel anahtarla yeniden sarma
      expect(await service.rewrapWithNewPassword('yeni-şifre'), isTrue);

      storage.clear();
      service.clearCache();
      expect(await service.loadKeyFromCloud('unutulan'), isFalse);
      expect(await service.loadKeyFromCloud('yeni-şifre'), isTrue);
      expect(await service.getLocalKey(), key);
    });

    test('yerel anahtar yoksa yeniden sarma yapılmaz', () async {
      await service.initializeUserKey('eski');
      storage.clear();
      service.clearCache();
      expect(await service.rewrapWithNewPassword('yeni'), isFalse);
      // Bulut kaydı değişmedi: eski şifre hâlâ açar
      expect(await service.loadKeyFromCloud('eski'), isTrue);
    });

    test('başka kullanıcının yerel anahtarı kullanılmaz (B20)', () async {
      await service.initializeUserKey('p');
      expect(await service.hasLocalKey(), isTrue);

      final other = E2EKeyService.overrideForTesting(
        cloud: cloud,
        currentUserId: () => 'user-2',
      );
      expect(await other.getLocalKey(), isNull);
      expect(await other.hasLocalKey(), isFalse);
    });
  });
}
