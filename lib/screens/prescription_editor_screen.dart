import 'package:flutter/material.dart';

class PrescriptionEditor extends StatefulWidget {
  final String patientName;

  const PrescriptionEditor({super.key, required this.patientName});

  @override
  State<PrescriptionEditor> createState() => _PrescriptionEditorState();
}

class _PrescriptionEditorState extends State<PrescriptionEditor> {
  final _formKey = GlobalKey<FormState>();

  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedFrequency = 'Once Daily (OD)';

  final List<String> _frequencies = [
    'Once Daily (OD)',
    'Twice Daily (BD)',
    'Three Times Daily (TDS)',
    'Four Times Daily (QDS)',
    'As Needed (PRN)',
  ];

  void _savePrescription() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Prescription issued for ${widget.patientName}! 💊"),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Write Prescription", style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text(
                "Prescription for: ${widget.patientName}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const Divider(height: 24, thickness: 1),

              _buildLabel("Medication / Drug Name"),
              TextFormField(
                controller: _medicationController,
                decoration: InputDecoration(
                  hintText: "e.g., Amoxicillin, Paracetamol",
                  prefixIcon: const Icon(Icons.medication, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter drug name' : null,
              ),

              _buildLabel("Dosage / Strength"),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  hintText: "e.g., 500mg, 10ml",
                  prefixIcon: const Icon(Icons.line_weight, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter dosage strength' : null,
              ),

              _buildLabel("Frequency"),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: _frequencies.map((freq) {
                  return DropdownMenuItem(value: freq, child: Text(freq));
                }).toList(),
                onChanged: (val) => setState(() => _selectedFrequency = val!),
              ),

              _buildLabel("Duration"),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  hintText: "e.g., 5 days, 2 weeks",
                  prefixIcon: const Icon(Icons.date_range, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter duration' : null,
              ),

              _buildLabel("Special Instructions (Optional)"),
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "e.g., Take after meals...",
                  prefixIcon: const Icon(Icons.description_outlined, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _savePrescription,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text("Issue Prescription", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
      ),
    );
  }
}