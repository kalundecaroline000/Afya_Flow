import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 📍 Added for Paired Week 9 GPS Hardware Tracking

// Service Imports
import '../services/local_storage_service.dart';
import '../services/network_service.dart';
import '../services/hospital_service.dart';

// Screen Imports
import 'booking_screen.dart'; // ✅ Now Active: Find Doctor
import 'records_screen.dart';
import 'messages_screen.dart'; // ✅ Now Active: Direct Inbox
import 'profile_screen.dart';
import 'prescriptions_screen.dart';
import 'billing_screen.dart';
import 'notifications_screen.dart';
import 'patient_screen.dart'; // ✅ Now Active: Secure Logout
import 'my_appointments_screen.dart'; // ✅ Contains PatientAppointmentsScreen
import 'patient_chat gateway_screen.dart'; // ✅ Integrated Gateway Chat Screen

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;
  String _displayName = "";
  String? _profileImagePath;
  bool _isLoading = true;
  List<dynamic> _hospitalsList = [];
  final NetworkService _networkService = NetworkService();

  // 📍 Week 9 State Elements to hold live tracking variables
  String _gpsCoordinatesDisplay = "Not Transmitted";
  bool _isFetchingGPS = false;

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    _loadDashboardData();
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
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
      if (name.isNotEmpty && name != "Patient") _displayName = name;
      _profileImagePath = imagePath;
      _hospitalsList = hospitals;
      _isLoading = false;
    });
  }

  // 📍 Paired Week 9 Integration Function: Verifies permission status and polls Fused Location coordinates
  Future<void> transmitGPSLocation() async {
    setState(() => _isFetchingGPS = true);

    try {
      // 1. Check if device location services are turned on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isFetchingGPS = false);
        _showGpsSnackBar('Please enable location services.', Colors.orange);
        return;
      }

      // 2. Request phone permissions programmatically
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isFetchingGPS = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isFetchingGPS = false);
        _showGpsSnackBar("Location permissions are permanently denied.", Colors.redAccent);
        return;
      }

      // 3. Successfully fetch coordinates from the phone hardware
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      // 4. Update the UI state with the real coordinates
      if (!mounted) return;
      setState(() {
        _gpsCoordinatesDisplay =
        "Lat: ${position.latitude.toStringAsFixed(4)}\nLon: ${position.longitude.toStringAsFixed(4)}";
        _isFetchingGPS = false;
      });

      _showGpsSnackBar("Coordinates captured! Emergency Services Dispatched 🚨", Colors.teal);
    } catch (e) {
      if (mounted) setState(() => _isFetchingGPS = false);
      _showGpsSnackBar("GPS Timeout or error. Please try again.", Colors.redAccent);
    }
  }

  void _showGpsSnackBar(String message, Color statusColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: statusColor,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _displayName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              accountEmail: const Text("Patient Portal Active", style: TextStyle(color: Colors.white70)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: const Icon(Icons.person, size: 45, color: Colors.teal),
              ),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
              child: Text("Account Preferences", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.teal),
              title: const Text('App Settings'),
              subtitle: const Text('Manage notifications and preferences'),
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(indent: 16, endIndent: 16),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
              child: Text("Help & Resources", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            ListTile(
              leading: const Icon(Icons.contact_support_outlined, color: Colors.teal),
              title: const Text('Health & Support'),
              subtitle: const Text('FAQs, terms, and customer care help'),
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Log Out Securely', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              onTap: () async {
                await LocalStorageService.clearSession();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const PatientScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_getDynamicGreeting()}, $_displayName 👋",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                const Text("Your health, our priority 🩵", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
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
              _buildActionItem('Billing\nPortal', Icons.receipt_long, Colors.orange, const BillingScreen()),
              _buildActionItem('Find\nDoctor', Icons.person_search, Colors.teal, const BookingScreen()),
              _buildActionItem('Chat with\nDoctor', Icons.chat_bubble, const Color(0xFF2563EB), const PatientChatGatewayScreen()),
              _buildActionItem('Direct\nInbox', Icons.mail_outline, Colors.blueGrey, MessagesScreen(patientName: _displayName)),
              _buildActionItem('Book AI\nAppt', Icons.auto_awesome, const Color(0xFF0D9488), const PatientAppointmentsScreen()),
              _buildActionItem('My\nRecords', Icons.assignment, const Color(0xFF6366F1), const RecordsScreen()),
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.g_mobiledata, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 2),
                      Text("GPS Emergency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red.shade900)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    child: _isFetchingGPS
                        ? const Center(child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent)))
                        : Text(
                      _gpsCoordinatesDisplay,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade800, fontFamily: 'monospace', height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: transmitGPSLocation,
                    child: const Text("Transmit GPS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
              _buildRecordTile("Prescription", "05 May 2025", "Active", Colors.green.shade50, Icons.medication, Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTile(String title, String date, String status, Color bgColor, IconData icon, Color iconColor) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: bgColor, child: Icon(icon, color: iconColor)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPremiumBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientAppointmentsScreen()));
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0D9488),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Book Appt"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Profile"),
      ],
    );
  }
}