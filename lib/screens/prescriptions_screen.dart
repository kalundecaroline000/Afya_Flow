import 'package:flutter/material.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPrescriptionCard(
            medication: 'Amoxicillin 500mg',
            instructions: 'Take 1 capsule 3 times daily after food',
            duration: '7 Days Supply',
            refillsLeft: 0,
          ),
          _buildPrescriptionCard(
            medication: 'Paracetamol 500mg',
            instructions: 'Take 2 tablets every 6 hours as needed for pain',
            duration: '5 Days Supply',
            refillsLeft: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard({
    required String medication,
    required String instructions,
    required String duration,
    required int refillsLeft,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Text(medication, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            Text(instructions, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration: $duration', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Refills Remaining: $refillsLeft', style: TextStyle(color: refillsLeft > 0 ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}