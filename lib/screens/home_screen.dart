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
  // --- VARIABEL UNTUK KORSEL PROMO (MANUAL) ---
  final PageController _promoController = PageController();
  int _currentPromoIndex = 0;

  // 1. DAFTAR GAMBAR PROMO
  final List<String> promoImages = [
    'assets/images/PNG-KostHub/Promo1.png',
    'assets/images/PNG-KostHub/Promo2.png',
    'assets/images/PNG-KostHub/Promo3.png',
  ];

  // 2. DAFTAR GAMBAR NEGARA
  final List<String> negaraImages = [
    'assets/images/PNG-KostHub/Negara1.png',
    'assets/images/PNG-KostHub/Negara2.png',
    'assets/images/PNG-KostHub/Negara3.png',
    'assets/images/PNG-KostHub/Negara4.png',
    'assets/images/PNG-KostHub/Negara5.png',
    'assets/images/PNG-KostHub/Negara6.png',
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER KOSTHUB (SUDAH RESPONSIVE DENGAN SAFEAREA) ---
            Container(
              color: const Color(0xFF5D5CFF),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const SafeAssetImage(
                        'assets/images/PNG-KostHub/Logo_SplashScreen.png',
                        width: 40,
                        height: 40,
                        circle: true,
                        semanticLabel: 'KostHub logo small',
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'KostHub',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
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
                            Positioned(
                              right: 0,
                              top: 4,
                              child: Builder(
                                builder: (ctx) {
                                  try {
                                    final count = ctx
                                        .watch<NotificationProvider>()
                                        .unreadCount;

                                    // --- PERBAIKAN KURUNG KURAWAL DI SINI ---
                                    if (count <= 0) {
                                      return const SizedBox.shrink();
                                    }
                                    // ----------------------------------------

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
              ),
            ),

            // --- 2. KORSEL PROMO MANUAL ---
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _promoController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPromoIndex = index;
                  });
                },
                itemCount: promoImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        promoImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white54, size: 40),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // TITIK INDIKATOR BANYAKNYA PROMO
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                promoImages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPromoIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPromoIndex == index
                        ? const Color(0xFF5D5CFF)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // --- 3. KONTEN UTAMA LAINNYA ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Kategori Negara (Bulat Tanpa Teks) ---
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: negaraImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: ClipOval(
                              child: SafeAssetImage(
                                negaraImages[index],
                                width: 56,
                                height: 56,
                                circle: true,
                                semanticLabel: 'Negara ${index + 1}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // --- Best Hotels ---
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

                  // --- Nearby your location ---
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
    );
  }
}
