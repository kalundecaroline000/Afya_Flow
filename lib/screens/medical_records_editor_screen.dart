import 'package:flutter/material.dart';

class MedicalRecordsEditor extends StatefulWidget {
  final String patientName;
  final String patientId;

  const MedicalRecordsEditor({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<MedicalRecordsEditor> createState() => _MedicalRecordsEditorState();
}

class _MedicalRecordsEditorState extends State<MedicalRecordsEditor> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user edits
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedStatus = 'Stable'; // Default observation flag

  @override
  void initState() {
    super.initState();
    // Pre-filling basic sample data for presentation demo
    _symptomsController.text = "Mild chest tightess, slight fatigue reported over 3 days.";
    _diagnosisController.text = "Mild Hypertension - Regular monitoring required.";
    _prescriptionController.text = "Amlodipine 5mg - Once daily for 30 days.";
  }

  void _saveMedicalRecord() {
    if (_formKey.currentState!.validate()) {
      // TODO: Connect this to your DatabaseHelper later to update SQLite/Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Medical record updated for ${widget.patientName}! 💾"),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context); // Go back smoothly to the dashboard queue
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Edit Medical Record", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Patient Context Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal.shade600,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patientName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          "ID: ${widget.patientId}",
                          style: TextStyle(fontSize: 13, color: Colors.teal.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🏷️ Patient Condition Dropdown Selector
              const Text("Current Patient Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: ['Stable', 'Critical', 'Under Observation', 'Discharged'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 🩺 Symptoms Input Field
              _buildEditorField("Presented Symptoms", _symptomsController, Icons.healing_outlined, 3),
              const SizedBox(height: 16),

              // 📋 Diagnosis Input Field
              _buildEditorField("Clinical Diagnosis", _diagnosisController, Icons.assignment_outlined, 3),
              const SizedBox(height: 16),

              // 💊 Prescription Entry Field
              _buildEditorField("Prescription Medications", _prescriptionController, Icons.medication_outlined, 2),
              const SizedBox(height: 16),

              // 📝 Additional Internal Notes
              _buildEditorField("Internal Consultation Notes (Optional)", _notesController, Icons.note_alt_outlined, 3),
              const SizedBox(height: 28),

              // 🚀 Save Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveMedicalRecord,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save & Update Record", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Form Builder Helper
  Widget _buildEditorField(String label, TextEditingController controller, IconData icon, int maxLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
          ),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'This field cannot be empty' : null,
        ),
      ],
    );
  }
}