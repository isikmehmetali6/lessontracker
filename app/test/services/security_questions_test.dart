import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/services/security_questions_service.dart';

import '../fakes/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeCloudRecordsService cloud;

  setUp(() {
    cloud = FakeCloudRecordsService();
    SecurityQuestionsService.cloudFactory = () => cloud;
    SecurityQuestionsService.isSignedIn = () => true;
  });

  test('cevaplar düz metin/base64 olarak saklanmaz (B11)', () async {
    await SecurityQuestionsService.setupSecurityQuestions(
      [0, 3],
      ['Kedi', 'İstanbul'],
    );
    final data = cloud.store['system']!['security_questions']!.data;
    expect(data['v'], 2);
    final stored = (data['answers'] as List).cast<String>();
    for (final s in stored) {
      expect(s, isNot(base64Encode(utf8.encode('kedi'))));
    }
    expect(
      await SecurityQuestionsService.verifyAnswers(['  kedi ', 'İstanbul']),
      isTrue,
    );
    expect(
      await SecurityQuestionsService.verifyAnswers(['köpek', 'İstanbul']),
      isFalse,
    );
  });

  test('v1 kayıt v2\'ye taşınır ve doğrulanabilir', () async {
    await cloud.upsert('system', 'security_questions', {
      'questions': [1, 2],
      'answers': [
        base64Encode(utf8.encode('mavi')),
        base64Encode(utf8.encode('ankara')),
      ],
      'attempts': 0,
    });
    expect(await SecurityQuestionsService.verifyAnswers(['mavi', 'ankara']),
        isFalse);

    await SecurityQuestionsService.migrateIfNeeded();

    final data = cloud.store['system']!['security_questions']!.data;
    expect(data['v'], 2);
    expect(data['questions'], [1, 2]);
    expect(await SecurityQuestionsService.verifyAnswers(['Mavi', 'ankara']),
        isTrue);

    // İkinci çağrı no-op
    final before = Map.of(data);
    await SecurityQuestionsService.migrateIfNeeded();
    expect(cloud.store['system']!['security_questions']!.data['salts'],
        before['salts']);
  });
}
