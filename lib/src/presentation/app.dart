import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../features/home/home.dart';
import '../features/library/library.dart';
import '../features/reciters/reciters.dart';
import '../features/settings/settings.dart';
import 'app_lifecycle_listener.dart';

/// Main QLearner app widget
class QLearnerApp extends ConsumerWidget {
  const QLearnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'QLearner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainNavigation(),
    );
  }
}

/// Main navigation with 4-tab bottom nav and IndexedStack
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.library_books_outlined,
      label: 'Library',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      label: 'Reciters',
    ),
    BottomNavItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  static const List<Widget> _screens = [
    HomeScreen(),
    LibraryScreen(),
    RecitersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
