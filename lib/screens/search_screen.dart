// File: lib/screens/search_screen.dart
// Auto-generated via Copilot — manual review required.
// Terhubung ke: lib/providers/room_provider.dart (stub) dan lib/widgets/room_card.dart
// See TODOs.md for consolidated actionable items (e.g. replace stubs with real API calls)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../widgets/room_card.dart';
import 'hotel_detail_screen.dart';

const _kBackground = Color(0xFF0B0C10);
const _kPrimary = Color(0xFF5D5CFF);
const _kSearchBg = Color(0xFF15161A);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // panggil provider setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<RoomProvider>().searchRooms('');
      } catch (_) {}
    });
    _queryCtrl.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final q = _queryCtrl.text.trim();
    try {
      context.read<RoomProvider>().searchRooms(q);
    } catch (_) {}
  }

  Future<void> _onUseLocation() async {
    // Location-based filtering is not implemented yet; see TODOs.md
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gunakan lokasi: fitur stub, belum terhubung'),
      ),
    );
  }

  @override
  void dispose() {
    _queryCtrl.removeListener(_onQueryChanged);
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();
    final rooms = provider.rooms;

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Empty space on the left to center the title; the close
                  // action (back) is placed at the top-right as requested.
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Search',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _kSearchBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFB9B9C9)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _queryCtrl,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Color(0xFFB9B9C9)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFFB9B9C9),
                            ),
                            onPressed: () => _queryCtrl.clear(),
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _onQueryChanged(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // use my location link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _onUseLocation,
                  child: Text(
                    'or use my current location',
                    style: GoogleFonts.inter(color: _kPrimary, fontSize: 13),
                  ),
                ),
              ),
            ),

            // Recent Search title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Text(
                    'Recent Search',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Results list
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HotelDetailScreen(room: room),
                        ),
                      );
                    },
                    child: RoomCard(room: room, compact: true),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// See TODOs.md for a list of backend integration tasks.
