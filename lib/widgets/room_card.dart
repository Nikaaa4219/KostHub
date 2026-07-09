import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room.dart';
import 'safe_asset_image.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final bool compact; // True = List Vertical, False = List Horizontal
  const RoomCard({super.key, required this.room, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // Efek Mewah: Border tipis + Shadow lembut
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar Hotel
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SafeAssetImage(
              room.assetImage,
              width: compact ? 100 : 130,
              height: compact ? 90 : 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Informasi Hotel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    room.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating Star
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFFD166)),
                      const SizedBox(width: 4),
                      Text(
                        '${room.rating} (${room.reviews} reviews)',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF5D5CFF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          room.location,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Harga (Formatted)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${room.price.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5D5CFF), // Warna Aksen
                          ),
                        ),
                        TextSpan(
                          text: '/night',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.white38),
                        ),
                      ],
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
}
