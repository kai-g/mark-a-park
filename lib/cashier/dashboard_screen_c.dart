import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app_state_c.dart';

class DashboardScreenC extends StatefulWidget {
  const DashboardScreenC({super.key});

  @override
  State<DashboardScreenC> createState() => _DashboardScreenCState();
}

class _DashboardScreenCState extends State<DashboardScreenC> {

  static const Color kGoldBg = Color(0xFFEAF27A);
  static const Color kPrimaryYellow = Color(0xFFF7D66C);

  // DASHBOARD VALUES
  int carsEnteredToday = 0;
  int carsExitedToday = 0;
  int paidTickets = 0;

  // FIREBASE REFERENCES
  final parkingRef = FirebaseDatabase.instance.ref('parking');
  final transactionsRef = FirebaseDatabase.instance.ref('transactions');
  // ACTIVE TICKETS REF
  final activeTicketsRef = FirebaseDatabase.instance.ref('activeTickets');

  @override
  void initState() {
    super.initState();

    // ACTIVE TICKETS LISTENER (CARS ENTERED)
    activeTicketsRef.onValue.listen((event) {

      if (!event.snapshot.exists) {
        setState(() {
          carsEnteredToday = 0;
        });
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      int count = 0;

      for (final item in data.values) {
        final ticket = Map<String, dynamic>.from(item);

        if (ticket["status"] == "active") {
          count++;
        }
      }

      setState(() {
        carsEnteredToday = count;
      });
    });

    // LISTEN TRANSACTIONS
    transactionsRef.onValue.listen((event) {

      if (!event.snapshot.exists) {
        setState(() {
          paidTickets = 0;
        });
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      int completedCount = 0;

      for (final item in data.values) {
        final tx = Map<String, dynamic>.from(item);

        if (tx["status"] == "completed") {
          completedCount++;
        }
      }

      setState(() {
        carsExitedToday = completedCount;
        paidTickets = completedCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/mark_a_park_app_icon.png",
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Cashier Dashboard",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "MARK-A-PARK",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  "WELCOME, CASHIER",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "ENTRY AND EXIT OVERVIEW",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  title: "Quick Overview",
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.login,
                        iconColor: Colors.blue,
                        label: "Cars Entered Today",
                        value: carsEnteredToday.toString(), // UPDATED VALUE
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        label: "Cars Exited Today",
                        value: carsExitedToday.toString(), // UPDATED VALUE
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.payments,
                        iconColor: Colors.green,
                        label: "Paid Tickets",
                        value: paidTickets.toString(), // UPDATED VALUE
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  title: "Cashier Actions",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        _CashierButton(
                          icon: Icons.confirmation_number,
                          label: "Vehicle Entry",
                          color: kPrimaryYellow,
                          onTap: () {
                            AppStateC.currentTabIndex.value = 1;
                          },
                        ),
                        const SizedBox(height: 10),
                        _CashierButton(
                          icon: Icons.receipt_long,
                          label: "Vehicle Exit",
                          color: kPrimaryYellow,
                          onTap: () {
                            AppStateC.currentTabIndex.value = 2;
                          },
                        ),
                        const SizedBox(height: 10),
                        _CashierButton(
                          icon: Icons.history,
                          label: "Transaction History",
                          color: kPrimaryYellow,
                          onTap: () {
                            AppStateC.currentTabIndex.value = 3;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.black12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CashierButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CashierButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}