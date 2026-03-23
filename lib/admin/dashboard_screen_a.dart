import 'package:flutter/material.dart';

class DashboardScreenA extends StatelessWidget {
  const DashboardScreenA({super.key});

  static const Color kGoldBg = Color(0xFFEAF27A);
  static const Color kPrimaryYellow = Color(0xFFF7D66C);
  static const Color kAccentGold = Color(0xFFA98420);

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
                          "Admin Dashboard",
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
                  "WELCOME, ADMIN",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "SYSTEM OVERVIEW",
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
                    children: const [
                      SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.directions_car,
                        iconColor: Color(0xFFF7D66C),
                        label: "Total Capacity",
                        value: "6",
                      ),
                      SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.circle,
                        iconColor: Colors.red,
                        label: "Occupied Slots",
                        value: "0",
                      ),
                      SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.circle,
                        iconColor: Colors.green,
                        label: "Vacant Slots",
                        value: "6",
                      ),
                      SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.people,
                        iconColor: Colors.blue,
                        label: "Total Users",
                        value: "0",
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  title: "Admin Controls",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        _AdminButton(
                          icon: Icons.map,
                          label: "Parking Monitoring",
                          color: kPrimaryYellow,
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _AdminButton(
                          icon: Icons.manage_accounts,
                          label: "Manage Accounts",
                          color: kPrimaryYellow,
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),
                        _AdminButton(
                          icon: Icons.build,
                          label: "Slot Maintenance",
                          color: kPrimaryYellow,
                          onTap: () {},
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

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminButton({
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