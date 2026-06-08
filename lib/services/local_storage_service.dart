import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _loginStatusKey = 'is_logged_in';
  static const String _patientEmailKey = 'patient_email';

  // Save the Patient's Session State when they log in successfully
  static Future<void> savePatientSession(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStatusKey, true);
    await prefs.setString(_patientEmailKey, email);
  }

  // Read the Session State to check if we should auto-login
  static Future<bool> isPatientLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStatusKey) ?? false;
  }

  // Clear the Session data when the patient clicks Logout
  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginStatusKey);
    await prefs.remove(_patientEmailKey);
  }
}