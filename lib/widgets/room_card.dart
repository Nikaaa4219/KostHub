import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room.dart';
import 'safe_asset_image.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final bool compact; // compact = for vertical list
  const RoomCard({super.key, required this.room, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SafeAssetImage(
            room.assetImage,
            width: compact ? 100 : 140,
            height: compact ? 80 : 110,
            fit: BoxFit.cover,
            semanticLabel: '${room.name} image',
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  room.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Color(0xFFFFD166),
                      semanticLabel: 'rating star',
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${room.rating} (${room.reviews})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.white70,
                      semanticLabel: 'location',
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        room.location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${room.price.toStringAsFixed(0)}/night',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
      child: card,
    );
  }
}
