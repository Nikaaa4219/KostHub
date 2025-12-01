import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility to perform a deep, developer-facing reset of local app data.
///
/// WARNING: Intended for development/debugging only. Do NOT ship UI that
/// exposes this to end users.
Future<void> deepReset({bool includeFiles = true}) async {
  try {
    // Clear shared preferences.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('SharedPreferences cleared');

    if (!includeFiles) return;

    // Remove application directories where files might be cached.
    final dir = await getApplicationSupportDirectory();
    await _deleteDirectorySafe(dir);
    debugPrint('Application support directory cleared: ${dir.path}');

    final cacheDir = await getTemporaryDirectory();
    await _deleteDirectorySafe(cacheDir);
    debugPrint('Cache directory cleared: ${cacheDir.path}');

    // On Android, there is also getExternalStorageDirectory; delete if available.
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        await _deleteDirectorySafe(ext);
        debugPrint('External storage directory cleared: ${ext.path}');
      }
    } catch (_) {
      // ignore: avoid_print
      debugPrint('External storage access not available/denied');
    }
  } catch (e, st) {
    debugPrint('deepReset failed: $e\n$st');
    rethrow;
  }
}

Future<void> _deleteDirectorySafe(Directory dir) async {
  try {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  } catch (e) {
    debugPrint('Failed to delete ${dir.path}: $e');
  }
}
