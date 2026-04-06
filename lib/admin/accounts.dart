import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'accounts_profile.dart';

class AccountsScreenA extends StatefulWidget {
  const AccountsScreenA({super.key});

  @override
  State<AccountsScreenA> createState() => _AccountsScreenAState();
}

class _AccountsScreenAState extends State<AccountsScreenA> {
  static const Color kGoldBg = Color(0xFFECC84E);
  static const Color kCardColor = Colors.white;

  String selectedRole = "user"; // default tab

  Map<String, dynamic> allUsers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final ref = FirebaseDatabase.instance.ref("users");
      final snapshot = await ref.get();

      if (snapshot.exists) {
        setState(() {
          allUsers = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // FILTER USERS BY ROLE
  List<MapEntry<String, dynamic>> get filteredUsers {
    return allUsers.entries
        .where((user) => user.value['role'] == selectedRole)
        .toList();
  }

  // TAB BUTTON
  Widget buildTab(String role, String label) {
    bool isActive = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // USER CARD
  Widget buildUserCard(String userId, Map data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AccountsProfileScreen(userId: userId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/default_profile.jpg'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['username'] ?? 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    data['email'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14)
          ],
        ),
      ),
    );
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
                // 🔹 HEADER (YOUR EXISTING UI)
                Row(
                  children: [
                    Image.asset(
                      "assets/mark_a_park_app_icon.png",
                      width: 34,
                      height: 34,
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin Dashboard",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "MARK-A-PARK",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 TABS
                Row(
                  children: [
                    buildTab("user", "Users"),
                    buildTab("cashier", "Cashier"),
                    buildTab("admin", "Admin"),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 LIST
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (filteredUsers.isEmpty)
                  const Center(child: Text("No users found"))
                else
                  Column(
                    children: filteredUsers.map((entry) {
                      return buildUserCard(
                        entry.key,
                        Map<String, dynamic>.from(entry.value),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}