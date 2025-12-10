import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/room.dart';
import '../widgets/room_card.dart';
import 'hotel_detail_screen.dart';
import '../widgets/safe_asset_image.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored header now inside scrollable content so it scrolls away
            Container(
              height: 110,
              color: const Color(0xFF5D5CFF),
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Row(
                children: [
                  const SafeAssetImage(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    circle: true,
                    semanticLabel: 'KostHub logo small',
                  ),
                  const SizedBox(width: 12),
                  // show title only; search removed so header will be simpler and scrollable
                  Text(
                    'KostHub',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(), // Add flexible space between title and notification
                  // Notifications icon with badge (reads from NotificationProvider)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        // badge
                        Positioned(
                          right: 0,
                          top: 4,
                          child: Builder(
                            builder: (ctx) {
                              try {
                                final count = ctx
                                    .watch<NotificationProvider>()
                                    .unreadCount;
                                if (count <= 0) return const SizedBox.shrink();
                                return Semantics(
                                  label: '$count unread notifications',
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF5D5CFF),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Center(
                                      child: Text(
                                        count > 9 ? '9+' : '$count',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } catch (_) {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // content padding
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Categories
                  SizedBox(
                    height: 92,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(6, (index) {
                        final label = 'Category ${index + 1}';
                        final img = 'assets/images/cat${(index % 4) + 1}.jpg';
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: ClipOval(
                                  child: SafeAssetImage(
                                    img,
                                    width: 56,
                                    height: 56,
                                    circle: true,
                                    semanticLabel: label,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Best Hotels',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sampleRooms.length,
                      itemBuilder: (context, idx) {
                        final r = sampleRooms[idx];
                        return SizedBox(
                          width: 320,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HotelDetailScreen(room: r),
                                ),
                              );
                            },
                            child: RoomCard(room: r, compact: false),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Nearby your location',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: sampleRooms
                        .map(
                          (r) => InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HotelDetailScreen(room: r),
                              ),
                            ),
                            child: RoomCard(room: r, compact: true),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation is handled by MainShell when the app is launched
      // via the shell. If this screen is used standalone it will not show a
      // bottom nav; navigation from the home content should navigate to the
      // shell using MainShell.navigateTo(context, index).
    );
  }
}
