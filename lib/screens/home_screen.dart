import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_provider.dart';
import 'dashboard_screen.dart';
import 'bin_screen.dart';
import 'statistics_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'janitor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _adminScreens = [
    DashboardScreen(),
    BinScreen(),
    StatisticsScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    // Janitor sees only their single focused screen
    if (!p.isAdmin) return const JanitorScreen();

    return Scaffold(
      body: IndexedStack(index: _index, children: _adminScreens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Dash',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: p.bin?.isOverflowing ?? false,
              child: const Icon(Icons.delete_outline),
            ),
            selectedIcon: const Icon(Icons.delete),
            label: 'Bin',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: p.pendingReports > 0,
              label: Text('${p.pendingReports}'),
              child: const Icon(Icons.description_outlined),
            ),
            selectedIcon: const Icon(Icons.description),
            label: 'Reports',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
