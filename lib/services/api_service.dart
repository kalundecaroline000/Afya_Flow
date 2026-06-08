import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/doctor_model.dart';

class ApiService {
  // Simulating an API request with a 2-second delay to showcase asynchronous states to your lecturer
  static Future<List<Doctor>> fetchAvailableDoctors() async {
    await Future.delayed(const Duration(seconds: 2));

    // Sample mock JSON data array representing an API server response stream
    final String mockJsonResponse = '''
    [
      {"name": "Dr. Emmanuel Mwangi", "specialty": "Cardiologist", "isAvailable": true},
      {"name": "Dr. Cynthia Akoth", "specialty": "Pediatrician", "isAvailable": true},
      {"name": "Dr. Silas Kamau", "specialty": "Dermatologist", "isAvailable": false}
    ]
    ''';

    final List<dynamic> parsedList = json.decode(mockJsonResponse);
    return parsedList.map((jsonItem) => Doctor.fromJson(jsonItem)).toList();
  }
}