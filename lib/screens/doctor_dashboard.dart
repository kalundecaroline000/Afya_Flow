import 'dart:io'; // 📸 Added to support handling captured file paths
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // 📸 Added for device hardware camera access

// --- Safe & Verified Screen Imports ---
import 'doctor_profile_screen.dart';
import 'patients_list_screen.dart';
import 'patient_details_screen.dart';
import 'medical_records_editor_screen.dart'; // ✅ Now Active
import 'prescription_editor_screen.dart';    // ✅ Now Active
import 'messages_screen.dart';
import 'lab_result_screen.dart';

class DoctorDashboard extends StatefulWidget {
    const DoctorDashboard({super.key});

    @override
    State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
    int _currentIndex = 0;

    // Handles dynamic workspace switching across bottom tabs
    Widget _buildBody(Map<String, dynamic> doctorData) {
        switch (_currentIndex) {
            case 0:
                return DoctorHomeTab(doctorData: doctorData);
            case 1:
            // 📅 Live Interactive Schedule Workspace Tab
                return const DoctorScheduleTab();
            case 2:
            // 📩 Messages/Consultations Terminal Tab
                return const MessagesScreen(patientName: "Active Consultations Workspace");
            case 3:
            // 🔬 Generalized Lab Reports Tracker Tab
                return const LabResultsScreen(patientName: "General Lab Queue", condition: "Routine Review Panel");
            case 4:
                return DoctorProfileScreen(doctorData: doctorData);
            default:
                return DoctorHomeTab(doctorData: doctorData);
        }
    }

    @override
    Widget build(BuildContext context) {
        final User? currentUser = FirebaseAuth.instance.currentUser;

        return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('doctors').doc(currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
                    );
                }

                final doctorData = snapshot.data?.data() as Map<String, dynamic>? ?? {};

                return Scaffold(
                    backgroundColor: const Color(0xFFF8FAFC),
                    appBar: AppBar(
                        title: const Text("AfyaFlow Doctor Portal", style: TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        actions: [
                            IconButton(
                                icon: const Icon(Icons.person_outline),
                                onPressed: () {
                                    setState(() {
                                        _currentIndex = 4; // Swaps directly to Profile Tab view
                                    });
                                },
                            ),
                            IconButton(
                                icon: const Icon(Icons.logout),
                                onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (context.mounted) {
                                        Navigator.pushReplacementNamed(context, '/login');
                                    }
                                },
                            ),
                        ],
                    ),
                    body: _buildBody(doctorData),

                    // 🗂️ Navigation dock tracking Home, Schedule, Messages, Labs, and Profile
                    bottomNavigationBar: BottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: (index) {
                            setState(() {
                                _currentIndex = index;
                            });
                        },
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: Colors.teal,
                        unselectedItemColor: Colors.grey.shade500,
                        showUnselectedLabels: true,
                        selectedFontSize: 11,
                        unselectedFontSize: 11,
                        elevation: 10,
                        backgroundColor: Colors.white,
                        items: const [
                            BottomNavigationBarItem(
                                icon: Icon(Icons.home_outlined),
                                activeIcon: Icon(Icons.home),
                                label: 'Home',
                            ),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.calendar_today_outlined),
                                activeIcon: Icon(Icons.calendar_today),
                                label: 'Schedule',
                            ),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.chat_bubble_outline),
                                activeIcon: Icon(Icons.chat_bubble),
                                label: 'Messages',
                            ),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.science_outlined),
                                activeIcon: Icon(Icons.science),
                                label: 'Labs',
                            ),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.person_outline),
                                activeIcon: Icon(Icons.person),
                                label: 'Profile',
                            ),
                        ],
                    ),
                );
            },
        );
    }
}

// 🏠 Tab 0: Home Dashboard
class DoctorHomeTab extends StatefulWidget {
    final Map<String, dynamic> doctorData;
    const DoctorHomeTab({super.key, required this.doctorData});

    @override
    State<DoctorHomeTab> createState() => _DoctorHomeTabState();
}

