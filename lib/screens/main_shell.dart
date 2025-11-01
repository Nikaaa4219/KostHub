import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';

/// MainShell: hosts the main app pages inside a PageView and a single
/// BottomNavigationBar so switching tabs is smooth and the bottom bar
/// doesn't re-create between pages.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  /// Helper to navigate to the shell with a specific tab index.
  static void navigateTo(BuildContext context, int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainShell(initialIndex: index)),
    );
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final PageController _controller;
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build pages lazily here so imports resolve widgets properly.
    _pages.clear();
    _pages.addAll([
      const HomeScreen(),
      // Saved screen shows saved rooms from SavedProvider
      const SavedScreen(),
      // Search is opened as a separate full-screen route (no bottom nav).
      Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
          child: const Text('Open Search'),
        ),
      ),
      const Center(
        child: Text('History', style: TextStyle(color: Colors.white)),
      ),
      const ProfileScreen(),
    ]);
  }

  void _onTap(int index) {
    if (index == 2) {
      // Open Search as a separate full-screen route without the bottom nav.
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
      return;
    }
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
