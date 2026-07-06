import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 Added for Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 Added for Firestore
import 'doctor_profile_screen.dart'; // 🌟 Added to call Doctor Profile

class LabResultsScreen extends StatelessWidget {
  final String patientName;
  final String condition;

  const LabResultsScreen({
    super.key,
    required this.patientName,
    required this.condition
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008080);

    // Fetch current logged-in doctor
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Mock laboratory data matching your dashboard items
    final List<Map<String, dynamic>> labTests = [
      {
        'testName': 'Lipid Profile Panel',
        'date': 'Yesterday, 4:15 PM',
        'status': 'High Risk',
        'statusColor': Colors.red,
        'metrics': [
          {'name': 'Total Cholesterol', 'value': '6.2 mmol/L', 'reference': '< 5.2 mmol/L', 'isAbnormal': true},
          {'name': 'Triglycerides', 'value': '2.1 mmol/L', 'reference': '< 1.7 mmol/L', 'isAbnormal': true},
          {'name': 'HDL Cholesterol', 'value': '1.0 mmol/L', 'reference': '> 1.2 mmol/L', 'isAbnormal': true},
          {'name': 'LDL Cholesterol', 'value': '4.3 mmol/L', 'reference': '< 3.0 mmol/L', 'isAbnormal': true},
        ]
      },
      {
        'testName': 'Full Blood Count (FBC)',
        'date': 'Today, 8:30 AM',
        'status': 'Normal',
        'statusColor': Colors.green,
        'metrics': [
          {'name': 'Hemoglobin (Hb)', 'value': '14.2 g/dL', 'reference': '13.0 - 17.0 g/dL', 'isAbnormal': false},
          {'name': 'White Blood Cells (WBC)', 'value': '6.5 x10^9/L', 'reference': '4.0 - 11.0 x10^9/L', 'isAbnormal': false},
          {'name': 'Platelets', 'value': '250 x10^9/L', 'reference': '150 - 400 x10^9/L', 'isAbnormal': false},
        ]
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lab Investigations', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Metadata Context Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.science, color: primaryTeal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text("Clinical Indication: $condition", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Report History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),

            // Lab Report Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: labTests.length,
              itemBuilder: (context, index) {
                final report = labTests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Fixed Theme.context error
                    child: ExpansionTile(
                      initiallyExpanded: index == 0, // Keep the latest report open
                      leading: Icon(Icons.analytics_outlined, color: report['statusColor']),
                      title: Text(report['testName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text(report['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (report['statusColor'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report['status'],
                          style: TextStyle(color: report['statusColor'], fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: const Color(0xFFFAFAFA),
                          child: Column(
                            children: [
                              // Table Header
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text("Investigation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                                    Text("Result", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                                    const SizedBox(width: 30),
                                    Text("Ref Range", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const Divider(),
                              // Metric Item List
                              ...(report['metrics'] as List).map((metric) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            metric['name'],
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: metric['isAbnormal'] ? Colors.red : Colors.black87)
                                        ),
                                      ),
                                      Text(
                                          metric['value'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: metric['isAbnormal'] ? Colors.red : Colors.black87)
                                      ),
                                      const SizedBox(width: 30),
                                      Text(metric['reference'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}