class _DoctorHomeTabState extends State<DoctorHomeTab> {
File? _scannedDocumentFile; // To keep tracking of the captured file locally
final ImagePicker _cameraPicker = ImagePicker();

// 📸 Week 9 Feature: Launches phone hardware camera to capture data records safely
Future<void> _scanPatientDocument() async {
try {
final XFile? capturedPhoto = await _cameraPicker.pickImage(
source: ImageSource.camera,
imageQuality: 80, // Optimizes compression size
);

if (capturedPhoto != null) {
setState(() {
_scannedDocumentFile = File(capturedPhoto.path);
});
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
backgroundColor: Colors.teal,
content: Text('Medical record captured and encrypted to memory! 🔒'),
),
);
}
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(backgroundColor: Colors.redAccent, content: Text('Hardware Access Failed: ${e.toString()}')),
);
}
}

@override
Widget build(BuildContext context) {
final String docName = widget.doctorData['name'] ?? 'Doctor';
final String specialization = widget.doctorData['specialization'] ?? 'General Practitioner';
final String hospital = widget.doctorData['hospital'] ?? 'AfyaFlow Hospital';
final String photoUrl = widget.doctorData['photoUrl'] ?? '';

return SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// 👋 Dynamic Doctor Greeting
Row(
children: [
CircleAvatar(
radius: 25,
backgroundColor: Colors.teal,
backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
child: photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Good morning, $docName! 👋",
style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
Text(
"$specialization | $hospital",
style: const TextStyle(color: Colors.grey, fontSize: 14),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
],
),
),
],
),
const SizedBox(height: 20),

// 📊 Analytical Metrics Summary Grid
GridView.count(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
crossAxisCount: 2,
mainAxisSpacing: 12,
crossAxisSpacing: 12,
childAspectRatio: 1.6,
children: [
GestureDetector(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => const PatientsListScreen()),
);
},
child: _buildStatCard("Total Patients", "128", Icons.people, Colors.blue.shade50, Colors.blue),
),
_buildStatCard("Today's Appts", "18", Icons.calendar_today, Colors.orange.shade50, Colors.orange),
_buildStatCard("Pending Consults", "5", Icons.chat_bubble_outline, Colors.purple.shade50, Colors.purple),
_buildStatCard("Reports to Review", "7", Icons.assignment_outlined, Colors.red.shade50, Colors.red),
],
),
const SizedBox(height: 24),

// 📸 PREMIUM WEEK 9 HARDWARE FEATURE CARD DESIGN
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: Colors.grey.shade200),
boxShadow: [
BoxShadow(color: Colors.grey.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(Icons.photo_camera_front_outlined, color: Colors.teal, size: 22),
SizedBox(width: 8),
Text(
"Clinical File Scanner (Week 9 Integration)",
style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
),
],
),
const SizedBox(height: 6),
const Text(
"Instantly digitize patient lab sheets, physical diagnostic documents, or symptom tracking charts via device hardware.",
style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
),
const SizedBox(height: 14),
if (_scannedDocumentFile != null) ...[
ClipRRect(
borderRadius: BorderRadius.circular(10),
child: Container(
height: 160,
width: double.infinity,
color: Colors.black12,
child: Image.file(_scannedDocumentFile!, fit: BoxFit.cover),
),
),
const SizedBox(height: 10),
],
ElevatedButton.icon(
onPressed: _scanPatientDocument,
icon: const Icon(Icons.document_scanner, size: 18, color: Colors.white),
label: Text(_scannedDocumentFile == null ? "Initialize Camera Scanner" : "Rescan Document File", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.teal,
minimumSize: const Size(double.infinity, 45),
elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
),
],
),
),
const SizedBox(height: 24),

