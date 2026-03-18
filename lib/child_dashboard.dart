import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ChildDashboard extends StatelessWidget {
  const ChildDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.power_settings_new, color: Colors.redAccent), 
          onPressed: () => FirebaseAuth.instance.signOut().then((_) => 
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()))))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 2)),
              child: const Icon(Icons.security_update_good, size: 100, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 40),
            const Text("SHIELD ACTIVE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
            const SizedBox(height: 10),
            const Text("Your location is being shared with your Parent", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}