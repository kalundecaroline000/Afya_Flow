import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🌐 Updated handler to safely write profiles to Firebase and Firestore
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          ),
        );

        // 1️⃣ Create the login authentication credentials in Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          String fullName = _nameController.text.trim();
          String userEmail = _emailController.text.trim().toLowerCase();

          // 🧠 SMART ROLE ASSIGNMENT:
          // It automatically detects keywords in the name or email to grant roles!
          String assignedRole = 'Patient'; // Default fallback

          if (fullName.toLowerCase().contains('admin') || userEmail.contains('admin')) {
            assignedRole = 'Admin';
          } else if (fullName.toLowerCase().contains('doctor') || fullName.toLowerCase().contains('dr.') || userEmail.contains('doctor')) {
            assignedRole = 'Doctor';
          }

          print("DEBUG: Registering user as a specialized role: $assignedRole");

          // 2️⃣ Save the companion tracking profile document into Cloud Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': fullName,
            'email': userEmail,
            'role': assignedRole, // 🔥 Dynamic role! No longer stuck on Patient
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (!mounted) return;
          Navigator.pop(context); // Dismiss loading spinner

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account Created as $assignedRole! Please Login.')),
          );

          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text(e.message ?? 'Registration failed.')),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join AfyaFlow',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || !value.contains('@')) ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => (value == null || value.length < 6) ? 'Password must be 6+ chars' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}