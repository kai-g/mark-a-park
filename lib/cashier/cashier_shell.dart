import 'package:flutter/material.dart';
import 'app_state_c.dart';
import 'dashboard_screen_c.dart';
import 'profile_screen_c.dart';

// PLACEHOLDER SCREEN - TO CHANGE
class EntryScreenC extends StatelessWidget {
  const EntryScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("VEHICLE ENTRY - NOT YET BUILT"));
  }
}

// PLACEHOLDER SCREEN - TO CHANGE
class ExitScreenC extends StatelessWidget {
  const ExitScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("VEHICLE EXIT - NOT YET BUILT"));
  }
}

class CashierShell extends StatelessWidget {
  const CashierShell({super.key});

  static const Color kAccentGold = Color(0xFFA98420);
  static const Color kMutedText = Color(0xFF796F43);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppStateC.currentTabIndex,
      builder: (context, tabIndex, _) {
        final pages = const [
          DashboardScreenC(),
          EntryScreenC(),
          ExitScreenC(),
          ProfileScreenC(),
        ];

        return Scaffold(
          body: SafeArea(child: pages[tabIndex]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabIndex,
            onTap: (index) {
              AppStateC.currentTabIndex.value = index;
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: kAccentGold,
            unselectedItemColor: kMutedText,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.login), label: "Entry"),
              BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Exit"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}