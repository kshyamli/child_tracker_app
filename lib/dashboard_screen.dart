import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- THIS WAS MISSING
import 'map_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "Parent";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() {
            userName = userData.exists ? (userData['firstName'] ?? "Parent") : "Parent";
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safety Dashboard"), 
        backgroundColor: const Color(0xFF1A2B3C), 
        foregroundColor: Colors.white
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1A2B3C)),
              accountName: Text(isLoading ? "Fetching..." : userName),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ""),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Welcome, $userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildFeatureCard("Live Location", "Track child on Map", Icons.map, Colors.red, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
            }),
            const SizedBox(height: 15),
            _buildFeatureCard("Emergency Call", "Quick dial help", Icons.phone, Colors.blue, () async {
              final Uri url = Uri.parse('tel:100');
              if (await canLaunchUrl(url)) { // FIXED: Now it knows this method
                await launchUrl(url);       // FIXED: Now it knows this method
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        onTap: onTap,
      ),
    );
  }
}