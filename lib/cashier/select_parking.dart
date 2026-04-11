import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SelectParkingScreen extends StatefulWidget {
  const SelectParkingScreen({super.key});

  @override
  State<SelectParkingScreen> createState() => _SelectParkingScreenState();
}

class _SelectParkingScreenState extends State<SelectParkingScreen> {

  final DatabaseReference parkingRef =
      FirebaseDatabase.instance.ref("parking/slots");

  final DatabaseReference activeTicketsRef =
      FirebaseDatabase.instance.ref("activeTickets");

  Map<String, String> slots = {
    "A": "vacant",
    "B": "vacant",
    "C": "vacant",
    "D": "vacant",
    "E": "vacant",
    "F": "vacant",
  };

  Set<String> reservedSlots = {};

  static const Color bgYellow = Color(0xFFECC84E);

  @override
  void initState() {
    super.initState();

    // LISTEN SLOT STATUS (vacant/occupied/unavailable)
    parkingRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is! Map) return;

      final map = Map<String, dynamic>.from(data);
      final next = {...slots};

      for (final key in next.keys) {
        final raw = (map[key] ?? "vacant").toString().toLowerCase();
        next[key] = raw;
      }

      setState(() {
        slots = next;
      });
    });

    // LISTEN ACTIVE TICKETS → RESERVED
    activeTicketsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is! Map) {
        setState(() => reservedSlots = {});
        return;
      }

      final map = Map<String, dynamic>.from(data);
      final temp = <String>{};

      for (final value in map.values) {
        final item = Map<String, dynamic>.from(value);

        if (item["status"] == "active") {
          final slot = item["parkingSlot"]?.toString();
          if (slot != null && slot.isNotEmpty) {
            temp.add(slot);
          }
        }
      }

      setState(() {
        reservedSlots = temp;
      });
    });
  }

  Color getColor(String letter, String status) {
    if (status == "occupied") return Colors.red;
    if (status == "unavailable") return Colors.grey;

    // 🔥 RESERVED LOGIC
    if (reservedSlots.contains(letter)) return Colors.yellow;

    return Colors.green;
  }

  bool isSelectable(String letter, String status) {
    if (status != "vacant") return false;

    // 🔥 BLOCK RESERVED
    if (reservedSlots.contains(letter)) return false;

    return true;
  }

  Widget slotBox(String letter) {
    final status = slots[letter] ?? "vacant";

    return Expanded(
      child: GestureDetector(
        onTap: isSelectable(letter, status)
            ? () {
                Navigator.pop(context, letter);
              }
            : null,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: getColor(letter, status),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgYellow,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🔥 HEADER (your requested UI)
                Row(
                  children: [
                    Image.asset(
                      "assets/mark_a_park_app_icon.png",
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Parking",
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

                const SizedBox(height: 20),

                Row(
                  children: [
                    slotBox("A"),
                    const SizedBox(width: 10),
                    slotBox("D"),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    slotBox("B"),
                    const SizedBox(width: 10),
                    slotBox("E"),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    slotBox("C"),
                    const SizedBox(width: 10),
                    slotBox("F"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}