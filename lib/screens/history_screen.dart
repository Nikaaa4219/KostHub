import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/room_provider.dart';
import '../models/booking_record.dart';
import '../widgets/safe_asset_image.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hist = context.watch<HistoryProvider>();
    final rooms = context.read<RoomProvider>().rooms;

    final items = hist.history;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                'History',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFF0B0C10),
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings yet',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.white12),
                        itemBuilder: (ctx, i) {
                          final BookingRecord r = items[i];
                          String roomName;
                          try {
                            roomName = rooms
                                .firstWhere((rm) => rm.id == r.roomId)
                                .name;
                          } catch (_) {
                            roomName = r.roomId;
                          }

                          return ListTile(
                            tileColor: const Color(0xFF0E0F12),
                            leading: (() {
                              try {
                                final rm = rooms.firstWhere(
                                  (rm) => rm.id == r.roomId,
                                );
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SafeAssetImage(
                                    rm.assetImage,
                                    width: 72,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    semanticLabel: '${rm.name} image',
                                  ),
                                );
                              } catch (_) {
                                return Container(
                                  width: 72,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F2130),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                  ),
                                );
                              }
                            }()),
                            title: Text(
                              roomName,
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${r.paymentMethod} • ${r.startDate.toLocal().toIso8601String().split('T').first} - ${r.endDate.toLocal().toIso8601String().split('T').first}\nInvoice: ${r.invoiceId}',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              formatCurrency(r.total),
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('Booking ${r.id}')),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        tooltip: 'Close',
                                        onPressed: () {
                                          // Close the dialog and remain on History screen
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'Room: $roomName\nDates: ${r.startDate.toLocal().toIso8601String().split('T').first} - ${r.endDate.toLocal().toIso8601String().split('T').first}\nGuests: ${r.adults}A ${r.children}C ${r.infants}I\nTotal: ${formatCurrency(r.total)}\nPayment: ${r.paymentMethod}\nInvoice: ${r.invoiceId}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
