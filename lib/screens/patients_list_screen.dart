import 'package:flutter/material.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  // Dummy static data matching your dashboard style—you can hook this to Firestore later!
  final List<Map<String, dynamic>> _allPatients = [
    {'name': 'John Mwangi', 'id': 'PT-2026-01', 'condition': 'Hypertension', 'status': 'Outpatient', 'color': Colors.blue},
    {'name': 'Mary Wanjiku', 'id': 'PT-2026-02', 'condition': 'Post-Op Recovery', 'status': 'Admitted', 'color': Colors.red},
    {'name': 'Peter Otieno', 'id': 'PT-2026-03', 'condition': 'Arrhythmia', 'status': 'Critical', 'color': Colors.orange},
    {'name': 'Grace Achieng', 'id': 'PT-2026-04', 'condition': 'General Checkup', 'status': 'Discharged', 'color': Colors.green},
    {'name': 'James Kariuki', 'id': 'PT-2026-05', 'condition': 'Chest Pain Evaluation', 'status': 'Admitted', 'color': Colors.red},
    {'name': 'Lucy Njeri', 'id': 'PT-2026-06', 'condition': 'Asthma Management', 'status': 'Outpatient', 'color': Colors.blue},
  ];

  List<Map<String, dynamic>> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _allPatients
          .where((patient) => patient['name']!.toLowerCase().contains(query.toLowerCase()) ||
          patient['id']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008080);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Patients', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar Container
          Container(
            color: primaryTeal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                hintText: 'Search patient name or ID...',
                prefixIcon: const Icon(Icons.search, color: primaryTeal),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Patient List
          Expanded(
            child: _filteredPatients.isEmpty
                ? const Center(child: Text('No patients found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: const Icon(Icons.person_pin, color: primaryTeal),
                    ),
                    title: Text(
                      patient['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(patient['id'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(patient['condition'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (patient['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        patient['status'],
                        style: TextStyle(color: patient['color'], fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    onTap: () {
                      // Hand off to patient diagnostic files/records view later
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}