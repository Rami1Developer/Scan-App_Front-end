import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scan_app/views/terms.dart';
import 'package:scan_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      Constants.baseUrl; // Remplacez par l'URL de votre backend

  Future<http.Response> signUp(Map<String, dynamic> signupData) async {
    print("signup data : $signupData ...");
    final url = Uri.parse('$baseUrl${Constants.signup}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(signupData),
    );
    return response;
  }

  Future<http.Response> confirmEmail(String token) async {
    final url = Uri.parse('$baseUrl${Constants.confirmEmail}?token=$token');
    final response = await http.get(url);
    return response;
  }

  Future<http.Response> login(Map<String, dynamic> credentials) async {
    final url = Uri.parse('$baseUrl${Constants.login}');
    print(url);
    print("login ...");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials),
    );
    return response;
  }

  Future<http.Response> refreshTokens(String refreshToken) async {
    final url = Uri.parse('$baseUrl${Constants.refreshTokens}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    return response;
  }

  Future<http.Response> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl${Constants.changePassword}');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'oldPassword':oldPassword,
        'newPassword': newPassword,
        'userId': userId
      }),
    );
    return response;
  }

  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl${Constants.forgotPassword}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response;
  }

  Future<http.Response> verifyOtp(String recoveryCode) async {
    final url = Uri.parse('$baseUrl${Constants.verifyOtp}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'recoveryCode': recoveryCode}),
    );
    return response;
  }

  Future<http.Response> resetPassword(
      String resetToken, String newPassword) async {
    final url = Uri.parse('$baseUrl${Constants.resetPassword}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'resetToken': resetToken, 'newPassword': newPassword}),
    );
    return response;
  }

  Future<http.Response> googleLogin() async {
    final url = Uri.parse('$baseUrl${Constants.googleLogin}');
    final response = await http.get(url);
    return response;
  }

  Future<http.Response> updateUserInfo(String name, String email) async {
    final url = Uri.parse('$baseUrl${Constants.updateUser}');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId")!;
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'userId': userId}),
    );
    return response;
  }

  Future<http.Response> getAllUsers() async {
    final url = Uri.parse('$baseUrl${Constants.getAllUsers}');
    final response = await http.get(url);
    return response;
  }
}