import 'package:get_storage/get_storage.dart';

/// Local storage service using GetStorage
class LocalStorageSource {
  static final GetStorage _box = GetStorage('tarana_prefs');

  /// Initialize GetStorage — call in main.dart
  static Future<void> init() async {
    await GetStorage.init('tarana_prefs');
  }

  // ─── Generic Read/Write ───

  static T? read<T>(String key) => _box.read<T>(key);

  static Future<void> write(String key, dynamic value) =>
      _box.write(key, value);

  static Future<void> remove(String key) => _box.remove(key);

  static Future<void> clearAll() => _box.erase();

  // ─── Convenience Keys ───

  static const String _keyOnboarded = 'onboarded';
  static const String _keyLastViewedLat = 'last_viewed_lat';
  static const String _keyLastViewedLng = 'last_viewed_lng';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyActiveRole = 'active_role';

  /// Whether onboarding has been completed
  static bool get onboarded => read<bool>(_keyOnboarded) ?? false;
  static set onboarded(bool value) => write(_keyOnboarded, value);

  /// Last viewed map location (for quick reopen)
  static double? get lastViewedLat => read<double>(_keyLastViewedLat);
  static double? get lastViewedLng => read<double>(_keyLastViewedLng);
  static Future<void> setLastViewedLocation(double lat, double lng) async {
    await write(_keyLastViewedLat, lat);
    await write(_keyLastViewedLng, lng);
  }

  /// Notifications preference
  static bool get notificationsEnabled =>
      read<bool>(_keyNotificationsEnabled) ?? true;
  static set notificationsEnabled(bool value) =>
      write(_keyNotificationsEnabled, value);

  /// Cached active role
  static String? get activeRole => read<String>(_keyActiveRole);
  static set activeRole(String? value) =>
      write(_keyActiveRole, value ?? 'rider');
}
