import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';
import 'child_dashboard.dart';
import 'registration_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // Logic for Show/Hide Password

  // CUSTOM ERROR POPUP: Replaces boring Firebase messages
  void _showErrorPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("TRY AGAIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorPopup("Empty Fields", "Please enter both email and password to continue.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(user.user!.uid).get();
      
      if (!mounted) return;
      String role = snap.get('role');

      if (role == 'Parent') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const ChildDashboard()));
      }
    } on FirebaseAuthException catch (e) {
      // Logic to filter "boring" codes into human-friendly messages
      String userFriendlyMessage = "Something went wrong. Please check your internet.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        userFriendlyMessage = "The email or password you entered is incorrect. Please try again.";
      } else if (e.code == 'network-request-failed') {
        userFriendlyMessage = "No internet connection detected.";
      }
      
      _showErrorPopup("Login Failed", userFriendlyMessage);
    } catch (e) {
      _showErrorPopup("Error", "An unexpected error occurred. Please restart the app.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
        child: Column(
          children: [
            const Icon(Icons.shield_rounded, size: 90, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text("GUARDIAN SHIELD", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 50),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword, // Toggles based on icon click
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                // THE SHOW/HIDE EYE ICON
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
              ),
              onPressed: _login,
              child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegistrationScreen())),
              child: const Text("New here? Create a Security Account", style: TextStyle(color: Colors.indigo)),
            )
          ],
        ),
      ),
    );
  }
}