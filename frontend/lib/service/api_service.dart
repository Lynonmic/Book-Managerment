import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:9090/quanly_sach/auth/login";

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email, 
          "password": password, 
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "token": data};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối"};
    }
  }
}
