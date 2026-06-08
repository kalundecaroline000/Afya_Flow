import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/doctor_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the asynchronous background pipeline
    _doctorsFuture = ApiService.fetchAvailableDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          // --- STATE A: ACTIVE LOADING ENGINE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text(
                    'Querying Live Hospital Registry...',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            );
          }

          // --- STATE B: ERROR HANDLING ---
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to retrieve server data. Check connection.'));
          }

          final doctors = snapshot.data ?? [];

          // --- STATE C: SUCCESS DATA COMPLETION ---
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(doctor.specialty),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: doctor.isAvailable ? Colors.teal.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      doctor.isAvailable ? 'Available' : 'On Leave',
                      style: TextStyle(
                        color: doctor.isAvailable ? Colors.teal : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}