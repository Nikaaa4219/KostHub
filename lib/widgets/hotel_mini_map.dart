// File: lib/widgets/hotel_mini_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Versi 6
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/room.dart';

class HotelMiniMap extends StatelessWidget {
  final Room room;

  const HotelMiniMap({super.key, required this.room});

  Future<void> _openGoogleMaps() async {
    // PERBAIKAN UTAMA: Menggunakan URL Scheme Resmi Google Maps
    // Format ini (api=1&query=lat,long) adalah standar resmi Google.
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${room.latitude},${room.longitude}',
    );

    try {
      // Coba buka aplikasi maps eksternal
      if (!await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        // Fallback ke browser jika gagal
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerLocation = LatLng(room.latitude, room.longitude);

    return GestureDetector(
      onTap: _openGoogleMaps,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // AbsorbPointer agar peta statis (tidak geser)
            AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: centerLocation,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.kosthub',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: centerLocation,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF5D5CFF),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0B0C10).withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
