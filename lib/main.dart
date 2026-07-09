import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/hotel_detail_screen.dart';
import 'models/room.dart';
import 'screens/add_card_screen.dart';
import 'widgets/date_picker_bottom_sheet.dart';
import 'widgets/guest_picker_bottom_sheet.dart';
import 'providers/saved_provider.dart';
import 'providers/room_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/history_provider.dart';
import 'common/info.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';

// === APP INITIALIZATION ===
// Menyiapkan engine Flutter dan koneksi Firebase sebelum UI mulai digambar
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  runApp(const KostHubApp());
}

class KostHubApp extends StatefulWidget {
  const KostHubApp({super.key});

  @override
  State<KostHubApp> createState() => _KostHubAppState();
}

class _KostHubAppState extends State<KostHubApp> {
  // == STATE VARIABLES ==
  // State untuk menyimpan provider setelah selesai dimuat
  AuthProvider? _authProvider;
  SavedProvider? _savedProvider;
  HistoryProvider? _historyProvider;
  NotificationProvider? _notificationProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  // === STATE MANAGEMENT ===
  // Memuat data otentikasi dan riwayat dari penyimpanan lokal sebelum masuk aplikasi
  Future<void> _loadProviders() async {
    try {
      final auth = await AuthProvider.loadSavedAuth();
      final saved = SavedProvider();
      await saved.loadSaved();
      final history = HistoryProvider();
      await history.loadHistory();
      final notif = NotificationProvider();
      await notif.loadNotifications();

      if (mounted) {
        setState(() {
          _authProvider = auth;
          _savedProvider = saved;
          _historyProvider = history;
          _notificationProvider = notif;
          _isInitialized = true;
        });
      }
    } catch (e, st) {
      debugPrint('Init Failed: $e\n$st');
      // Fallback jika terjadi error muat data
      if (mounted) {
        setState(() {
          _authProvider = AuthProvider.loadSavedAuth() as AuthProvider?;
          _savedProvider = SavedProvider();
          _historyProvider = HistoryProvider();
          _notificationProvider = NotificationProvider();
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/PNG-KostHub/Logo_SplashScreen.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 18),
                const CircularProgressIndicator(color: Color(0xFF5D5CFF)),
                const SizedBox(height: 18),
                const Text('Starting system...',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      );
    }

    // === STATE MANAGEMENT ===
    // JIKA PROVIDER SIAP, JALANKAN APLIKASI UTAMA (HANYA ADA 1 MATERIAL APP)
    // MultiProvider memastikan data dapat diakses dari layar manapun
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider.value(value: _authProvider!),
        ChangeNotifierProvider.value(value: _notificationProvider!),
        ChangeNotifierProvider.value(value: _savedProvider!),
        ChangeNotifierProvider.value(value: _historyProvider!),
      ],
      child: MaterialApp(
        title: 'KostHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),

        // === NAVIGATION ===
        // Kunci Navigasi Utama untuk mengontrol SnackBar dan rute dari luar widget UI
        navigatorKey: Info.navigatorKey,
        scaffoldMessengerKey: Info.scaffoldMessengerKey,

        // === NAVIGATION ===
        // Peta rute deklaratif aplikasi KostHub
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/signin': (ctx) => const SigninPage(),
          '/signup': (ctx) => const SignupPage(),
          '/discover': (ctx) => const MainShell(),
          '/home': (ctx) => const HomeScreen(),
          '/search': (ctx) => const SearchScreen(),
          '/profile': (ctx) => const ProfileScreen(),
          '/edit_profile': (ctx) => const EditProfileScreen(),
          '/saved': (ctx) => const SizedBox.shrink(),
          '/confirm_pay': (ctx) => const SizedBox.shrink(),
          '/shell': (ctx) => const MainShell(),
          '/hotel_detail': (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments as Room?;
            if (args == null) return const SizedBox.shrink();
            return HotelDetailScreen(room: args);
          },
          '/add_card': (ctx) {
            final args =
                ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
            if (args == null) return const SizedBox.shrink();
            return AddCardScreen(
              total: args['total'] as int,
              room: args['room'] as Room,
              months: args['months'] as MonthsSelection,
              guests: args['guests'] as GuestSelection,
              selectedRoomDetail:
                  args['selectedRoomDetail'] as String? ?? "Standard Room",
            );
          },
        },
      ),
    );
  }
}
