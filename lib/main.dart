import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/main_shell.dart';
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

Future<void> main() async {
  // Wajib ada agar Firebase bisa jalan sebelum UI muncul
  WidgetsFlutterBinding.ensureInitialized();

  // -- INISIALISASI FIREBASE --
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  // ---------------------------

  runApp(
    const MaterialApp(home: BootLoader(), debugShowCheckedModeBanner: false),
  );
}

class BootLoader extends StatefulWidget {
  const BootLoader({super.key});

  @override
  State<BootLoader> createState() => _BootLoaderState();
}

class _BootLoaderState extends State<BootLoader> {
  String _status = 'Starting...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      setState(() => _status = 'Loading auth...');
      final authProvider = await AuthProvider.loadSavedAuth();

      setState(() => _status = 'Loading saved...');
      final savedProvider = SavedProvider();
      await savedProvider.loadSaved();

      setState(() => _status = 'Loading history...');
      final historyProvider = HistoryProvider();
      await historyProvider.loadHistory();

      setState(() => _status = 'Loading notifications...');
      final notificationProvider = NotificationProvider();
      await notificationProvider.loadNotifications();

      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => KostHubApp(
            authProvider: authProvider,
            savedProvider: savedProvider,
            historyProvider: historyProvider,
            notificationProvider: notificationProvider,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('BootLoader init failed: $e\n$st');
      if (!mounted) return;
      final authProvider2 = await AuthProvider.loadSavedAuth();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => KostHubApp(
            authProvider: authProvider2,
            savedProvider: SavedProvider(),
            historyProvider: HistoryProvider(),
            notificationProvider: NotificationProvider(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/PNG-KostHub/Logo_SplashScreen.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 18),
              Text(_status, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class KostHubApp extends StatelessWidget {
  final AuthProvider authProvider;
  final SavedProvider savedProvider;
  final HistoryProvider historyProvider;
  final NotificationProvider notificationProvider;

  const KostHubApp({
    super.key,
    required this.authProvider,
    required this.savedProvider,
    required this.historyProvider,
    required this.notificationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: savedProvider),
        ChangeNotifierProvider.value(value: historyProvider),
      ],
      child: MaterialApp(
        title: 'KostHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/login': (ctx) => const LoginScreen(),
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
            );
          },
        },
      ),
    );
  }
}
