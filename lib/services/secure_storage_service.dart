// Secure storage service wrapper
// Generated to centralize usage of flutter_secure_storage for token persistence.
// Stores sensitive tokens in platform secure storage. Use SecureStorageService.instance
// to access. For tests, call SecureStorageService.setTestInstance(...) to inject a fake.
// NOTE: Adjust the storage key names if your app uses different legacy keys.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static SecureStorageService? _instance;

  final FlutterSecureStorage _impl;

  // singleton accessor
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._(const FlutterSecureStorage());
    return _instance!;
  }

  // allow injecting a test instance
  static void setTestInstance(SecureStorageService testInstance) {
    _instance = testInstance;
  }

  const SecureStorageService._(this._impl);

  // write a value to secure storage
  Future<void> write(String key, String value) async {
    await _impl.write(key: key, value: value);
  }

  // read a value from secure storage
  Future<String?> read(String key) async {
    return await _impl.read(key: key);
  }

  // delete a single key
  Future<void> delete(String key) async {
    await _impl.delete(key: key);
  }

  // delete all keys
  Future<void> deleteAll() async {
    try {
      await _impl.deleteAll();
    } catch (_) {
      // some platforms may not support deleteAll - ignore but surface in logs if needed
    }
  }
}
