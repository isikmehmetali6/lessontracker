import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'file_service.dart';

/// Ses kaydı servisi
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final _fileService = FileService();
  
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  /// Kayıt devam ediyor mu?
  Future<bool> get isRecording async => await _recorder.isRecording();

  /// Mikrofon izni var mı?
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Kaydı başlat
  Future<bool> startRecording() async {
    try {
      if (await isRecording) {
        await stopRecording();
      }

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        return false;
      }

      _currentRecordingPath = await _fileService.getTempAudioPath();
      _recordingStartTime = DateTime.now();

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      return true;
    } catch (e) {
      _currentRecordingPath = null;
      _recordingStartTime = null;
      return false;
    }
  }

  /// Kaydı durdur
  Future<AudioRecordingResult?> stopRecording() async {
    try {
      if (!await isRecording) {
        return null;
      }

      final path = await _recorder.stop();
      if (path == null || _currentRecordingPath == null) {
        return null;
      }

      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inSeconds
          : 0;

      // Geçici dosyayı kalıcı konuma taşı (göreceli yol döner)
      final savedRelativePath = await _fileService.saveAudio(File(path));

      // Geçici dosyayı sil (orijinal mutlak yolu kullan)
      try {
        final tempFile = File(path);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        debugPrint('[AudioService] Could not delete temp file: $e');
      }

      final result = AudioRecordingResult(
        filePath: savedRelativePath,
        duration: duration,
      );

      _currentRecordingPath = null;
      _recordingStartTime = null;

      return result;
    } catch (e) {
      debugPrint('[AudioService] Stop recording error: $e');
      _currentRecordingPath = null;
      _recordingStartTime = null;
      return null;
    }
  }

  /// Kaydı iptal et
  Future<void> cancelRecording() async {
    try {
      if (await isRecording) {
        await _recorder.stop();
      }
      if (_currentRecordingPath != null) {
        try {
          final tempFile = File(_currentRecordingPath!);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          debugPrint('[AudioService] Could not delete temp file: $e');
        }
      }
    } catch (e) {
      debugPrint('[AudioService] Cancel recording error: $e');
    } finally {
      _currentRecordingPath = null;
      _recordingStartTime = null;
    }
  }

  // --- Oynatma ---

  /// Ses dosyasını oynat
  Future<void> play(String path) async {
    debugPrint('[AudioService] Playing: $path');
    try {
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('[AudioService] ⚠️ Play error: $e');
    }
  }

  /// Oynatmayı durdur
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  /// Oynatmayı duraklat
  Future<void> pausePlayback() async {
    await _player.pause();
  }

  /// Oynatmaya devam et
  Future<void> resumePlayback() async {
    await _player.resume();
  }

  /// Belirli bir süreye git
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Oynatma durumu akışı
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  /// Oynatma pozisyonu akışı
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  /// Toplam süre akışı
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  /// Oynatma tamamlandı akışı
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  /// Kayıt süresini getir (ms)
  int get recordingDurationMs {
    if (_recordingStartTime == null) return 0;
    return DateTime.now().difference(_recordingStartTime!).inMilliseconds;
  }

  /// Kayıt süresini getir (saniye)
  int get recordingDuration {
    if (_recordingStartTime == null) return 0;
    return DateTime.now().difference(_recordingStartTime!).inSeconds;
  }

  /// Servisi kapat
  Future<void> dispose() async {
    await cancelRecording();
    await _recorder.dispose();
    await _player.dispose();
  }
}

/// Ses kaydı sonucu
class AudioRecordingResult {
  final String filePath;
  final int duration; // saniye

  AudioRecordingResult({
    required this.filePath,
    required this.duration,
  });

  /// Formatlanmış süre
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
