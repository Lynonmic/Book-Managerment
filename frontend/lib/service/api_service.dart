import 'dart:convert';
import 'dart:io';
import 'package:frontend/model/PublisherModels.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:9090/book_management/auth";

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

  static Future<List<Publishermodels>> getAllPublisher() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/nha-xuat-ban"),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    print("🔍 API Response Code: ${response.statusCode}");
    print("📡 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Publishermodels.fromJson(json)).toList();
    } else {
      throw Exception("Lỗi lấy dữ liệu từ server!");
    }
  } catch (e) {
    throw Exception("Lỗi kết nối đến server: $e");
  }
}


  static Future<Map<String, dynamic>> createPublisher(
    String tenNhaXuatBan,
    String diaChi,
    String sdt,
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/nha-xuat-ban"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ten_nha_xuat_ban": tenNhaXuatBan,
          "dia_chi": diaChi,
          "so_dien_thoai": sdt,
          "email": email,
        }),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": responseJson["message"]};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Nhà xuất bản đã tồn tại!",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }

  static Future<Map<String, dynamic>> deletePublisher(int maNhaXuatBan) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/nha-xuat-ban/$maNhaXuatBan"),
        headers: {"Content-Type": "application/json"},
      );

      print("Response: ${response.body}");

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": responseJson["message"]};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Lỗi xóa nhà xuất bản!",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }

  static Future<Map<String, dynamic>> update(
    int manxb,
    String name,
    String address,
    String phone,
    String email,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/nha-xuat-ban/$manxb"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ten_nha_xuat_ban": name,
          "dia_chi": address,
          "so_dien_thoai": phone,
          "email": email,
        }),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": responseJson["message"]};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Lỗi cập nhật nhà xuất bản!",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }
}
