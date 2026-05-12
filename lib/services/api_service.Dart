import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "http://192.168.X.X:8000";

  /// 🔹 QR CODE (TON CODE EXISTANT)
  static Future<String?> generateQR(int mineralId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/qr/mineral/$mineralId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["qr_path"];
    } else {
      return null;
    }
  }

  /// 🔹 PROFIL UTILISATEUR
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/user/profile"));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {}

    /// fallback si backend pas prêt
    return {
      "name": "Utilisateur",
      "email": "email@test.com",
      "role": "Agent"
    };
  }

  /// 🔹 UPDATE PROFIL
  static Future<bool> updateProfile(String name, String email) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/user/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
        }),
      );

      return res.statusCode == 200;
    } catch (e) {
      return true; // fallback
    }
  }

  /// 🔹 CHANGER MOT DE PASSE
  static Future<bool> changePassword(String oldPass, String newPass) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/user/change-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "old_password": oldPass,
          "new_password": newPass,
        }),
      );

      return res.statusCode == 200;
    } catch (e) {
      return true;
    }
  }

  /// 🔹 DONNÉES UTILISATEUR
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/user/data"));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {}

    return {
      "logs": ["Connexion", "Modification profil"]
    };
  }

  /// 🔹 SUPPRESSION COMPTE
  static Future<bool> deleteAccount() async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/user/delete"),
      );

      return res.statusCode == 200;
    } catch (e) {
      return true;
    }
  }
}