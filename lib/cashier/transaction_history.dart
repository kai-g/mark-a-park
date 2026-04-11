import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const Color kGoldBg = Color(0xFFEAF27A);

  @override
  Widget build(BuildContext context) {
    final transactionsRef = FirebaseDatabase.instance.ref('transactions');

    return Scaffold(
      backgroundColor: kGoldBg,
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: transactionsRef.onValue,
          builder: (context, snapshot) {
            List<MapEntry<String, dynamic>> transactions = [];

            if (snapshot.hasData &&
                snapshot.data!.snapshot.value != null &&
                snapshot.data!.snapshot.value is Map) {
              final data = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );
              transactions = data.entries.toList();
              transactions.sort((a, b) {
                final aTime =
                    (a.value['timeExited'] ?? '').toString();
                final bTime =
                    (b.value['timeExited'] ?? '').toString();
                return bTime.compareTo(aTime);
              });
            }

            return Padding(
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
                            "Transaction History",
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
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions yet.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: transactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = transactions[index];
                              final tx =
                                  Map<String, dynamic>.from(item.value);

                              return _TransactionCard(
                                plateNumber: tx['plateNumber']?.toString() ?? '',
                                timeEnteredDisplay: tx['timeEnteredDisplay']?.toString() ?? '',
                                timeExitedDisplay: tx['timeExitedDisplay']?.toString() ?? '',
                                durationText: tx['durationText']?.toString() ?? '',
                                parkingSlot: tx['parkingSlot']?.toString() ?? '',
                                amountDue: (tx['amountDue'] ?? 0).toString(),
                                amountPaid: (tx['cashReceived'] ?? 0).toString(),
                                change: (tx['change'] ?? 0).toString(),
                                paymentType: tx['paymentType']?.toString() ?? '',
                                paymentStatus: tx['paymentStatus']?.toString() ?? '',
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String plateNumber;
  final String timeEnteredDisplay;
  final String timeExitedDisplay;
  final String durationText;
  final String parkingSlot;
  final String amountDue;
  final String amountPaid;
  final String change;
  final String paymentType;
  final String paymentStatus;

  const _TransactionCard({
    required this.plateNumber,
    required this.timeEnteredDisplay,
    required this.timeExitedDisplay,
    required this.durationText,
    required this.parkingSlot,
    required this.amountDue,
    required this.amountPaid,
    required this.change,
    required this.paymentType,
    required this.paymentStatus,
  });

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
            'Plate Number: $plateNumber',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.black12),
          const SizedBox(height: 8),
          Text('Entry: $timeEnteredDisplay'),
            const SizedBox(height: 4),
            Text('Exit: $timeExitedDisplay'),
            const SizedBox(height: 4),
            Text('Duration: $durationText'),
            const SizedBox(height: 4),
            Text('Parking Slot: $parkingSlot'),
            const SizedBox(height: 4),
            Text('Amount Due: PHP $amountDue'),
            const SizedBox(height: 4),
            Text('Amount Paid: PHP $amountPaid'),
            const SizedBox(height: 4),
            Text('Change: PHP $change'),
            const SizedBox(height: 4),
            Text('Payment Type: $paymentType'),
            const SizedBox(height: 4),
            Text('Status: $paymentStatus'),
        ],
      ),
    );
  }
}