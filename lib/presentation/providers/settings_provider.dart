import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

/// Settings provider for user preferences (persisted via GetStorage)
class SettingsProvider extends ChangeNotifier {
  final GetStorage _box = GetStorage('tarana_prefs');

  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyDefaultPayment = 'default_payment';
  static const String _keySoundEffects = 'sound_effects';
  static const String _keyAutoAccept = 'auto_accept_rides';

  // Getters
  bool get notificationsEnabled => _box.read<bool>(_keyNotifications) ?? true;
  String get language => _box.read<String>(_keyLanguage) ?? 'en';
  bool get darkModeEnabled => _box.read<bool>(_keyDarkMode) ?? false;
  String get defaultPayment => _box.read<String>(_keyDefaultPayment) ?? 'cash';
  bool get soundEffectsEnabled => _box.read<bool>(_keySoundEffects) ?? true;
  bool get autoAcceptRides => _box.read<bool>(_keyAutoAccept) ?? false;

  ThemeMode get themeMode => darkModeEnabled ? ThemeMode.dark : ThemeMode.light;

  String get languageLabel {
    switch (language) {
      case 'en':
        return 'English';
      case 'fil':
        return 'Filipino';
      case 'ceb':
        return 'Cebuano';
      default:
        return 'English';
    }
  }

  // Setters
  Future<void> setNotificationsEnabled(bool value) async {
    await _box.write(_keyNotifications, value);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    await _box.write(_keyLanguage, lang);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _box.write(_keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setDefaultPayment(String payment) async {
    await _box.write(_keyDefaultPayment, payment);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) async {
    await _box.write(_keySoundEffects, value);
    notifyListeners();
  }

  Future<void> setAutoAcceptRides(bool value) async {
    await _box.write(_keyAutoAccept, value);
    notifyListeners();
  }

  /// Reset all preferences to defaults
  Future<void> resetAll() async {
    await _box.erase();
    notifyListeners();
  }
}
