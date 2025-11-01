import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/room.dart';
import '../providers/saved_provider.dart';
import '../widgets/room_card.dart';

/// Simple Saved screen: shows rooms that the user marked as saved.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>().savedIds;

    // Map saved ids to known sampleRooms; in a real app you'd query the
    // backend or a RoomProvider. This keeps the example self-contained.
    final List<Room> rooms = sampleRooms
        .where((r) => saved.contains(r.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text('Saved'),
        backgroundColor: const Color(0xFF0E0F12),
      ),
      body: rooms.isEmpty
          ? const Center(
              child: Text(
                'No saved rooms yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (ctx, i) => RoomCard(room: rooms[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: rooms.length,
            ),
    );
  }
}
