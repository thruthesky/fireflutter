/// This service was mainly made to
/// prevent the scroll problems for multiple
/// nested firestore stream builders.
///
class CacheService {
  static CacheService? _instance;
  static CacheService get instance {
    // _instance ??= CacheService._init();
    _instance ??= CacheService._();
    return _instance!;
  }

  CacheService._();
  // CacheService._init();

  final Map<String, dynamic> _cache = {};

  dynamic get(String id) {
    return _cache[id];
  }

  void cache(String id, dynamic data) {
    _cache[id] = data;
  }

  void clean(String id) {
    _cache.remove(id);
  }

  void cleanList(List<String> ids) {
    for (final id in ids) {
      _cache.remove(id);
    }
  }

  void clear() {
    _cache.clear();
  }
}
