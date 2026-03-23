import 'package:flutter/material.dart';
import 'app_state_a.dart';
import 'dashboard_screen_a.dart';
import 'profile_screen_a.dart';

// PLACEHOLDER SCREEN - TO CHANGE
class MonitoringScreenA extends StatelessWidget {
  const MonitoringScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("ADMIN MONITORING - NOT YET BUILT"));
  }
}

// PLACEHOLDER SCREEN - TO CHANGE
class AccountsScreenA extends StatelessWidget {
  const AccountsScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("ADMIN ACCOUNTS - NOT YET BUILT"));
  }
}

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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Monitoring"),
              BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: "Accounts"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}