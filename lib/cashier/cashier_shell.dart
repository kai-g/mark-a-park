import 'package:flutter/material.dart';
import 'app_state_c.dart';
import 'dashboard_screen_c.dart';
import 'entry.dart';
import 'exit.dart';
import 'transaction_history.dart';
import 'profile_screen_c.dart';

// PLACEHOLDER SCREEN - TO CHANGE
class EntryScreenC extends StatelessWidget {
  const EntryScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return const EntryScreen();
  }
}

// PLACEHOLDER SCREEN - TO CHANGE
class ExitScreenC extends StatelessWidget {
  const ExitScreenC({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExitScreen();
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
          TransactionHistoryScreen(),
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.login), label: "Entry"),
              BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Exit"),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}