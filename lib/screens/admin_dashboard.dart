import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  bool _isCheckingRole = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _enforceAdminAuthorization();
  }

  // 🛡️ Security Guard: Verifies the logged-in user is explicitly an Admin in Firestore
  Future<void> _enforceAdminAuthorization() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _kickToLogin();
        return;
      }

      // Read the user role configuration directly from a unified 'users' or 'admins' collection
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        //Verify your key is exactly 'role' in Firestore
        final String role = data?['role'] ?? 'Patient';
        print("DEBUG: User document found. Role value in Firestore is: '$role'");

        if (role.toLowerCase() == 'admin') {
          print("DEBUG: Access granted! Loading admin layout dashboards.");
          setState(() {
            _isAuthorized = true;
            _isCheckingRole = false;
          });
          return;
        }
      } else {
        print(
            "DEBUG: Authorization Failed. No document found matching this UID in the collection.");
      }

      // If it fails authorization, turn off loading state so the screen can render the block message
      setState(() {
        _isAuthorized = false;
        _isCheckingRole = false;
      });

      // If execution reaches here, user is a Patient or Doctor attempting to bypass access
      _triggerAccessBlockedDialog();
    } catch (e) {
      print("DEBUG: Security Guard Exception occurred: ${e.toString()}");
      setState(() {
        _isCheckingRole = false;
      });
      _kickToLogin();
    }
  }

  void _triggerAccessBlockedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 48),
        title: const Text("Access Blocked By Admin 🛑",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "This terminal is restricted exclusively to System Administrators. "
              "Your account does not possess administrative clearance to access this platform.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                _kickToLogin();
              },
              child: const Text("Exit Console"),
            ),
          ),
        ],
      ),
    );
  }

  void _kickToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const AdminOverviewTab();
      case 1:
        return const AdminUserManagementTab();
      default:
        return const AdminOverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    if (!_isAuthorized) {
      return const Scaffold(backgroundColor: Color(0xFFF8FAFC));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("AfyaFlow Central Control",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              _kickToLogin();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'System Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            label: 'User Clearance',
          ),
        ],
      ),
    );
  }
}

// 📊 Admin Sub-Workspace 1: Operations Overview
class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("System Operational Analytics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard("Active Nodes", "2,410", Icons.dns, Colors.green),
              _buildMetricCard("Flagged Breaches", "0", Icons.security, Colors.blue),
              _buildMetricCard("Blocked Attempts", "47", Icons.block, Colors.orange),
              _buildMetricCard("Total Reg Users", "1,892", Icons.people, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// 👥 Admin Sub-Workspace 2: Access Management List
class AdminUserManagementTab extends StatelessWidget {
  const AdminUserManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final String name = user['name'] ?? 'Anonymous Node';
            final String assignedRole = user['role'] ?? 'Patient';
            final bool isApproved = user['isApprovedByAdmin'] ?? true;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: assignedRole == 'Doctor' ? Colors.teal.shade50 : Colors.blue.shade50,
                  child: Icon(
                    assignedRole == 'Doctor' ? Icons.medical_services_outlined : Icons.person_outline,
                    color: assignedRole == 'Doctor' ? Colors.teal : Colors.blue,
                  ),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Access Classification: $assignedRole"),
                trailing: Switch(
                  activeColor: Colors.redAccent,
                  value: !isApproved, // Toggle represents "Is Blocked"
                  onChanged: (bool toggleBlocked) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(users[index].id)
                        .update({'isApprovedByAdmin': !toggleBlocked});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}