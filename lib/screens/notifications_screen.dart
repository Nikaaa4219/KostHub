import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Clear unread badge when opening notifications (best-effort)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<NotificationProvider>().clear();
      } catch (_) {
        // provider not available - ignore
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;

    return Scaffold(
      body: Container(
        color: const Color(0xFF5D5CFF),
        child: SafeArea(
          child: Column(
            children: [
              // App bar with back button
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Notifications',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Empty space to balance the back button
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Content area
              Expanded(
                child: Container(
                  color: const Color(0xFF1A1A1A), // Match the dark theme
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'No notifications yet',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white12),
                          itemBuilder: (ctx, i) {
                            final it = items[i];
                            final isBooking =
                                it.containsKey('roomId') ||
                                it.containsKey('invoiceId');
                            final title =
                                (it['title'] ??
                                        (isBooking
                                            ? 'Booking confirmed'
                                            : 'Notification'))
                                    as String;
                            final body =
                                (it['body'] ??
                                        (isBooking
                                            ? 'You have a new booking'
                                            : ''))
                                    as String;
                            final tsRaw = it['timestamp'] as String?;
                            final ts = tsRaw != null
                                ? DateTime.tryParse(tsRaw)
                                : null;
                            return ListTile(
                              tileColor: const Color(0xFF0E0F12),
                              title: Text(
                                title,
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                              subtitle: Text(
                                '$body${ts != null ? ' • ${ts.toLocal().toIso8601String().split('T').first}' : ''}',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                // Show a dialog; closing it should keep the user on
                                // the Notifications screen (no further navigation).
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(title),
                                    content: Text(body),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Only close the dialog and remain on
                                          // the Notifications screen as requested.
                                          Navigator.of(ctx).pop();
                                        },
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
      ),
    );
  }
}
