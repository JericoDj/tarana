import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class RtdbSource {
  final FirebaseDatabase _database;

  RtdbSource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Sets data at a specific path
  Future<void> setData(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).set(data);
    } catch (e) {
      throw Exception('Failed to set RTDB data at $path: $e');
    }
  }

  /// Updates data at a specific path
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).update(data);
    } catch (e) {
      throw Exception('Failed to update RTDB data at $path: $e');
    }
  }

  /// Removes data at a specific path
  Future<void> removeData(String path) async {
    try {
      await _database.ref(path).remove();
    } catch (e) {
      throw Exception('Failed to remove RTDB data at $path: $e');
    }
  }

  /// Sets up an onDisconnect handler for a path
  Future<void> setOnDisconnect(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).onDisconnect().update(data);
    } catch (e) {
      throw Exception('Failed to set onDisconnect at $path: $e');
    }
  }

  /// Cancels an existing onDisconnect handler
  Future<void> cancelOnDisconnect(String path) async {
    try {
      await _database.ref(path).onDisconnect().cancel();
    } catch (e) {
      throw Exception('Failed to cancel onDisconnect at $path: $e');
    }
  }

  /// Listen to value changes at a path
  Stream<DatabaseEvent> watchPath(String path) {
    return _database.ref(path).onValue;
  }
}
