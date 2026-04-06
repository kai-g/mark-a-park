import 'package:flutter/material.dart';
import 'app_state_a.dart';
import 'dashboard_screen_a.dart';
import 'profile_screen_a.dart';
import 'monitoring_a.dart';
import 'accounts.dart';
import 'maintenance.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  static const Color kAccentGold = Color(0xFFA98420);
  static const Color kMutedText = Color(0xFF796F43);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppStateA.currentTabIndex,
      builder: (context, tabIndex, _) {
        final pages = const [
          DashboardScreenA(),
          MonitoringScreenA(),
          AccountsScreenA(),
          MaintenanceScreenA(),
          ProfileScreenA(),
        ];

        return Scaffold(
          body: SafeArea(child: pages[tabIndex]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabIndex,
            onTap: (index) {
              AppStateA.currentTabIndex.value = index;
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: kAccentGold,
            unselectedItemColor: kMutedText,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Monitoring"),
              BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: "Accounts"),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: "Maintenance"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}