import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'booking_screen.dart';
import 'records_screen.dart';
import 'prescriptions_screen.dart';
import 'billing_screen.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Afyaflow',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              // Clear Shared Preferences session data on logout (Week 4 Requirement)
              await LocalStorageService.clearSession();
              if (!context.mounted) return;

              // Pop back to the Login Screen gateway view
              Navigator.pop(context);
            },
          ),
        ],
        backgroundColor: Colors.teal,
        elevation: 2,
        automaticallyImplyLeading: false, // Disables the back button arrow on the hub
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Greeting Banner
            const Text(
              'Welcome Back, Patient 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Text(
              'Manage your healthcare appointments and digital records smoothly.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Grid Architecture Section Title
            const Text(
              'Our Medical Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Core Operational Application Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildServiceCard(
                  context,
                  title: 'Book Appointment',
                  icon: Icons.calendar_month_rounded,
                  color: Colors.teal,
                  subtitle: 'Schedule a visit',
                ),
                _buildServiceCard(
                  context,
                  title: 'My Records',
                  icon: Icons.folder_shared_rounded,
                  color: Colors.blue,
                  subtitle: 'Medical history',
                ),
                _buildServiceCard(
                  context,
                  title: 'Prescriptions',
                  icon: Icons.medication_rounded,
                  color: Colors.orange,
                  subtitle: 'Active dosages',
                ),
                _buildServiceCard(
                  context,
                  title: 'Billing & Fees',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.purple,
                  subtitle: 'Invoices & statements',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Refactored Modular UI Card Map Router
  Widget _buildServiceCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required String subtitle,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Explicit navigation handling for every core grid layout milestone
          if (title == 'Book Appointment') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingScreen()),
            );
          } else if (title == 'My Records') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecordsScreen()),
            );
          } else if (title == 'Prescriptions') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrescriptionsScreen()),
            );
          } else if (title == 'Billing & Fees') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BillingScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}