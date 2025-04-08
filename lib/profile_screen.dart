import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  void _logout(BuildContext context) async {
    await _auth.signOut();
  }

  void _changePassword(BuildContext context) async {
    try {
      final user = _auth.currentUser!;

      // Re-authenticate the user first before changing the password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(cred);

      // Check if the new password is valid (at least 6 characters)
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ));
        return;
      }

      // Update password
      await user.updatePassword(_passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password updated successfully'),
      ));

      _currentPasswordController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Error updating password'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome,', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text(user?.email ?? 'No Email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            Text('Change Password', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
