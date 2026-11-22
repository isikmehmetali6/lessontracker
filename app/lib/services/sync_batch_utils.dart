import 'package:flutter/foundation.dart';

/// Rows per bulk upsert request — keeps PostgREST request bodies small.
const int kSyncBatchChunkSize = 400;

/// Network error classifier used by the retry helper.
bool isSyncNetworkError(Object error) {
  final msg = error.toString().toLowerCase();
  return msg.contains('socketexception') ||
      msg.contains('timeoutexception') ||
      msg.contains('handshakeexception') ||
      msg.contains('connection') ||
      msg.contains('network') ||
      msg.contains('clientexception') ||
      msg.contains('httpexception') ||
      msg.contains('authretryablefetchexception');
}

/// Exponential backoff retry for transient network/backend failures.
/// Only retries when [isSyncNetworkError] returns true; other errors
/// propagate immediately.
Future<T> withSyncRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 4,
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await operation();
    } catch (e) {
      attempt++;
      if (attempt >= maxAttempts || !isSyncNetworkError(e)) {
        rethrow;
      }
      final delay = Duration(seconds: (1 << (attempt - 1)));
      debugPrint('SyncRetry $attempt/$maxAttempts after ${delay.inSeconds}s: $e');
      await Future.delayed(delay);
    }
  }
}