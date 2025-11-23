import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_log.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class HealthService {
  final AuthService _authService = AuthService();

  // 🔹 Add new health log
  Future<HealthLog?> addLog(HealthLog log) async {
    final url = Uri.parse("$BASE_URL/health/add");
    final headers = await _authService.getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(log.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return HealthLog.fromJson(data['log']);
    } else {
      throw Exception(data['message'] ?? "Failed to add log");
    }
  }

  // 🔹 Get today's logs
  Future<List<HealthLog>> getTodayLogs() async {
    final url = Uri.parse("$BASE_URL/health/today");
    final headers = await _authService.getAuthHeaders();

    final response = await http.get(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<HealthLog>.from(data.map((x) => HealthLog.fromJson(x)));
    } else {
      throw Exception(data['message'] ?? "Failed to fetch today's logs");
    }
  }

  // 🔹 Get logs in a date range
  Future<List<HealthLog>> getLogs({DateTime? start, DateTime? end}) async {
    final queryParams = {
      if (start != null) 'startDate': start.toIso8601String(),
      if (end != null) 'endDate': end.toIso8601String(),
    };

    final uri = Uri.parse("$BASE_URL/health").replace(queryParameters: queryParams);
    final headers = await _authService.getAuthHeaders();

    final response = await http.get(uri, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<HealthLog>.from(data.map((x) => HealthLog.fromJson(x)));
    } else {
      throw Exception(data['message'] ?? "Failed to fetch logs");
    }
  }

  // 🔹 Get today's summary
  Future<Map<String, dynamic>> getTodaySummary() async {
    final url = Uri.parse("$BASE_URL/health/summary");
    final headers = await _authService.getAuthHeaders();

    final response = await http.get(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? "Failed to fetch today's summary");
    }
  }

  // 🔹 Update a log
  Future<HealthLog?> updateLog(String id, Map<String, dynamic> updateData) async {
    final url = Uri.parse("$BASE_URL/health/$id");
    final headers = await _authService.getAuthHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(updateData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return HealthLog.fromJson(data);
    } else {
      throw Exception(data['message'] ?? "Failed to update log");
    }
  }

  // 🔹 Delete a log
  Future<void> deleteLog(String id) async {
    final url = Uri.parse("$BASE_URL/health/$id");
    final headers = await _authService.getAuthHeaders();

    final response = await http.delete(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? "Failed to delete log");
    }
  }
}
