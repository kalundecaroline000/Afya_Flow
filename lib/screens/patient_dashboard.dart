import 'dart:io';
import 'package:flutter/material.dart';

// Service Imports
import '../services/local_storage_service.dart';
import '../services/network_service.dart';
import '../services/hospital_service.dart';

// Screen Imports
import 'booking_screen.dart';
import 'records_screen.dart';
import 'profile_screen.dart';
import 'prescriptions_screen.dart';
import 'billing_screen.dart';
import 'notifications_screen.dart';
import 'patient_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;
  String _displayName = "Kalunde"; // Personalized presentation fallback
  String? _profileImagePath;
  bool _isLoading = true;
  List<dynamic> _hospitalsList = [];
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    _loadDashboardData();
  }

  // Helper method to calculate real-time greeting based on device hour
  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  Future<void> _checkNetworkStatus() async {
    final status = await _networkService.checkNetworkConnection();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final name = await LocalStorageService.getPatientName();
    final imagePath = await LocalStorageService.getProfileImagePath();
    final hospitals = await HospitalService().fetchAndCacheHospitals();

    if (!mounted) return;
    setState(() {
      // Updates name dynamically based on who logged in!
      if (name.isNotEmpty && name != "Patient") _displayName = name;
      _profileImagePath = imagePath;
      _hospitalsList = hospitals;
      _isLoading = false;
    });
  }

  Future<void> _navigateToProfile() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const Drawer(),
      appBar: _buildPremiumAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderGreeting(),
            _buildSearchBar(),
            _buildQuickActionsSection(),
            _buildUpcomingAppointmentCard(),
            _buildHospitalAndHealthTipSection(),
            _buildRecentRecordsSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildPremiumBottomNav(),
    );
  }

  // --- PREMIUM UI SECTIONS ---

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 28, errorBuilder: (c, e, s) => const Icon(Icons.local_hospital, color: Color(0xFF0D9488))),
          const SizedBox(width: 6),
          const Text('AfyaFlow', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 28),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        GestureDetector(
          onTap: _navigateToProfile,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
              child: _profileImagePath == null ? const Icon(Icons.person, color: Color(0xFF0D9488)) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 Dynamic Time Greeting + Dynamic Logged-in Name!
              Text(
                "${_getDynamicGreeting()}, $_displayName 👋",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              const Text("Your health, our priority 🩵", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.health_and_safety, color: Color(0xFF0D9488)),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search doctor, service, medicine...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              TextButton(onPressed: () {}, child: const Text("View all", style: TextStyle(color: Color(0xFF0D9488)))),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            children: [
              _buildActionItem('Book\nAppointment', Icons.calendar_month, const Color(0xFF0D9488), const BookingScreen()),
              _buildActionItem('Chat with\nDoctor', Icons.chat_bubble, const Color(0xFF2563EB), const PatientScreen()),
              _buildActionItem('My\nRecords', Icons.assignment, const Color(0xFF6366F1), const RecordsScreen()),
              _buildActionItem('Emergency\nSOS', Icons.notification_important, const Color(0xFFEF4444), const RecordsScreen()),
              _buildActionItem('Pharmacy\nCheck', Icons.medication, const Color(0xFF10B981), const PrescriptionsScreen()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color, Widget destination) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00A3A1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text("Upcoming Appointment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text("Tomorrow", style: TextStyle(color: Colors.white, fontSize: 11)),
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 25),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white30,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dr. Kamau Njoroge", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("General Physician", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    SizedBox(height: 4),
                    Text("15 May 2026  •  10:00 AM", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00A3A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {},
                child: const Text("View Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHospitalAndHealthTipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Box: SQLite database-cached hospital values
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hospital Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    _hospitalsList.isNotEmpty ? _hospitalsList[0]['name'] : "Kenyatta National Hospital",
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                    child: const Text("● Low Queue", style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Text("Est. wait time", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const Text("15 - 20 mins", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Right Box: Dynamic Health Tips block
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Health Tip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  SizedBox(height: 8),
                  Text(
                    "Drink enough water today. It keeps your body and mind fresh.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      CircleAvatar(radius: 3, backgroundColor: Colors.black12),
                      SizedBox(width: 4),
                      CircleAvatar(radius: 3, backgroundColor: Colors.black12),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Records", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              TextButton(onPressed: () {}, child: const Text("View all", style: TextStyle(color: Color(0xFF0D9488)))),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildRecordTile("Blood Test", "12 May 2025", "Normal", Colors.red.shade50, Icons.bloodtype, Colors.red),
              const Divider(height: 1, indent: 60),
              _buildRecordTile("Chest X-Ray", "10 May 2025", "Normal", Colors.blue.shade50, Icons.bubble_chart, Colors.blue),
              const Divider(height: 1, indent: 60),
              _buildRecordTile("Prescription", "08 May 2025", "2 Medicines", Colors.green.shade50, Icons.medication, Colors.green),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRecordTile(String title, String date, String status, Color bgIcon, IconData icon, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgIcon, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text("$date  •  $status", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildPremiumBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF0D9488),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: (i) {
        if (i == 4) {
          _navigateToProfile();
        } else if (i == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen()));
        } else if (i == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordsScreen()));
        } else if (i == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientScreen()));
        } else {
          setState(() => _currentIndex = i);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), label: 'Records'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
      ],
    );
  }
}