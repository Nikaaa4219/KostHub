import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple key/value storage abstraction to allow swapping secure storage with
/// a fake during tests.
abstract class KeyValueStorage {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);
}

/// Adapter that uses FlutterSecureStorage under the hood.
class FlutterSecureStorageAdapter implements KeyValueStorage {
  final FlutterSecureStorage _impl;

  const FlutterSecureStorageAdapter([FlutterSecureStorage? impl])
    : _impl = impl ?? const FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) =>
      _impl.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _impl.read(key: key);

  @override
  Future<void> delete(String key) => _impl.delete(key: key);
}
