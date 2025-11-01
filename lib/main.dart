import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// no extra imports
import 'dart:async';
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
import 'providers/saved_provider.dart';
import 'providers/room_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/history_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved auth state (migration included) before building the app so the
  // provider starts with persisted authentication state. Clearing recent
  // apps or killing the process will no longer immediately log out users
  // because token is read from secure storage before UI is built.
  final authProvider = await AuthProvider.loadSavedAuth();

  // prepare saved provider & history & notifications before run so UI can read initial state
  final savedProvider = SavedProvider();
  await savedProvider.loadSaved();
  final historyProvider = HistoryProvider();
  await historyProvider.loadHistory();
  final notificationProvider = NotificationProvider();
  await notificationProvider.loadNotifications();

  runApp(
    KostHubApp(
      authProvider: authProvider,
      savedProvider: savedProvider,
      historyProvider: historyProvider,
      notificationProvider: notificationProvider,
    ),
  );
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
        // Provide the already-initialized AuthProvider instance
        ChangeNotifierProvider.value(value: authProvider),
        // preloaded notification provider
        ChangeNotifierProvider.value(value: notificationProvider),
        // use preloaded savedProvider to ensure initial state is available
        ChangeNotifierProvider.value(value: savedProvider),
        // preloaded history provider
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
          '/add_card': (ctx) => const AddCardScreen(),
        },
      ),
    );
  }
}
