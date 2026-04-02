import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ActiveTicketsScreen extends StatefulWidget {
  const ActiveTicketsScreen({super.key});

  static const Color kGoldBg = Color(0xFFEAF27A);

  @override
  State<ActiveTicketsScreen> createState() => _ActiveTicketsScreenState();
}

class _ActiveTicketsScreenState extends State<ActiveTicketsScreen> {
  String? selectedTicket;

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('activeTickets');

    return Scaffold(
      backgroundColor: ActiveTicketsScreen.kGoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "Active Tickets",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Text(
                        "No active tickets",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    );
                  }

                  final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );

                  final entries = data.entries.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = Map<String, dynamic>.from(entries[index].value);

                      final ticket = item['ticketNumber']?.toString() ?? '';
                      final plate = item['plateNumber']?.toString() ?? '';
                      final time = item['timeEnteredDisplay']?.toString() ?? '';

                      final isSelected = selectedTicket == ticket;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.black54, width: 1.5)
                              : null,
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
                              ticket,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Plate: $plate"),
                            const SizedBox(height: 4),
                            Text("Entry Time: $time"),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedTicket = ticket;
                                  });
                                  Navigator.pop(context, ticket);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF7D66C),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Select Ticket',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}