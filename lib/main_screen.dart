import 'package:ferrytools/pages/home_page.dart';
import 'package:ferrytools/pages/setting_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      page: const HomePage(),
    ),
    _NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      page: const SettingPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    final currentView = _navigationItems[_currentIndex].page;

    if (isWideScreen) {
      return _DesktopLayout(
        currentIndex: _currentIndex,
        currentView: currentView,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        navigationItems: _navigationItems,
      );
    } else {
      return _MobileLayout(
        currentIndex: _currentIndex,
        currentView: currentView,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        navigationItems: _navigationItems,
      );
    }
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.currentIndex,
    required this.currentView,
    required this.onDestinationSelected,
    required this.navigationItems,
  });

  final int currentIndex;
  final Widget currentView;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavigationItem> navigationItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FerryTools')),
      body: currentView,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onDestinationSelected,
        items: navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.currentIndex,
    required this.currentView,
    required this.onDestinationSelected,
    required this.navigationItems,
  });

  final int currentIndex;
  final Widget currentView;
  final ValueChanged<int> onDestinationSelected;
  final List<_NavigationItem> navigationItems;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('FerryTools')),
      body: Row(
        children: [
          NavigationRail(
            minWidth: 72,
            groupAlignment: -1.0,
            labelType: NavigationRailLabelType.all,
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: navigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          Expanded(child: currentView),
        ],
      ),
    );
  }
}
