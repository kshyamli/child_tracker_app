import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  // Fixes the typo from your photo
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ChildTrackerApp());
}

class ChildTrackerApp extends StatelessWidget {
  const ChildTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Child Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A2B3C),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}