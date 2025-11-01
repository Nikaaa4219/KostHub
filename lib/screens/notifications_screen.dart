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
                  child: Center(
                    child: Text(
                      'No notifications yet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
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
