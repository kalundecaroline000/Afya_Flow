import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 Added for Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 Added for Firestore
import 'doctor_profile_screen.dart'; // 🌟 Added to call Doctor Profile

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008080);
    const Color lightTeal = Color(0xFFE0F2F1);

    // Fetch current logged-in doctor
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(patient['name'] ?? 'Patient Details', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 🌟 Added Profile Button to call the Doctor Profile screen
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('doctors').doc(currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              final doctorData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              return IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfileScreen(doctorData: doctorData),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🩺 Top Core Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: lightTeal,
                      child: const Icon(Icons.person, color: primaryTeal, size: 35),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient['name'] ?? 'Unknown Patient',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ID: ${patient['id'] ?? 'N/A'} | Condition: ${patient['condition'] ?? 'N/A'}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (patient['color'] as Color? ?? Colors.teal).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              patient['status'] ?? 'Outpatient',
                              style: TextStyle(
                                color: patient['color'] as Color? ?? primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📊 Patient Vitals Section
            const Text("Current Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildVitalCard("Blood Pressure", "120/80 mmHg", Icons.favorite, Colors.red.shade50, Colors.red),
                _buildVitalCard("Heart Rate", "72 bpm", Icons.monitor_heart, Colors.orange.shade50, Colors.orange),
                _buildVitalCard("SpO2", "98%", Icons.opacity, Colors.blue.shade50, Colors.blue),
                _buildVitalCard("Temperature", "36.7 °C", Icons.thermostat, Colors.green.shade50, Colors.green),
              ],
            ),
            const SizedBox(height: 24),

            // 📋 Medical History & Notes
            const Text("Clinical Notes & History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Patient presents with occasional mild palpitations during exertion. Advised to reduce sodium intake, stick to continuous daily monitoring logs, and schedule a formal follow-up ECG assessment in two weeks.",
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 💊 Current Prescriptions
            const Text("Active Medications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            _buildMedicationRow("Amlodipine 5mg", "1 tablet daily - Morning", Icons.medication),
            _buildMedicationRow("Atorvastatin 20mg", "1 tablet daily - Night", Icons.poll),
          ],
        ),
      ),
    );
  }

  // 1. Added 'Widget' keyword here
  Widget _buildVitalCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: Colors.grey), // 2. Changed shade200 to plain grey to fix const conflict
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(backgroundColor: bgColor, radius: 14, child: Icon(icon, color: iconColor, size: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMedicationRow(String medName, String dosage, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.grey)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.medical_services, color: Color(0xFF008080))),
        title: Text(medName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(dosage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}