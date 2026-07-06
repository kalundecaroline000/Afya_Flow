import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _aiRecommendedSpecialty = "General Practitioner";
  String _aiUrgencyLevel = "Medium";
  bool _isAiAnalyzing = false;
  bool _isBooking = false;

  // Mock function representing your Gemini API service call
  Future<void> _analyzeSymptomsWithGemini(String symptoms) async {
    if (symptoms.trim().isEmpty) return;

    setState(() {
      _isAiAnalyzing = true;
    });

    try {
      // TODO: Replace with your actual Google Gemini AI Dart SDK call
      // Example prompt payload: "Analyze these symptoms and return the best medical department and urgency (Low, Medium, High): $symptoms"
      await Future.delayed(const Duration(seconds: 2)); // Simulating network latency

      // Simulated AI Smart Extraction Logic based on your project requirements
      if (symptoms.toLowerCase().contains("chest") || symptoms.toLowerCase().contains("heart")) {
        setState(() {
          _aiRecommendedSpecialty = "Cardiologist";
          _aiUrgencyLevel = "High";
        });
      } else if (symptoms.toLowerCase().contains("breath") || symptoms.toLowerCase().contains("cough")) {
        setState(() {
          _aiRecommendedSpecialty = "Pulmonologist";
          _aiUrgencyLevel = "High";
        });
      } else {
        setState(() {
          _aiRecommendedSpecialty = "General Practitioner";
          _aiUrgencyLevel = "Low";
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✨ Gemini AI analysis complete! Recommendations updated."),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI Analysis Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isAiAnalyzing = false;
      });
    }
  }

  // Save appointment directly to your Firestore database backend
  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details, select a date and time slot.")),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final String? patientId = FirebaseAuth.instance.currentUser?.uid;
      final String formattedTime = _selectedTime!.format(context);
      final String formattedDate = "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}";

      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': patientId ?? 'anonymous_patient',
        'patientName': "Patient User", // Pull dynamic user name here later
        'symptoms': _symptomController.text.trim(),
        'recommendedSpecialty': _aiRecommendedSpecialty,
        'priority': _aiUrgencyLevel,
        'date': formattedDate,
        'time': formattedTime,
        'status': 'Pending', // Sent straight to the Doctor's dashboard queue
        'createdAt': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Success! 🎉", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Your appointment has been logged. Recommended Specialist: $_aiRecommendedSpecialty."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to patient dashboard
              },
              child: const Text("OK", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Book Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text(
                "Describe how you are feeling",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              const Text(
                "Our AfyaFlow Gemini AI assistant will analyze your symptoms to match you with the right clinic specialty.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Symptoms input box
              TextFormField(
                controller: _symptomController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "e.g., I've been experiencing a persistent dry cough and slight chest pain over the last two days...",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? "Please outline your medical symptoms" : null,
              ),
              const SizedBox(height: 12),

              // Gemini AI trigger chip button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isAiAnalyzing ? null : () => _analyzeSymptomsWithGemini(_symptomController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: _isAiAnalyzing
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple))
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: const Text("Ask Gemini AI to Route", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),

              // AI Output Summary Panel Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: Colors.purple.shade400, size: 20),
                        const SizedBox(width: 8),
                        const Text("Gemini Triage Recommendation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Suggested Clinic:", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(_aiRecommendedSpecialty, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Urgency Priority Status:", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: (_aiUrgencyLevel == "High" ? Colors.red.shade50 : Colors.green.shade50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _aiUrgencyLevel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (_aiUrgencyLevel == "High" ? Colors.red : Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date and Time selection pickers
              const Text("Schedule Allocation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.calendar_today, color: Colors.teal),
                      label: Text(
                        _selectedDate == null ? "Select Date" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: const TextStyle(color: Color(0xFF1E293B)),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.access_time, color: Colors.teal),
                      label: Text(
                        _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                        style: const TextStyle(color: Color(0xFF1E293B)),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Master Submission Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isBooking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm & Queue Appointment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}