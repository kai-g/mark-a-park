import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../auth/session.dart';
import 'active_tickets.dart';

class ExitScreen extends StatefulWidget {
  const ExitScreen({super.key});

  @override
  State<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  static const Color kGoldBg = Color(0xFFEAF27A);
  static const Color kPrimaryYellow = Color(0xFFF7D66C);

  final TextEditingController plateController = TextEditingController();
  final TextEditingController cashReceivedController = TextEditingController();

  bool isSearching = false;
  bool isProcessing = false;

// PAYMENT TYPE
String paymentType = 'regular';

  String? activeTicketKey;
  Map<String, dynamic>? activeTicketData;

  Future<void> findTicket() async {
    final plateNumber = plateController.text.trim().toUpperCase();

    if (plateNumber.isEmpty) {
      showMessage('Please enter plate number.');
      return;
    }

    setState(() {
      isSearching = true;
      activeTicketKey = null;
      activeTicketData = null;
    });

    try {
      final snapshot = await FirebaseDatabase.instance.ref('activeTickets').get();

      if (!snapshot.exists) {
        showMessage('No active tickets found.');
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      String? foundKey;
      Map<String, dynamic>? foundData;

      for (final entry in data.entries) {
        final ticket = Map<String, dynamic>.from(entry.value);
        if ((ticket['plateNumber'] ?? '').toString().toUpperCase() == plateNumber) {
          foundKey = entry.key;
          foundData = ticket;
          break;
        }
      }

      if (foundKey == null || foundData == null) {
        showMessage('Ticket not found.');
        return;
      }

      setState(() {
        activeTicketKey = foundKey;
        activeTicketData = foundData;
      });
    } catch (e) {
      showMessage('Failed to find ticket: $e');
    } finally {
      if (mounted) {
        setState(() => isSearching = false);
      }
    }
  }

  DateTime? get timeEntered {
    if (activeTicketData == null) return null;
    final raw = activeTicketData!['timeEntered']?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  DateTime get timeExited => DateTime.now();

  int get durationMinutes {
    final entered = timeEntered;
    if (entered == null) return 0;
    return timeExited.difference(entered).inMinutes;
  }

  String get durationText {
    final mins = durationMinutes;
    final hours = mins ~/ 60;
    final remaining = mins % 60;
    return '${hours}h ${remaining}m';
  }

  double get amountDue {
    final mins = durationMinutes;

    // GRACE PERIOD
    if (mins < 10) {
      return 0.0;
    }

    // TAXES TEXA-
    final hours = mins ~/ 60;

    double baseRate;

    // FIRST 3 HOURS
    if (hours <= 3) {
      baseRate = 50.0;
    } else {
      // ADDITIONAL HOURS
      final extraHours = hours - 3;
      baseRate = 50.0 + (extraHours * 10);
    }

    // REGULAR PAYMENT (WITH VAT)
    if (paymentType == 'regular') {
      baseRate = baseRate * 1.12;
    }

    // PWD OR SENIOR
    if (paymentType == 'pwd' || paymentType == 'senior') {
      baseRate = baseRate * 0.80;
    }

    // ROUND TO 2 DECIMALS
    return double.parse(baseRate.toStringAsFixed(2));
  }

  double get cashReceived {
    return double.tryParse(cashReceivedController.text.trim()) ?? 0.0;
  }

  // CALCULATE CHANGE
  double get change {
    final value = cashReceived - amountDue;
    return value < 0 ? 0 : value;
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

  Future<void> openActiveTickets() async {
    final selectedTicket = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ActiveTicketsScreen(),
      ),
    );

    if (selectedTicket != null && selectedTicket.isNotEmpty) {
      setState(() {
        plateController.text = selectedTicket;
      });
      await findTicket();
    }
  }

  Future<void> confirmExit() async {
    if (activeTicketKey == null || activeTicketData == null) {
      showMessage('Please find a valid ticket first.');
      return;
    }

    // CHECK PAYMENT ONLY IF NOT FREE
    if (amountDue > 0 && cashReceived < amountDue) {
      showMessage('Cash received is not enough.');
      return;
    }

    setState(() => isProcessing = true);

    try {
      final transactionRef =
          FirebaseDatabase.instance.ref('transactions').push();

      await transactionRef.set({
        //'ticketNumber': activeTicketData!['ticketNumber'] ?? '',
        'plateNumber': activeTicketData!['plateNumber'] ?? '',
        'parkingSlot': activeTicketData!['parkingSlot'] ?? '', // SAVE SLOT
        //'vehicleType': activeTicketData!['vehicleType'] ?? '',
        'timeEntered': activeTicketData!['timeEntered'] ?? '',
        'timeEnteredDisplay': activeTicketData!['timeEnteredDisplay'] ?? '',
        'timeExited': timeExited.toIso8601String(),
        'timeExitedDisplay': formatDateTime(timeExited),
        'durationMinutes': durationMinutes,
        'durationText': durationText,
        'amountDue': amountDue,
        'cashReceived': cashReceived,
        'change': change,
        'paymentMethod': 'cash',
        'paymentStatus': 'paid',
        'paymentType': paymentType,
        'entryCashierId': activeTicketData!['entryCashierId'] ?? '',
        'entryCashierName': activeTicketData!['entryCashierName'] ?? '',
        'exitCashierId': Session.userKey ?? '',
        'exitCashierName': Session.username ?? 'Cashier',
        'status': 'completed',
      });

      await FirebaseDatabase.instance
          .ref('activeTickets/$activeTicketKey')
          .remove();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit Confirmed'),
          content: Text(
            'Payment recorded successfully.\n\nChange: PHP ${change.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                plateController.clear();
                cashReceivedController.clear();
                setState(() {
                  activeTicketKey = null;
                  activeTicketData = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showMessage('Failed to process exit: $e');
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
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
    cashReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plateNumber = activeTicketData?['plateNumber']?.toString() ?? '';
    final enteredDisplay =
        activeTicketData?['timeEnteredDisplay']?.toString() ?? '';
    //final vehicleType = activeTicketData?['vehicleType']?.toString() ?? '';

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
                          "Vehicle Exit",
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
                  title: "Enter Ticket",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        TextField(
                          controller: plateController,
                          decoration: inputDecoration(
                            hint: "Enter Plate Number",
                            icon: Icons.directions_car,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: openActiveTickets,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryYellow,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.list_alt),
                            label: const Text(
                              "View Tickets",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: isSearching ? null : findTicket,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryYellow,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: isSearching
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                            label: Text(
                              isSearching ? 'Searching...' : 'Find Ticket',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  title: "Ticket Details",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        _ReadOnlyRow(label: 'Plate Number', value: plateNumber),
                        const SizedBox(height: 10),
                        _ReadOnlyRow(
                          label: 'Parking Slot',
                          value: activeTicketData?['parkingSlot']?.toString() ?? '',
                        ),
                        const SizedBox(height: 10),
                        //_ReadOnlyRow(label: 'Vehicle Type', value: vehicleType),
                        //const SizedBox(height: 10),
                        _ReadOnlyRow(label: 'Time Entered', value: enteredDisplay),
                        const SizedBox(height: 10),
                        _ReadOnlyRow(
                          label: 'Time Exited',
                          value: activeTicketData == null
                              ? ''
                              : formatDateTime(timeExited),
                        ),
                        const SizedBox(height: 10),
                        _ReadOnlyRow(
                          label: 'Duration',
                          value: activeTicketData == null ? '' : durationText,
                        ),
                        const SizedBox(height: 10),
                        _ReadOnlyRow(
                          label: 'Amount Due',
                          value: activeTicketData == null
                              ? ''
                              : 'PHP ${amountDue.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  title: "Payment",
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        // PAYMENT TYPE OPTIONS
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'regular',
                                  groupValue: paymentType,
                                  onChanged: (value) {
                                    setState(() {
                                      paymentType = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'Regular (12% VAT)',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'pwd',
                                  groupValue: paymentType,
                                  onChanged: (value) {
                                    setState(() {
                                      paymentType = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'PWD (-20%, No VAT)',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'senior',
                                  groupValue: paymentType,
                                  onChanged: (value) {
                                    setState(() {
                                      paymentType = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'Senior (-20%, No VAT)',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: cashReceivedController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: inputDecoration(
                            hint: "Cash Received",
                            icon: Icons.payments_outlined,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ReadOnlyRow(
                          label: 'Change',
                          value: activeTicketData == null
                              ? ''
                              : 'PHP ${change.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: isProcessing ? null : confirmExit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryYellow,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: isProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              isProcessing
                                  ? 'Processing...'
                                  : 'Confirm Payment and Exit',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
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