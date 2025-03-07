import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:9090/quanly_sach/auth/login";

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      print("🔹 Gửi request đến API...");
      print("📤 URL: $baseUrl");
      print("📤 Headers: {Content-Type: application/json}");
      print("📤 Body: ${jsonEncode({"email": email, "password": password})}");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("🔹 Nhận phản hồi từ API...");
      print("📥 Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {"success": true, "token": response.body}; // Trả về token trực tiếp
      } else {
        // Parse JSON để lấy thông báo lỗi nếu có
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["message"] ?? "Sai email hoặc mật khẩu!",
        };
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối: $e");
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }
}