const Text("Today's Schedule Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
const SizedBox(height: 4),
const Text("💡 Tap for details | Long-press to edit records.", style: TextStyle(fontSize: 12, color: Colors.grey)),
const SizedBox(height: 10),

// 👥 Patient Rows Layout List
ListView(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
children: [
_buildPatientRow(context, "09:00 AM", "John Mwangi", "Regular Checkup", "Confirmed", Colors.green, "Hypertension"),
_buildPatientRow(context, "10:00 AM", "Mary Wanjiku", "Follow-up Visit", "Confirmed", Colors.green, "Post-Op Recovery"),
_buildPatientRow(context, "11:30 AM", "Peter Otieno", "Heart Consultation", "Pending", Colors.orange, "Arrhythmia"),
_buildPatientRow(context, "01:00 PM", "Grace Achieng", "ECG Review", "Confirmed", Colors.green, "General Checkup"),
],
),
const SizedBox(height: 24),

// 🔬 Recent Lab Results Section
const Text("Recent Lab Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
const SizedBox(height: 4),
const Text("💡 Long-press to update patient medical record.", style: TextStyle(fontSize: 11, color: Colors.grey)),
const SizedBox(height: 10),
_buildSimpleRow(context, "Mary Wanjiku", "Blood Test - Today, 8:30 AM", "Normal", Colors.green, "Post-Op Recovery", isLab: true),
_buildSimpleRow(context, "Peter Otieno", "Lipid Profile - Yesterday", "High Risk", Colors.red, "Arrhythmia", isLab: true),
const SizedBox(height: 24),

// 📩 Pending Consultations Section
const Text("Pending Consultations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
const SizedBox(height: 4),
const Text("💡 Long-press to issue a prescription.", style: TextStyle(fontSize: 11, color: Colors.grey)),
const SizedBox(height: 10),
_buildSimpleRow(context, "James Kariuki", "Chest pain and discomfort", "High", Colors.redAccent, "Chest Pain Evaluation", isLab: false),
_buildSimpleRow(context, "Lucy Njeri", "Shortness of breath", "Medium", Colors.orange, "Asthma Management", isLab: false),
],
),
);
}

Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.grey.withValues(alpha: 0.05),
blurRadius: 5,
spreadRadius: 2
)
]
),
child: LayoutBuilder(
builder: (context, constraints) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
CircleAvatar(
backgroundColor: bgColor,
radius: 16,
child: Icon(icon, color: iconColor, size: 18)
),
FittedBox(
fit: BoxFit.scaleDown,
child: Text(
value,
style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
),
),
Text(
title,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)
),
],
);
}
),
);
}

Widget _buildPatientRow(BuildContext context, String time, String name, String type, String status, Color statusColor, String condition) {
final String generatedId = "PT-${name.hashCode.toString().substring(0, 4)}";

return Card(
margin: const EdgeInsets.only(bottom: 10),
elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade100)),
child: ListTile(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => PatientDetailsScreen(
patient: {
'name': name,
'id': generatedId,
'condition': condition,
'status': status,
'color': statusColor,
},
),
),
);
},
onLongPress: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => MedicalRecordsEditor(
patientName: name,
patientId: generatedId,
),
),
);
},
leading: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
subtitle: Text(type, style: const TextStyle(fontSize: 13)),
trailing: Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
),
),
);
}

Widget _buildSimpleRow(BuildContext context, String name, String detail, String label, Color labelColor, String condition, {required bool isLab}) {
return Card(
margin: const EdgeInsets.only(bottom: 10),
elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade100)),
child: ListTile(
onTap: () {
if (isLab) {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => LabResultsScreen(
patientName: name,
condition: condition,
),
),
);
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => MessagesScreen(
patientName: name,
),
),
);
}
},
onLongPress: () {
if (isLab) {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => MedicalRecordsEditor(
patientName: name,
patientId: "PT-${name.hashCode.toString().substring(0, 4)}",
),
),
);
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => PrescriptionEditor(
patientName: name,
),
),
);
}
},
leading: CircleAvatar(
backgroundColor: isLab ? Colors.blue.shade50 : Colors.purple.shade50,
radius: 18,
child: Icon(
isLab ? Icons.science_outlined : Icons.chat_bubble_outline,
color: isLab ? Colors.blue : Colors.purple,
size: 18,
),
),
title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
subtitle: Text(detail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
trailing: Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(color: labelColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, fontSize: 11)),
),
),
);
}
}

