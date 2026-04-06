import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../auth/login.dart';
import '../auth/session.dart';

class AccountsProfileScreen extends StatefulWidget {
  final String userId;

  const AccountsProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AccountsProfileScreen> createState() => _AccountsProfileScreenState();
}

class _AccountsProfileScreenState extends State<AccountsProfileScreen> {
  static const Color bgYellow = Color(0xFFECC84E);
  static const Color cardYellow = Color(0xFFE7CA63);
  static const Color buttonYellow = Color(0xFFF3CA41);
  static const Color mutedFill = Color(0xFFE0E0E0);

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  DatabaseReference get userRef =>
    FirebaseDatabase.instance.ref('users/${widget.userId}');

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      if (Session.userKey == null) return;

      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        userIdController.text = widget.userId;
        usernameController.text = data['username']?.toString() ?? '';
        emailController.text = data['email']?.toString() ?? '';
        contactController.text = data['contact']?.toString() ?? '';
        addressController.text = data['address']?.toString() ?? '';
        sexController.text = data['sex']?.toString() ?? '';
        nationalityController.text = data['nationality']?.toString() ?? '';
      }
    } catch (e) {
      showMessage('Failed to load admin data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> saveUserData() async {
    setState(() => isSaving = true);

    try {
      await userRef.update({
        'email': emailController.text.trim(),
        'contact': contactController.text.trim(),
        'address': addressController.text.trim(),
        'sex': sexController.text.trim(),
        'nationality': nationalityController.text.trim(),
      });

      showMessage('Admin information updated successfully.');
    } catch (e) {
      showMessage('Failed to save data: $e');
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

  InputDecoration fieldDecoration({
    required String hint,
    IconData? icon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
      filled: true,
      fillColor: readOnly ? mutedFill : Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black54),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: fieldDecoration(
          hint: label,
          icon: icon,
          readOnly: readOnly,
        ),
      ),
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    usernameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    sexController.dispose();
    nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: bgYellow,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: bgYellow,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/mark_a_park_app_icon.png',
                    width: 52,
                    height: 52,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MARK-A-PARK',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: cardYellow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const CircleAvatar(
                        radius: 48,
                        backgroundImage: AssetImage('assets/default_profile.jpg'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        usernameController.text.isEmpty
                            ? 'Admin'
                            : usernameController.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 22),
                      buildTextField(
                        label: 'User ID',
                        controller: userIdController,
                        icon: Icons.badge_outlined,
                        readOnly: true,
                      ),
                      buildTextField(
                        label: 'Username',
                        controller: usernameController,
                        icon: Icons.person_outline,
                        readOnly: true,
                      ),
                      buildTextField(
                        label: 'Email',
                        controller: emailController,
                        icon: Icons.email_outlined,
                      ),
                      buildTextField(
                        label: 'Contact',
                        controller: contactController,
                        icon: Icons.phone_outlined,
                      ),
                      buildTextField(
                        label: 'Address',
                        controller: addressController,
                        icon: Icons.location_on_outlined,
                      ),
                      buildTextField(
                        label: 'Sex',
                        controller: sexController,
                        icon: Icons.wc_outlined,
                      ),
                      buildTextField(
                        label: 'Nationality',
                        controller: nationalityController,
                        icon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonYellow,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'SAVE CHANGES',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}