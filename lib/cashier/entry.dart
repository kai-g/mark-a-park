import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../auth/session.dart';

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

  String selectedVehicleType = 'Car';

  bool isSaving = false;

  final List<String> vehicleTypes = const [
    'Car',
    'Motorcycle',
    'SUV',
    'Van',
    'Pickup',
    'Truck',
  ];

  String getPlatePrefix(String plate) {
    final clean = plate.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean.length >= 3) {
      return clean.substring(0, 3);
    }
    return clean.padRight(3, 'X');
  }

  String formatTicketDate(DateTime dt) {
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year.toString().substring(2);
    return '$month$day$year';
  }

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

  Future<int> getTodayTicketCount() async {
    final dateKey = formatTicketDate(DateTime.now());
    int count = 0;

    final activeSnapshot =
        await FirebaseDatabase.instance.ref('activeTickets').get();
    if (activeSnapshot.exists && activeSnapshot.value is Map) {
      final activeData = Map<String, dynamic>.from(activeSnapshot.value as Map);
      for (final value in activeData.values) {
        final item = Map<String, dynamic>.from(value);
        final ticket = item['ticketNumber']?.toString() ?? '';
        if (ticket.contains('-$dateKey-')) {
          count++;
        }
      }
    }

    final transactionSnapshot =
        await FirebaseDatabase.instance.ref('transactions').get();
    if (transactionSnapshot.exists && transactionSnapshot.value is Map) {
      final transactionData =
          Map<String, dynamic>.from(transactionSnapshot.value as Map);
      for (final value in transactionData.values) {
        final item = Map<String, dynamic>.from(value);
        final ticket = item['ticketNumber']?.toString() ?? '';
        if (ticket.contains('-$dateKey-')) {
          count++;
        }
      }
    }

    return count + 1;
  }

  Future<String> generateTicketNumber(String plateNumber) async {
    final now = DateTime.now();
    final prefix = getPlatePrefix(plateNumber);
    final datePart = formatTicketDate(now);
    final count = await getTodayTicketCount();
    final countPart = count.toString().padLeft(2, '0');

    return '$prefix-$datePart-$countPart';
  }

  Future<void> saveEntry() async {
    final plateNumber = plateController.text.trim().toUpperCase();
    final notes = notesController.text.trim();

    if (plateNumber.isEmpty) {
      showMessage('Please enter plate number.');
      return;
    }

    setState(() => isSaving = true);

    try {
      final now = DateTime.now();
      final ticketNumber = await generateTicketNumber(plateNumber);

      final activeTicketRef =
          FirebaseDatabase.instance.ref('activeTickets').push();

      await activeTicketRef.set({
        'ticketNumber': ticketNumber,
        'plateNumber': plateNumber,
        'vehicleType': selectedVehicleType,
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
              Text('Ticket Number: $ticketNumber'),
              const SizedBox(height: 8),
              Text('Plate Number: $plateNumber'),
              const SizedBox(height: 8),
              Text('Vehicle Type: $selectedVehicleType'),
              const SizedBox(height: 8),
              Text('Time Entered: ${formatDateTime(now)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                plateController.clear();
                notesController.clear();
                setState(() {
                  selectedVehicleType = 'Car';
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
                //const SizedBox(height: 14),
                //const SizedBox(height: 3),
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
                        DropdownButtonFormField<String>(
                          value: selectedVehicleType,
                          decoration: inputDecoration(
                            hint: "Vehicle Type",
                            icon: Icons.local_shipping_outlined,
                          ),
                          items: vehicleTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedVehicleType = value;
                            });
                          },
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
                        const SizedBox(height: 10),
                        const _ReadOnlyRow(
                          label: "Ticket Number",
                          value: "Auto-generated after save",
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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