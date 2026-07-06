import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatefulWidget {
  // Pass the logged-in doctor's data dynamically from your login/auth state
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({
    super.key,
    required this.doctorData,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _specializationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with data passed from the logged-in session
    _nameController = TextEditingController(text: widget.doctorData['name'] ?? 'Doctor');
    _specializationController = TextEditingController(text: widget.doctorData['specialization'] ?? 'General Practitioner');
    _phoneController = TextEditingController(text: widget.doctorData['phone'] ?? '+254 700 000 000');
    _emailController = TextEditingController(text: widget.doctorData['email'] ?? 'doctor@afyaflow.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008080);
    const Color lightTeal = Color(0xFFE0F2F1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_note, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save actions would go here (e.g., update Database/API)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Profile Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 51,
                      backgroundColor: Colors.teal[100],
                      child: Icon(Icons.person, size: 55, color: primaryTeal), // Generic icon placeholder
                    ),
                  ),
                  const SizedBox(height: 16),

                  _isEditing
                      ? TextField(
                    controller: _nameController,
                    textAlign: Alignment.center == Alignment.center ? TextAlign.center : TextAlign.left,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Enter Name",
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  )
                      : Text(
                    _nameController.text,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),

                  _isEditing
                      ? TextField(
                    controller: _specializationController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.teal[100], fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: "Enter Specialization",
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  )
                      : Text(
                    _specializationController.text,
                    style: TextStyle(fontSize: 16, color: Colors.teal[100], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Available Today',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _buildQuickActionCard(Icons.calendar_month_rounded, 'View Schedule', lightTeal, primaryTeal, () {}),
                      _buildQuickActionCard(Icons.people_alt_rounded, 'My Patients', lightTeal, primaryTeal, () {}),
                      _buildQuickActionCard(
                          _isEditing ? Icons.save_rounded : Icons.badge_rounded,
                          _isEditing ? 'Save Profile' : 'Edit Profile',
                          Colors.orange[50]!,
                          Colors.orange[800]!,
                              () {
                            setState(() { _isEditing = !_isEditing; });
                          }
                      ),
                      _buildQuickActionCard(Icons.logout_rounded, 'Logout', Colors.red[50]!, Colors.red[700]!, () {
                        Navigator.pushReplacementNamed(context, '/login');
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard('Experience', widget.doctorData['experience'] ?? '0 Years', Icons.timeline, primaryTeal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard('Doctor ID', widget.doctorData['id'] ?? 'AF-0000', Icons.fingerprint, primaryTeal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Professional Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.local_hospital, 'Hospital', Text(widget.doctorData['hospital'] ?? 'AfyaFlow Hospital')),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.school, 'Qualifications', Text(widget.doctorData['qualifications'] ?? 'Not Specified')),
                          const Divider(height: 24),
                          _buildDetailRow(
                              Icons.email_rounded,
                              'Email Address',
                              _isEditing
                                  ? TextField(controller: _emailController, decoration: const InputDecoration(isDense: true))
                                  : Text(_emailController.text)
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                              Icons.phone_android_rounded,
                              'Phone Number',
                              _isEditing
                                  ? TextField(controller: _phoneController, decoration: const InputDecoration(isDense: true))
                                  : Text(_phoneController.text)
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String label, Color color, Color iconColor, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: iconColor == Colors.teal ? Colors.teal[900] : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, Widget valueWidget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal[700], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 4),
              valueWidget,
            ],
          ),
        ),
      ],
    );
  }
}