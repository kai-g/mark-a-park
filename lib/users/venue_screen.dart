import 'package:flutter/material.dart';
import 'monitoring_screen.dart';
import 'app_state.dart';

class VenueScreen extends StatelessWidget {
  const VenueScreen({super.key});

  // PALETTE
  static const Color kPrimaryYellow = Color(0xFFF7D66C);
  static const Color kAccentGold = Color(0xFFA98420);
  static const Color kDarkText = Color(0xFF2E2A1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER IMAGE + TITLE
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // PLACEHOLDER IMAGE - TO CHANGE
                    Image.asset(
                      "assets/placeholder_img.jpg",
                      fit: BoxFit.cover,
                    ),
                    Container(color: Colors.black.withOpacity(0.25)),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "MARK-A-PARK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Make Smart Parking Decisions",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Mark-A-Park",
                        style: TextStyle(
                          color: kAccentGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      "Select where to park",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryYellow,
                          foregroundColor: kDarkText,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
  // DIRECTS TO THE MONITORING TAB - TO CHANGE
  AppState.currentTabIndex.value = 2;
},
                        child: const Text(
                          "Hotel",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "This hotel was established on XXXX and is owned by the Y company located on Z address.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}