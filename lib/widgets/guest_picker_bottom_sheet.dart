// File: lib/widgets/guest_picker_bottom_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestSelection {
  final int adults;
  final int children;
  final int infants;

  GuestSelection({
    required this.adults,
    required this.children,
    required this.infants,
  });

  int get totalGuests => adults + children + infants;
}

Future<GuestSelection?> showGuestPickerSheet(
  BuildContext context, {
  GuestSelection? initial,
}) {
  initial ??= GuestSelection(adults: 1, children: 0, infants: 0);
  return showModalBottomSheet<GuestSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GuestPickerContent(initial: initial!),
  );
}

class _GuestPickerContent extends StatefulWidget {
  final GuestSelection initial;

  const _GuestPickerContent({required this.initial});

  @override
  State<_GuestPickerContent> createState() => _GuestPickerContentState();
}

class _GuestPickerContentState extends State<_GuestPickerContent> {
  late int adults;
  late int children;
  late int infants;
  bool _didReturn = false;

  @override
  void initState() {
    super.initState();
    adults = widget.initial.adults;
    children = widget.initial.children;
    infants = widget.initial.infants;
  }

  // Kunci batas maksimal kuota kamar (Ide 3)
  bool get _canAdd => (adults + children + infants) < 4;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0F12),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Guest (Max 4)',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    _row(
                      'Adults',
                      'Ages 14 or above',
                      adults,
                      () => setState(() => adults =
                          (adults - 1).clamp(1, 4)), // Minimal 1 Dewasa
                      () {
                        if (_canAdd) setState(() => adults++);
                      },
                    ),
                    const Divider(color: Colors.white12),
                    _row(
                      'Children',
                      'Ages 2-13 (+5% charge)',
                      children,
                      () =>
                          setState(() => children = (children - 1).clamp(0, 4)),
                      () {
                        if (_canAdd) setState(() => children++);
                      },
                    ),
                    const Divider(color: Colors.white12),
                    _row(
                      'Infants',
                      'Under 2 years (Free)',
                      infants,
                      () => setState(() => infants = (infants - 1).clamp(0, 4)),
                      () {
                        if (_canAdd) setState(() => infants++);
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D5CFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: adults < 1
                          ? null
                          : () {
                              if (_didReturn) return;
                              _didReturn = true;
                              Navigator.of(context).pop(
                                GuestSelection(
                                  adults: adults,
                                  children: children,
                                  infants: infants,
                                ),
                              );
                            },
                      child: const Text('Confirm Guests',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String title,
    String subtitle,
    int value,
    VoidCallback onDec,
    VoidCallback onInc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDec,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
          ),
          Text('$value', style: GoogleFonts.inter(color: Colors.white)),
          IconButton(
            onPressed: _canAdd ? onInc : null, // Tombol mati jika sudah 4 orang
            icon: Icon(Icons.add_circle,
                color: _canAdd ? const Color(0xFF5D5CFF) : Colors.white24),
          ),
        ],
      ),
    );
  }
}