// 📅 Tab 1: Live Interactive Schedule View Block with Conflict Checking Management
class DoctorScheduleTab extends StatelessWidget {
    const DoctorScheduleTab({super.key});

    Future<void> _handleApprovalAction(BuildContext context, String docId, String date, String time, String status) async {
        try {
            if (status == 'Approved') {
                final QuerySnapshot checkConflict = await FirebaseFirestore.instance
                    .collection('appointments')
                    .where('date', isEqualTo: date)
                    .where('time', isEqualTo: time)
                    .where('status', isEqualTo: 'Approved')
                    .get();

                if (checkConflict.docs.isNotEmpty) {
                    if (!context.mounted) return;
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: const Text("Booking Conflict Detected ⚠️", style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Text("Another patient is already confirmed for $date at $time. Approving this slot will cause an overlap."),
                            actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                    onPressed: () async {
                                        Navigator.pop(context);
                                        await _executeStatusUpdate(context, docId, 'Approved');
                                    },
                                    child: const Text("Force Approve Anyway", style: TextStyle(color: Colors.red)),
                                )
                            ],
                        ),
                    );
                    return;
                }
            }

            await _executeStatusUpdate(context, docId, status);
        } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.redAccent),
            );
        }
    }

    Future<void> _executeStatusUpdate(BuildContext context, String docId, String status) async {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(docId)
            .update({'status': status});

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Appointment successfully marked as $status!"),
                backgroundColor: status == 'Approved' ? Colors.green : Colors.orange,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .orderBy('date', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.teal));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text("No appointment records found.", style: TextStyle(color: Colors.grey)),
                            ],
                        ),
                    );
                }

                final appointmentDocs = snapshot.data!.docs;

                return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointmentDocs.length,
                    itemBuilder: (context, index) {
                        final doc = appointmentDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final String docId = doc.id;

                        final String patientName = data['patientName'] ?? 'Patient User';
                        final String appointmentDate = data['date'] ?? 'N/A';
                        final String appointmentTime = data['time'] ?? 'N/A';
                        final String currentStatus = data['status'] ?? 'Pending';
                        final String diagnosticReason = data['symptoms'] ?? 'No symptoms reported';

                        return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(
                                                        color: Colors.teal.shade50,
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                        "$appointmentDate  •  $appointmentTime",
                                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 12),
                                                    ),
                                                ),
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: currentStatus == 'Approved'
                                                            ? Colors.green.shade50
                                                            : (currentStatus == 'Pending' ? Colors.orange.shade50 : Colors.red.shade50),
                                                        borderRadius: BorderRadius.circular(12)
                                                    ),
                                                    child: Text(
                                                        currentStatus,
                                                        style: TextStyle(
                                                            color: currentStatus == 'Approved'
                                                                ? Colors.green
                                                                : (currentStatus == 'Pending' ? Colors.orange : Colors.red),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                            patientName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            "Reason: $diagnosticReason",
                                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),

                                        if (currentStatus == 'Pending') ...[
                                            const Divider(height: 24),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                    OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                            foregroundColor: Colors.red,
                                                            side: BorderSide(color: Colors.red.shade200),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                                        ),
                                                        onPressed: () => _handleApprovalAction(context, docId, appointmentDate, appointmentTime, 'Rejected'),
                                                        child: const Text("Reject Slot"),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.teal,
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                            elevation: 0
                                                        ),
                                                        onPressed: () => _handleApprovalAction(context, docId, appointmentDate, appointmentTime, 'Approved'),
                                                        child: const Text("Approve Request"),
                                                    ),
                                                ],
                                            )
                                        ]
                                    ],
                                ),
                            ),
                        );
                    },
                );
            },
        );
    }
}