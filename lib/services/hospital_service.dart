import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class HospitalService {
  Future<List<dynamic>> fetchAndCacheHospitals() async {
    final url = Uri.parse('https://api.afyaflow.or.ke/v1/hospitals');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> hospitals = json.decode(response.body);

        // Cache them into SQLite database locally
        for (var hospital in hospitals) {
          await DatabaseHelper.instance.cacheHospital(
            hospital['id'].toString(),
            hospital['name'],
            hospital['location'],
          );
        }
        return hospitals;
      }
    } catch (e) {
      debugPrint("⚠️ Offline Mode: Fetching backend data failed. Defaulting to local SQLite cache.");
    }

    // ✅ Fallback: Return data from local database if API is unreachable
    return await DatabaseHelper.instance.getAllHospitals();
  }
}
