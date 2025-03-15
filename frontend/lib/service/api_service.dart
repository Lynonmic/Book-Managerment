import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/PublisherModels.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:9090/quanly_sach/auth";

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "token": responseJson["token"]};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Sai email hoặc mật khẩu!",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }

  static Future<Map<String, dynamic>> registerUser(
    String tenKhachHang,
    String email,
    String password,
    String phone,
    String address,
    File? avatar,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/register");
      var request = http.MultipartRequest("POST", uri);

      // ✅ Gửi từng trường dữ liệu riêng lẻ
      request.fields['ten_khach_hang'] = tenKhachHang;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;
      request.fields['address'] = address;

      // ✅ Kiểm tra nếu có ảnh thì thêm vào request
      if (avatar != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "avatar",
            avatar.path,
            contentType: MediaType("image", "jpeg"), // 🔥 Định dạng ảnh
          ),
        );
      }

      // ✅ Thêm header (không cần Content-Type, vì MultipartRequest tự thêm)
      request.headers.addAll({"Accept": "application/json"});

      // Gửi request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var responseJson = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return {"success": true, "message": responseJson["message"]};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Đăng ký thất bại",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server"};
    }
  }

  static Future<Map<String, dynamic>> getAllPublisher() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/nha-xuat-ban"),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );

      print("🔍 API Response Code: ${response.statusCode}");
      print("📡 API Response Body: ${response.body}");
      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Publishermodels> publishers =
            (responseJson as List)
                .map((json) => Publishermodels.fromJson(json))
                .toList();

        return {"success": true, "data": publishers};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Lỗi lấy dữ liệu!",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }
}
