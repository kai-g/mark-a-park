import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../auth/session.dart';
import 'select_parking.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  static const Color kGoldBg = Color(0xFFEAF27A);
  static const Color kPrimaryYellow = Color(0xFFF7D66C);

  final TextEditingController plateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? selectedSlot;

  bool isSaving = false;

  String formatDateTime(DateTime dt) {
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year.toString();
    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$month/$day/$year  $hour:$minute $suffix';
  }

  Future<void> saveEntry() async {
    final plateNumber = plateController.text.trim().toUpperCase();
    final notes = notesController.text.trim();

    if (plateNumber.isEmpty) {
      showMessage('Please enter plate number.');
      return;
    }

    if (selectedSlot == null) {
      showMessage('Please select a parking slot.');
      return;
    }

    setState(() => isSaving = true);

    try {
      final now = DateTime.now();

      final activeTicketRef =
          FirebaseDatabase.instance.ref('activeTickets').push();

      await activeTicketRef.set({
        'plateNumber': plateNumber,
        'parkingSlot': selectedSlot,
        'timeEntered': now.toIso8601String(),
        'timeEnteredDisplay': formatDateTime(now),
        'entryCashierId': Session.userKey ?? '',
        'entryCashierName': Session.username ?? 'Cashier',
        'notes': notes,
        'status': 'active',
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Entry Saved'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plate Number: $plateNumber'),
              const SizedBox(height: 8),
              Text('Parking Slot: $selectedSlot'),
              const SizedBox(height: 8),
              Text('Time Entered: ${formatDateTime(now)}'),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: $notes'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                plateController.clear();
                notesController.clear();
                setState(() {
                  selectedSlot = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showMessage('Failed to save entry: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black45),
      ),
    );
  }

  @override
  void dispose() {
    plateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = formatDateTime(DateTime.now());

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
                          "Vehicle Entry",
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

                _CardBox(
                  title: "Vehicle Information",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        TextField(
                          controller: plateController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: inputDecoration(
                            hint: "Plate Number",
                            icon: Icons.directions_car_outlined,
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SelectParkingScreen(),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  selectedSlot = result;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_parking_outlined, color: Colors.black),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedSlot == null
                                          ? "Select Parking"
                                          : "Slot Selected: $selectedSlot",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: inputDecoration(
                            hint: "Notes (optional)",
                            icon: Icons.note_alt_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _CardBox(
                  title: "Entry Details",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        _ReadOnlyRow(
                          label: "Cashier",
                          value: Session.username ?? 'Cashier',
                        ),
                        const SizedBox(height: 10),
                        _ReadOnlyRow(
                          label: "Time Entered",
                          value: now,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      isSaving ? 'Saving...' : 'Save Entry',
                      style: const TextStyle(fontWeight: FontWeight.w800),
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

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}