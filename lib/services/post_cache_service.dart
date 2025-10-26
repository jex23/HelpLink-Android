import '../models/post_model.dart';

class PostCacheService {
  // Singleton pattern
  static final PostCacheService _instance = PostCacheService._internal();
  factory PostCacheService() => _instance;
  PostCacheService._internal();

  // Cache storage
  final Map<String, CachedData<List<Post>>> _cache = {};

  // Cache duration (5 minutes)
  static const Duration cacheDuration = Duration(minutes: 5);

  // Get cached posts
  List<Post>? getCachedPosts(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(cached.timestamp) > cacheDuration) {
      _cache.remove(key);
      return null;
    }

    return cached.data;
  }

  // Store posts in cache
  void cachePosts(String key, List<Post> posts) {
    _cache[key] = CachedData(
      data: posts,
      timestamp: DateTime.now(),
    );
  }

  // Clear specific cache
  void clearCache(String key) {
    _cache.remove(key);
  }

  // Clear all cache
  void clearAllCache() {
    _cache.clear();
  }

  // Generate cache keys
  static String getAllPostsCacheKey({String? status, int? userId}) {
    return 'all_posts_${status ?? 'all'}_${userId ?? 'all'}';
  }

  static String getDonationsCacheKey({String? status, int? userId}) {
    return 'donations_${status ?? 'all'}_${userId ?? 'all'}';
  }

  static String getRequestsCacheKey({String? status, int? userId}) {
    return 'requests_${status ?? 'all'}_${userId ?? 'all'}';
  }

  static String getPostsCacheKey({String? postType, String? status, int? userId}) {
    return 'posts_${postType ?? 'all'}_${status ?? 'all'}_${userId ?? 'all'}';
  }
}

// Helper class to store cached data with timestamp
class CachedData<T> {
  final T data;
  final DateTime timestamp;

  CachedData({
    required this.data,
    required this.timestamp,
  });
}
