// File: lib/services/room_service.dart
// Stub service for Room-related operations.
// Replace with real network calls when API is available.

import 'dart:async';
import '../models/room.dart';

class RoomService {
  RoomService();

  /// Simulate a server search (filtering sampleRooms).
  Future<List<Room>> searchRooms(String q) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return List<Room>.from(sampleRooms);
    return sampleRooms
        .where(
          (r) =>
              r.name.toLowerCase().contains(query) ||
              r.location.toLowerCase().contains(query),
        )
        .toList();
  }

  /// Simulate fetching nearby rooms.
  Future<List<Room>> fetchNearby() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Room>.from(sampleRooms);
  }
}
