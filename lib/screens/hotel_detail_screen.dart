// File: lib/screens/hotel_detail_screen.dart
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';
import '../providers/saved_provider.dart';
import '../widgets/safe_asset_image.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../widgets/guest_picker_bottom_sheet.dart';
import '../widgets/hotel_mini_map.dart'; // Import widget maps baru
import '../screens/confirm_pay_screen.dart';

const Color primaryAccent = Color(0xFF5D5CFF);
const Color bg = Color(0xFF0B0C10);
const Color surface = Color(0xFF0E0F12);
const Color muted = Color(0xFFB9B9C9);
const Color starColor = Color(0xFFFFD166);
const int monthlyPrice = 2500000;

final _currency = NumberFormat.currency(
  locale: 'id',
  symbol: 'Rp ',
  decimalDigits: 0,
);

class HotelDetailScreen extends StatefulWidget {
  final Room room;

  const HotelDetailScreen({super.key, required this.room});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  bool _navigating = false;

  @override
  Widget build(BuildContext context) {
    final savedProv = context.watch<SavedProvider>();
    final isSaved = savedProv.isSaved(widget.room.id);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // Bagian atas (Gambar & Tombol Back/Save) tetap sama
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: SafeAssetImage(
                  widget.room.assetImage,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 9 / 16,
                  fit: BoxFit.cover,
                  semanticLabel: '${widget.room.name} image',
                ),
              ),

              Positioned(
                left: 6,
                top: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                  ),
                ),
              ),

              Positioned(
                right: 6,
                top: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final sp = context.read<SavedProvider>();
                        final wasSaved = sp.isSaved(widget.room.id);
                        await sp.toggleSaved(widget.room.id);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              wasSaved
                                  ? 'Removed from Saved'
                                  : 'Added to Saved',
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Failed to toggle save: $e');
                      }
                    },
                    tooltip: isSaved ? 'Unsave' : 'Save',
                  ),
                ),
              ),
            ],
          ),

          // Konten Scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => const Icon(
                              Icons.star,
                              color: starColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '5.0 (120 Reviews)',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Judul Hotel
                    Text(
                      widget.room.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Lokasi Teks
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.room.location,
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Deskripsi
                    Text(
                      'A comfortable stay with great amenities. Price and availability depend on selection.',
                      style: GoogleFonts.inter(fontSize: 14, color: muted),
                    ),
                    const SizedBox(height: 12),
                    // Gallery
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (ctx, idx) {
                          final p = widget.room.assetImage;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SafeAssetImage(
                                p,
                                width: 120,
                                height: 80,
                                fit: BoxFit.cover,
                                semanticLabel: 'photo_$idx',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Features
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _feature(Icons.wifi, 'Free WiFi'),
                        _feature(Icons.kitchen, 'Kitchen'),
                        _feature(Icons.local_parking, 'Parking'),
                        _feature(Icons.ac_unit, 'AC'),
                      ],
                    ),

                    // --- SECTION MAPS ---
                    // Posisinya setelah features, sebelum padding bawah.
                    const SizedBox(height: 24),
                    Text(
                      'Location',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Container Maps
                    Container(
                      height: 180, // Tinggi peta
                      width: double.infinity, // Lebar penuh sesuai parent
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      // Memanggil widget HotelMiniMap yang kita buat
                      child: HotelMiniMap(room: widget.room),
                    ),
                    const SizedBox(height: 8),
                    // Keterangan teks kecil di bawah peta
                    Row(
                      children: [
                        const Icon(Icons.map, size: 14, color: primaryAccent),
                        const SizedBox(width: 6),
                        Text(
                          'Tap map to see details',
                          style: GoogleFonts.inter(fontSize: 12, color: muted),
                        ),
                      ],
                    ),

                    // --- END SECTION MAPS ---
                    const SizedBox(
                      height: 80,
                    ), // Padding bottom agar tidak tertutup tombol bayar
                  ],
                ),
              ),
            ),
          ),

          // Bagian Bawah (Harga & Tombol Select Date)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: bg,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$120/night',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _currency.format(monthlyPrice),
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_navigating) return;
                        _navigating = true;
                        try {
                          final months = await showMonthPickerSheet(context);
                          if (months == null) return;
                          final guests = await showGuestPickerSheet(context);
                          if (guests == null) return;
                          if (!mounted) return;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            try {
                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ConfirmPayScreen(
                                    room: widget.room,
                                    months: months,
                                    guests: guests,
                                  ),
                                ),
                              );
                            } catch (e, st) {
                              debugPrint('Navigation schedule failed: $e\n$st');
                            }
                          });
                        } catch (e, st) {
                          debugPrint('Navigation error: $e\n$st');
                        } finally {
                          _navigating = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Select Date'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData ic, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(ic, color: Colors.white70, size: 18),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.inter(color: Colors.white70)),
    ],
  );
}
