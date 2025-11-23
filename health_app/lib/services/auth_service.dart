import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  // 🔹 Register user
  Future<User?> registerUser(
      String name,
      String email,
      String password,
      int age,
      double? height,
      double? weight
  ) async {
    final url = Uri.parse("$BASE_URL/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "age": age,
        "height": height,
        "weight": weight
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // 🛡️ Safe Cast
      final userJson = Map<String, dynamic>.from(data["user"]);
      userJson["token"] = data["token"]; 

      final user = User.fromJson(userJson);

      await saveToken(user.token!);
      return user;
    } else {
      throw Exception(data["message"] ?? "Registration failed");
    }
  }

  // 🔹 Login user
  Future<User?> loginUser(String email, String password) async {
    final url = Uri.parse("$BASE_URL/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // 🛡️ Safe Cast
      final userJson = Map<String, dynamic>.from(data["user"]);
      userJson["token"] = data["token"];

      final user = User.fromJson(userJson);

      await saveToken(user.token!);
      return user;
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  // 🔹 Update User Goals/Profile (FIXED)
  Future<User?> updateUserGoals(Map<String, dynamic> updates) async {
    final url = Uri.parse("$BASE_URL/auth/update");
    final headers = await getAuthHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      
      // 🛡️ Check for null and cast safely
      if (decodedData != null) {
        final userMap = Map<String, dynamic>.from(decodedData);
        return User.fromJson(userMap);
      }
      return null;
    } else {
      throw Exception("Failed to update goals");
    }
  }

  // 🔹 Get Current User Profile (NEW)
  Future<User?> getUserProfile() async {
    final url = Uri.parse("$BASE_URL/auth/profile");
    final headers = await getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to fetch profile");
    }
  }

  // 🔹 Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  // 🔹 Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // 🔹 Auth headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // 🔹 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}