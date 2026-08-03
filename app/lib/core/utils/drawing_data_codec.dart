import 'dart:convert';

import 'package:lesson_tracker/widgets/course/drawing_canvas.dart';

/// Single source of truth for the drawing-data JSON format used by
/// `Note.drawingData`. Per plan 3.2 the wire format is now versioned:
///
///   v1 (legacy): a flat list of strokes, treated as page 1.
///   v2:         `{"v":2,"strokesByPage": {"<page>": [strokeMap, ...]}}`
///               Each strokeMap follows [DrawingStroke.toMap] and may
///               include per-point pressure (`p`); the codec and
///               [DrawingStroke.fromMap] tolerate missing `p`.
///
/// We always emit `v2` going forward.
class DrawingDataCodec {
  static const int currentVersion = 2;

  /// Encode a per-page strokes map into a JSON string.
  static String encode(Map<int, List<DrawingStroke>> strokesByPage) {
    final payload = <String, dynamic>{
      'v': currentVersion,
      'strokesByPage': strokesByPage.map(
        (page, strokes) => MapEntry(
          page.toString(),
          strokes.map((s) => s.toMap()).toList(),
        ),
      ),
    };
    return jsonEncode(payload);
  }

  /// Decode a JSON string produced by [encode] (or the legacy v1 list).
  /// Returns an empty map on parse failure.
  static Map<int, List<DrawingStroke>> decode(String raw) {
    if (raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final version = (decoded['v'] as num?)?.toInt() ?? 1;
        final strokesByPage = decoded['strokesByPage'];
        if (strokesByPage is Map<String, dynamic>) {
          final result = <int, List<DrawingStroke>>{};
          strokesByPage.forEach((key, value) {
            final pageNum = int.tryParse(key.toString());
            if (pageNum == null || value is! List) return;
            result[pageNum] = value
                .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
                .toList(growable: false);
          });
          if (result.isNotEmpty) return result;
        }
        // v2 with no strokesByPage -> empty
        if (version >= 2) return const {};
      }
      if (decoded is List) {
        // v1 legacy: flat list -> page 1
        return {
          1: decoded
              .map((e) => DrawingStroke.fromMap(e as Map<String, dynamic>))
              .toList(growable: false),
        };
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }
}