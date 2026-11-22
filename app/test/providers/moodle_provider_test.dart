import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/models/moodle/moodle_account.dart';
import 'package:lesson_tracker/models/moodle/moodle_message.dart';
import 'package:lesson_tracker/providers/moodle_provider.dart';
import 'package:lesson_tracker/repositories/moodle_account_repository.dart';
import 'package:lesson_tracker/services/moodle/moodle_api_service.dart';
import 'package:lesson_tracker/services/moodle/moodle_sync_service.dart';
import 'package:lesson_tracker/services/moodle/moodle_token_storage.dart';

MoodleAccount _account(String id) => MoodleAccount(
      id: id,
      baseUrl: 'https://moodle.example.edu',
      siteTitle: 'Example',
      username: 'u_$id',
      fullName: 'User $id',
      lastSynced: DateTime(2026, 1, 1),
    );

class _FakeAccountRepo extends Fake implements MoodleAccountRepository {
  _FakeAccountRepo(this.accounts);
  final List<MoodleAccount> accounts;

  @override
  Future<List<MoodleAccount>> getAll() async => List.of(accounts);

  @override
  Future<void> delete(String id) async =>
      accounts.removeWhere((a) => a.id == id);
}

class _FakeSyncService extends Fake implements MoodleSyncService {
  final List<String> calls = [];
  Completer<void>? gate;

  @override
  Future<MoodleSyncResult> syncAccount(MoodleAccount account) async {
    calls.add(account.id);
    if (gate != null) await gate!.future;
    return MoodleSyncResult(
      account: account,
      messages: [
        MoodleMessage(
          id: 1,
          accountId: account.id,
          senderId: 7,
          senderName: 'Hoca',
          message: 'Merhaba',
          timestamp: DateTime(2026, 1, 1),
        ),
      ],
    );
  }
}

class _FakeTokenStorage extends Fake implements MoodleTokenStorage {
  @override
  Future<void> deleteToken(String accountId) async {}
}

class _FakeApi extends Fake implements MoodleApiService {}

void main() {
  late _FakeSyncService sync;

  MoodleProvider build(List<MoodleAccount> accounts) => MoodleProvider(
        accountRepo: _FakeAccountRepo(accounts),
        syncService: sync,
        api: _FakeApi(),
        tokenStorage: _FakeTokenStorage(),
      );

  setUp(() => sync = _FakeSyncService());

  test('initialize tüm hesapları senkronlar (B1)', () async {
    final provider = build([_account('a'), _account('b')]);
    await provider.initialize();
    await pumpEventQueue();
    expect(sync.calls, ['a', 'b']);
  });

  test('syncAll her hesabı bir kez senkronlar', () async {
    final provider = build([_account('a'), _account('b')]);
    await provider.initialize();
    await pumpEventQueue();
    sync.calls.clear();

    await provider.syncAll();
    expect(sync.calls, ['a', 'b']);
  });

  test('aynı hesap için eşzamanlı ikinci senkron yok sayılır', () async {
    final provider = build([_account('a')]);
    await provider.initialize();
    await pumpEventQueue();
    sync.calls.clear();

    sync.gate = Completer<void>();
    final first = provider.syncAccount('a');
    final second = provider.syncAccount('a');
    expect(provider.isAnySyncing, isTrue);
    sync.gate!.complete();
    await Future.wait([first, second]);

    expect(sync.calls, ['a']);
    expect(provider.isAnySyncing, isFalse);
  });

  test('farklı hesaplar paralel senkronlanabilir', () async {
    final provider = build([_account('a'), _account('b')]);
    await provider.initialize();
    await pumpEventQueue();
    sync.calls.clear();

    sync.gate = Completer<void>();
    final a = provider.syncAccount('a');
    final b = provider.syncAccount('b');
    sync.gate!.complete();
    await Future.wait([a, b]);
    expect(sync.calls, unorderedEquals(['a', 'b']));
  });

  test('mesajlar senkron sonucundan doldurulur (B15)', () async {
    final provider = build([_account('a')]);
    await provider.initialize();
    await pumpEventQueue();
    expect(provider.messagesFor('a'), hasLength(1));
    expect(provider.unreadMessageCount, 1);
  });

  test('senkron sırasında silinen hesabın sonucu yazılmaz', () async {
    final provider = build([_account('a')]);
    await provider.initialize();
    await pumpEventQueue();
    sync.calls.clear();

    sync.gate = Completer<void>();
    final pending = provider.syncAccount('a');
    await provider.removeAccount('a');
    sync.gate!.complete();
    await pending;
    expect(provider.messagesFor('a'), isEmpty);
  });
}
