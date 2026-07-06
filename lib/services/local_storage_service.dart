import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _loginStatusKey = 'is_logged_in';
  static const String _patientEmailKey = 'patient_email';
  static const String _patientNameKey = 'patient_name';
  static const String _profileImageKey = 'profile_image_path';
  static const String _bloodGroupKey = 'blood_group';
  static const String _weightKey = 'weight';
  static const String _userRoleKey = 'user_role'; // Key for role management

  // 🚀 FIXED: Now accepts the real name directly from your database user map!
  static Future<void> savePatientSession(String email, String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, true);
    await prefs.setString(_patientEmailKey, email);
    await prefs.setString(_patientNameKey, name); // Saves the true database name!
  }

  static Future<String> getPatientName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_patientNameKey) ?? "Patient";
  }

  // Profile Data Accessors
  static Future<String?> getProfileImagePath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  static Future<String> getBloodGroup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bloodGroupKey) ?? "--";
  }

  static Future<String> getWeight() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_weightKey) ?? "--";
  }

  static Future<void> saveProfileData({String? imagePath, String? bloodGroup, String? weight}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (imagePath != null) await prefs.setString(_profileImageKey, imagePath);
    if (bloodGroup != null) await prefs.setString(_bloodGroupKey, bloodGroup);
    if (weight != null) await prefs.setString(_weightKey, weight);
  }

  // Role Management Methods
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}