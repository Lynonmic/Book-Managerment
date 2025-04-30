import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/model/PublisherModels.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/model/book_model.dart';
import 'package:frontend/model/category_model.dart';
import 'package:frontend/model/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:9090/book_management/auth";
  static const String apiUrl = "http://10.0.2.2:3000/api";

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"), // Đảm bảo endpoint chính xác
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("📌 Response status: ${response.statusCode}");
      print("📌 Response body: ${response.body}");

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "token": responseJson["token"],
          "role": responseJson["role"], // Lấy role từ API
          "userData": responseJson["userData"] ?? {}, // ✅ Lấy userData
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Sai email hoặc mật khẩu!",
        };
      }
    } catch (e) {
      print("❌ Lỗi kết nối đến server: $e");
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

  static Future<List<UserModels>> getAllUser() async {
    try {
      print("===== CALLING API: $baseUrl/users =====");
      final response = await http.get(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
      );
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => UserModels.fromJson(json)).toList();
      } else {
        throw Exception("Lỗi lấy dữ liệu từ server!");
      }
    } catch (e) {
      print("API Error: $e");
      throw Exception("Lỗi kết nối đến server: $e");
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final responseJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "user": responseJson};
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Lỗi khi lấy thông tin!",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }

  static Future<Map<String, dynamic>?> updateUser({
    required int userId,
    String? tenKhachHang,
    String? soDienThoai,
    String? diaChi,
    String? email,
    File? avatar,
  }) async {
    try {
      debugPrint("🔹 Chuẩn bị gửi request cập nhật user...");

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("$baseUrl/users/update/$userId"),
      );
      request.headers["Accept"] = "application/json";
      request.headers["Content-Type"] = "multipart/form-data";

      if (tenKhachHang != null) request.fields["tenKhachHang"] = tenKhachHang;
      if (soDienThoai != null) request.fields["soDienThoai"] = soDienThoai;
      if (diaChi != null) request.fields["diaChi"] = diaChi;
      if (email != null) request.fields["email"] = email;

      if (avatar != null) {
        String? mimeType = lookupMimeType(avatar.path);
        var multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      debugPrint("📥 Phản hồi từ server: ${response.body}");

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse is Map) {
        return jsonResponse.cast<String, dynamic>();
      } else {
        return {"success": false, "message": "Dữ liệu phản hồi không hợp lệ!"};
      }
    } catch (e) {
      debugPrint("❌ Lỗi gửi request: $e");
      return {"success": false, "message": "Lỗi kết nối đến server!"};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    final url = Uri.parse("$baseUrl/users/$userId");

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message":
              jsonDecode(response.body)["message"] ?? "Lỗi không xác định",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối"};
    }
  }

  static Future<bool> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      }),
    );

    return response.statusCode == 200;
  }

  Future<List<UserModels>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?keyword=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserModels.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  // Book API Methods
  static Future<List<Book>> getAllBooks() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/books"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch books");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Book> getBookById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/books/$id"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return Book.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Book not found");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> createBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/books"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(book.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Book added successfully",
          "bookId": responseJson["bookId"],
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to add book",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateBook(int id, Book book) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/books/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(book.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Book updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to update book",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteBook(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/books/$id"),
        headers: {"Content-Type": "application/json"},
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Book deleted successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to delete book",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> rateBook(
    int bookId,
    double rating,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/books/$bookId/rate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"rating": rating}),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Book rated successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to rate book",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  // Category API Methods
  static Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/categories"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch categories");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<CategoryModel> getCategoryById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/categories/$id"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return CategoryModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Category not found");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> createCategory(
    CategoryModel category,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/categories"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(category.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Category created successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to create category",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateCategory(
    int id,
    CategoryModel category,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/categories/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(category.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Category updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to update category",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/categories/$id"),
        headers: {"Content-Type": "application/json"},
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Category deleted successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to delete category",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  // Order API Methods
  static Future<List<Order>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/orders"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch orders");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Order> getOrderById(String id) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/orders/$id"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Order not found");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Order> getOrderWithDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/orders/$id/with-details"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Order not found");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> createOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(order.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Order created successfully",
          "orderId": responseJson["orderId"],
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to create order",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateOrder(
    String id,
    Order order,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/orders/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(order.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Order updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to update order",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse("$apiUrl/orders/$id/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message":
              responseJson["message"] ?? "Order status updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to update order status",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteOrder(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/orders/$id"),
        headers: {"Content-Type": "application/json"},
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Order deleted successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to delete order",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<List<OrderDetail>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/orders/$orderId/details"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => OrderDetail.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch order details");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> addOrderDetail(
    String orderId,
    OrderDetail detail,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/orders/$orderId/details"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(detail.toJson()),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message":
              responseJson["message"] ?? "Order detail added successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to add order detail",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  // Review/Evaluation API Methods
  static Future<List<dynamic>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/reviews"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch reviews");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<dynamic> getReviewById(String id) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/reviews/$id"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Review not found");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<List<dynamic>> getReviewsByBookId(String bookId) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/reviews/book/$bookId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch reviews for book");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<double> getBookAverageRating(String bookId) async {
    try {
      final response = await http.get(
        Uri.parse("$apiUrl/reviews/book/$bookId/rating"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['averageRating'] as num).toDouble();
      } else {
        throw Exception("Failed to fetch book rating");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  static Future<Map<String, dynamic>> createReview(
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/reviews"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reviewData),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Review created successfully",
          "reviewId": responseJson["reviewId"],
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to create review",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> updateReview(
    String id,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/reviews/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reviewData),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Review updated successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to update review",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteReview(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/reviews/$id"),
        headers: {"Content-Type": "application/json"},
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseJson["message"] ?? "Review deleted successfully",
        };
      } else {
        return {
          "success": false,
          "message": responseJson["message"] ?? "Failed to delete review",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }
}
