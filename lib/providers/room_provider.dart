// Auto-generated via Copilot — manual review required.
// File: lib/providers/room_provider.dart
// Deskripsi: Provider sederhana untuk Room data (stub).
// See TODOs.md for backend integration tasks (RoomService).

import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../services/room_service.dart';

/// RoomProvider delegates to [RoomService].
/// See TODOs.md for backend integration tasks.
class RoomProvider extends ChangeNotifier {
  final RoomService _service;

  List<Room> _rooms = [];

  List<Room> get rooms => _rooms;

  RoomProvider({RoomService? service}) : _service = service ?? RoomService() {
    // initialize with nearby/sample
    _init();
  }

  Future<void> _init() async {
    _rooms = await _service.fetchNearby();
    notifyListeners();
  }

  /// Search rooms through RoomService.
  Future<List<Room>> searchRooms(String q) async {
    try {
      final result = await _service.searchRooms(q);
      _rooms = result;
      notifyListeners();
      return result;
    } catch (e) {
      _rooms = [];
      notifyListeners();
      return _rooms;
    }
  }

  /// Return cached nearby list (fast sync accessor)
  List<Room> nearby() => List<Room>.from(_rooms);
}
