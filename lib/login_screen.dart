import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isRegistering = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadharController = TextEditingController();

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (isRegistering) {
          // 1. Create User in Firebase Auth
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim());

          // 2. IMPORTANT: Save data to Firestore 'users' collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': _firstNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'aadhar': _aadharController.text.trim(),
            'email': _emailController.text.trim(),
            'uid': userCredential.user!.uid,
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful! Now Login.")));
            setState(() => isRegistering = false);
          }
        } else {
          // Login Logic
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.security, size: 80, color: Color(0xFF1A2B3C)),
              const SizedBox(height: 20),
              Text(isRegistering ? "Create Parent Account" : "Parent Login", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (isRegistering) ...[
                TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: "First Name")),
                TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone Number")),
                TextFormField(controller: _aadharController, decoration: const InputDecoration(labelText: "Aadhaar Number")),
              ],
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: const Color(0xFF1A2B3C)),
                onPressed: _handleSubmit, 
                child: Text(isRegistering ? "Register" : "Login", style: const TextStyle(color: Colors.white)),
              ),
              TextButton(onPressed: () => setState(() => isRegistering = !isRegistering), 
                         child: Text(isRegistering ? "Already have an account? Login" : "New user? Register here"))
            ],
          ),
        ),
      ),
    );
  }
}