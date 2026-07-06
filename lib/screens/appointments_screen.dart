import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medical_records_editor_screen.dart'; // To update patient history
import 'patient_screen.dart';                // To jump into the check-up chat

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  // Updates status to 'Completed' once the check-up is fully done
  Future<void> _completeAppointment(String docId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({'status': 'Completed'});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment marked as completed! ✅"), backgroundColor: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("My Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_toggle_off_rounded),
            onPressed: () {
              // Optional: Navigate to completed appointment history archive
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Only streams appointments that have been officially 'Approved' and scheduled
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('status', isEqualTo: 'Approved')
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No confirmed appointments for today.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final doc = appointments[index];
              final data = doc.data() as Map<String, dynamic>;
              final String docId = doc.id;
              final String patientName = data['patientName'] ?? 'Patient User';
              final String patientId = data['patientId'] ?? 'N/A'; // Retrieve patient ID

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Time slot allocation indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: Colors.teal, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "${data['date']}  •  ${data['time']}",
                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: data['priority'] == 'High' ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['priority'] ?? 'Normal',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: data['priority'] == 'High' ? Colors.red : Colors.green
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // Body: Patient identity details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.teal.shade50,
                            child: const Icon(Icons.person, color: Colors.teal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Symptoms: ${data['symptoms']}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, indent: 16, endIndent: 16),

                    // Bottom Action Ribbon Bar for Clinical Operations
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Action 1: Open consulting communications channel
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientScreen()));
                            },
                            icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.blue),
                            label: const Text("Chat", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),

                          // Action 2: Update Medical Records / Diagnostic History file
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MedicalRecordsEditor(
                                        patientName: patientName,
                                        patientId: patientId, // Fixed: Added required patientId
                                      )
                                  )
                              );
                            },
                            icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.orange),
                            label: const Text("Records", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),

                          // Action 3: Finalize consultation and close session track
                          TextButton.icon(
                            onPressed: () => _completeAppointment(docId),
                            icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                            label: const Text("Complete", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}