import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Dedicated disk cache for Moodle-hosted images (course covers, account
/// avatars), kept separate from [DefaultCacheManager].
///
/// Policy: course covers and avatars rarely change and are non-essential
/// (re-fetchable), so a short retention keeps cache disk usage bounded on
/// low-storage devices instead of accumulating indefinitely under the
/// library's default 30-day / 200-object policy. Storage screen's
/// "deep clean" (Faz 0.7/4a.2) empties this cache explicitly since it is
/// a separate [CacheManager] instance from [DefaultCacheManager].
class MoodleImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'moodleImageCache';

  static final MoodleImageCacheManager _instance =
      MoodleImageCacheManager._();

  factory MoodleImageCacheManager() => _instance;

  MoodleImageCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 14),
            maxNrOfCacheObjects: 100,
          ),
        );
}
