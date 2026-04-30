import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellPage extends StatelessWidget {
  final Widget child;

  const MainShellPage({super.key, required this.child});

  static const _tabs = [
    _BottomTab(
      path: '/home',
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _BottomTab(
      path: '/history',
      label: 'History',
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
    ),
    _BottomTab(
      path: '/leave',
      label: 'Leave',
      icon: Icons.event_available_outlined,
      activeIcon: Icons.event_available,
    ),
    _BottomTab(
      path: '/profile',
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final index = _tabs.indexWhere((tab) => location.startsWith(tab.path));

    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          context.go(_tabs[index].path);
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _BottomTab {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _BottomTab({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
