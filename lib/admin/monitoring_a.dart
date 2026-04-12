import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MonitoringScreenA extends StatefulWidget {
  const MonitoringScreenA({super.key});

  @override
  State<MonitoringScreenA> createState() => _MonitoringScreenAState();
}

class _MonitoringScreenAState extends State<MonitoringScreenA> {
  // ACTIVE TICKETS MAP
Map<String, bool> activeTicketSlots = {};
  final DatabaseReference parkingRef = FirebaseDatabase.instance.ref("parking");

  static const int totalCapacity = 6;

  int carsEntered = 0;

  Map<String, String> slots = const {
    "A": "vacant",
    "B": "vacant",
    "C": "vacant",
    "D": "vacant",
    "E": "vacant",
    "F": "vacant",
  };

  @override
  void initState() {
    super.initState();

    parkingRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is! Map) return;

      final map = Map<String, dynamic>.from(data);

      final ce = map["carsEntered"];
      final nextCarsEntered = (ce is int) ? ce : int.tryParse("$ce") ?? 0;

      final nextSlots = <String, String>{...slots};
      final slotData = map["slots"];
      if (slotData is Map) {
        final slotMap = Map<String, dynamic>.from(slotData);
        for (final key in nextSlots.keys) {
          final raw = (slotMap[key] ?? "vacant").toString().toLowerCase();
          // SUPPORT VACANT / OCCUPIED / UNAVAILABLE
          if (raw == "occupied") {
            nextSlots[key] = "occupied";
          } else if (raw == "unavailable") {
            nextSlots[key] = "unavailable";
          } else {
            nextSlots[key] = "vacant";
          }
        }
      }
      // ACTIVE TICKETS LISTENER
      FirebaseDatabase.instance.ref("activeTickets").onValue.listen((event) {
        final data = event.snapshot.value;

        final Map<String, bool> next = {};

        if (data is Map) {
          final map = Map<String, dynamic>.from(data);

          for (final item in map.values) {
            final ticket = Map<String, dynamic>.from(item);

            if (ticket["status"] == "active") {
              final slot = ticket["parkingSlot"];
              if (slot != null) {
                next[slot] = true;
              }
            }
          }
        }

        setState(() {
          activeTicketSlots = next;
        });
      });

