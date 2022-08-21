LazyDB? _lazyDB;

LazyDB get lazydb => _lazyDB ??= LazyDB();

class LazyDB {
  static final String cacheVersion = '3.0';
  static bool _initialized = false;

  bool cacheable;
	String? cacheDir;

  LazyDB({
    this.cacheable = false,
		this.cacheDir,
  }) {
    if (!_initialized) {
      _initialized = true;
    }
  }
}
