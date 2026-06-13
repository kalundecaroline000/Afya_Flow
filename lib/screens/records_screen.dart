import 'package:flutter/material.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medical Records', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRecordCard(
            title: 'Full Blood Count Test',
            date: 'June 04, 2026',
            facility: 'AfyaFlow Central Lab',
            status: 'Completed',
            icon: Icons.biotech_rounded,
            color: Colors.blue,
          ),
          _buildRecordCard(
            title: 'General Medical Examination',
            date: 'May 28, 2026',
            facility: 'Outpatient Department',
            status: 'Archived',
            icon: Icons.assignment_turned_in_rounded,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard({
    required String title,
    required String date,
    required String facility,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$facility\n$date', style: const TextStyle(height: 1.3)),
        isThreeLine: true,
        trailing: Chip(
          label: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          backgroundColor: color.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}