      setState(() {
        carsEntered = nextCarsEntered;
        slots = nextSlots;
      });
    });
  }

  int get occupiedCount =>
      slots.values.where((v) => v.toLowerCase() == "occupied").length;

  int get vacantCount => totalCapacity - occupiedCount;

  String get interpretationText {
    if (carsEntered == 0) return "Completely Vacant";
    if (carsEntered >= 1 && carsEntered <= 2) return "Many Vacant";
    if (carsEntered == 3) return "Half Full";
    if (carsEntered >= 4 && carsEntered <= 5) return "Almost Full";
    if (carsEntered == 6) return "Full";
    return "Overloaded";
  }

  // PALETTE
  static const Color kGoldBg = Color(0xFFEAF27A);
  //static const Color kCardShadow = Color(0x22000000);

  static const Color kPrimaryYellow = Color(0xFFF7D66C);
  static const Color kAccentGold = Color(0xFFA98420);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = kGoldBg;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                          "Monitoring",
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
                //const SizedBox(height: 12),
                
                const SizedBox(height: 3),
                const Text(
                  "PARKING OVERVIEW",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                _CardBox(
                  title: "Status",
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _StatusRow(
                        icon: Icons.directions_car,
                        iconColor: kPrimaryYellow,
                        label: "Total Capacity",
                        value: "$totalCapacity",
                        valueColor: kAccentGold,
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        icon: Icons.login,
                        iconColor: Colors.blue,
                        label: "Total Cars Entered",
                        value: "$carsEntered",
                        valueColor: Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        icon: Icons.circle,
                        iconColor: Colors.red,
                        label: "Occupied Slots",
                        value: "$occupiedCount",
                        valueColor: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        icon: Icons.circle,
                        iconColor: Colors.green,
                        label: "Vacant Slots",
                        value: "$vacantCount",
                        valueColor: Colors.green,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  title: "Slots",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child:
                            _SlotPill(
                              letter: "A",
                              status: slots["A"] ?? "vacant",
                              hasActiveTicket: activeTicketSlots["A"] == true,
                            )
                            ),
                            const SizedBox(width: 10),
                            Expanded(child:
                            _SlotPill(
                              letter: "D",
                              status: slots["D"] ?? "vacant",
                              hasActiveTicket: activeTicketSlots["D"] == true,
                            )
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child:
                            _SlotPill(
                              letter: "B",
                              status: slots["B"] ?? "vacant",
                              hasActiveTicket: activeTicketSlots["B"] == true,
                            )),
                            const SizedBox(width: 10),
                            Expanded(child:
                            _SlotPill(
                              letter: "E",
                              status: slots["E"] ?? "vacant",
                              hasActiveTicket: activeTicketSlots["E"] == true,
                            )),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child:
                            _SlotPill(
                              letter: "C",
                              status: slots["C"] ?? "vacant",
                              hasActiveTicket: activeTicketSlots["C"] == true,
                            )),
                            const SizedBox(width: 10),
                            Expanded(child:
                            _SlotPill(
                              letter: "F",
                              status: slots["F"] ?? "vacant",
                              hasActiveTicket: activeTicketSlots["F"] == true,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _InterpretationBox(
                  text: interpretationText,
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
          )
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

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatusRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
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
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SlotPill extends StatelessWidget {
  final String letter;
  final String status;
  final bool hasActiveTicket;

  const _SlotPill({
    required this.letter,
    required this.status,
    required this.hasActiveTicket,
  });

  // SHOW ADMIN SLOT OPTIONS
void _showSlotOptions(BuildContext context, String slot, String status, bool hasActiveTicket) {
  final ref = FirebaseDatabase.instance.ref("parking/slots/$slot");

  // ACTIVE TICKETS REF
  final ticketsRef = FirebaseDatabase.instance.ref("activeTickets");

  // FORMAT DURATION
  String formatDuration(DateTime start) {
    final diff = DateTime.now().difference(start);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return "${h}h ${m}m";
  }

  final s = status.toLowerCase();

  // CHECK IF RESERVED (VACANT + ACTIVE TICKET)
  final bool isTaken = s == "vacant" && hasActiveTicket;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          isTaken
              ? "SLOT $slot: Taken"
              : "SLOT $slot: ${s[0].toUpperCase()}${s.substring(1)}",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // TAKEN SLOT (RESERVED)
            if (isTaken) ...[
              FutureBuilder(
                future: ticketsRef.get(),
                builder: (context, snapshot) {
                  String plate = "N/A";
                  String timeDisplay = "N/A";

                  if (snapshot.hasData && snapshot.data!.value != null) {
                    final data = Map<String, dynamic>.from(snapshot.data!.value as Map);

                    for (final item in data.values) {
                      final map = Map<String, dynamic>.from(item);

                      if (map["parkingSlot"] == slot && map["status"] == "active") {
                        plate = map["plateNumber"] ?? "N/A";
                        timeDisplay = map["timeEnteredDisplay"] ?? "N/A";
                        break;
                      }
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Slot currently taken: $plate",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Entry Time: $timeDisplay",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: null,
                        child: const Text("Disable Parking Slot"),
                      ),
                    ],
                  );
                },
              ),
            ],

            // VACANT SLOT
            if (s == "vacant" && !isTaken)
              ElevatedButton(
                onPressed: () async {
                  await ref.set("unavailable");
                  Navigator.pop(context);
                },
                child: const Text("Disable Parking Slot"),
              ),

            // OCCUPIED SLOT
            if (s == "occupied") ...[
              FutureBuilder(
                future: ticketsRef.get(),
                builder: (context, snapshot) {
                  String plate = "N/A";
                  String timeDisplay = "N/A";
                  String duration = "N/A";

                  if (snapshot.hasData && snapshot.data!.value != null) {
                    final data = Map<String, dynamic>.from(snapshot.data!.value as Map);

                    for (final item in data.values) {
                      final map = Map<String, dynamic>.from(item);

                      if (map["parkingSlot"] == slot && map["status"] == "active") {
                        plate = map["plateNumber"] ?? "N/A";
                        timeDisplay = map["timeEnteredDisplay"] ?? "N/A";

                        final rawTime = map["timeEntered"];
                        if (rawTime != null) {
                          final dt = DateTime.tryParse(rawTime);
                          if (dt != null) {
                            duration = formatDuration(dt);
                          }
                        }
                        break;
                      }
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Slot currently occupied: $plate",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Entry Time: $timeDisplay",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Current Duration: $duration",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: null,
                        child: const Text("Disable Parking Slot"),
                      ),
                    ],
                  );
                },
              ),
            ],

            // UNAVAILABLE SLOT
            if (s == "unavailable")
              ElevatedButton(
                onPressed: () async {
                  await ref.set("vacant");
                  Navigator.pop(context);
                },
                child: const Text("Enable Parking Slot"),
              ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final bool isOccupied = s == "occupied";
    final bool isUnavailable = s == "unavailable";

    Color bg;
    String label;

    if (isOccupied) {
      bg = Colors.red;
      label = "Occupied";
    } else if (isUnavailable) {
      bg = Colors.grey;
      label = "Unavailable";
    } else if (hasActiveTicket) {
      bg = Colors.yellow;
      label = "Taken";
    } else {
      bg = Colors.green;
      label = "Vacant";
    }

    return GestureDetector(
  onTap: () {
    _showSlotOptions(context, letter, status, hasActiveTicket);
  },
  child: Container(
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            letter,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
  ),
    );
  }
}

class _InterpretationBox extends StatelessWidget {
  final String text;

  const _InterpretationBox({required this.text});

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
          const Text(
            "Interpretation",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}