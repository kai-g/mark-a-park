import 'package:flutter/material.dart';
import 'app_state.dart';
import 'home_screen.dart';
import 'venue_screen.dart';
import 'monitoring_screen.dart';
import 'account_screen.dart';

// PLACEHOLDER SCREEN - TO CHANGE
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("ABOUT SCREEN - NOT YET BUILT"));
}

class UserShell extends StatelessWidget {
  const UserShell({super.key});

  static const Color kAccentGold = Color(0xFFA98420);
  static const Color kMutedText = Color(0xFF796F43);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.currentTabIndex,
      builder: (context, tabIndex, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppState.isVenueSelected,
          builder: (context, venueSelected, __) {
            final pages = [
              venueSelected ? const VenueScreen() : const HomeScreen(),
              const AboutScreen(),
              const MonitoringScreen(),
              const AccountScreen(),
            ];

            return Scaffold(
              body: SafeArea(child: pages[tabIndex]),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: tabIndex,
                onTap: (index) {
                  AppState.currentTabIndex.value = index;
                  if (index == 0) {
                    AppState.isVenueSelected.value = false;
                  }
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: kAccentGold,
                unselectedItemColor: kMutedText,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "About"),
                  BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Monitoring"),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
                ],
              ),
            );
          },
        );
      },
    );
  }
}