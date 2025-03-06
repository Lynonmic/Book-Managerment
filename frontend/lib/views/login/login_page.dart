import 'package:flutter/material.dart';
import 'package:frontend/views/book/book_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email và mật khẩu không được để trống!");
      return;
    }

    try {
      print("🔹 Gửi request đến API...");
      print("📤 URL: http://10.0.2.2:9090/quanly_sach/auth/login");
      print("📤 Headers: ${{"Content-Type": "application/json"}}");
      print("📤 Body: ${jsonEncode({"email": email, "password": password})}");

      var response = await http.post(
        Uri.parse("http://10.0.2.2:9090/quanly_sach/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("🔹 Nhận phản hồi từ API...");
      print("📥 Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        String token = response.body;
        print("✅ Đăng nhập thành công, Token: $token");
        _showMessage("Đăng nhập thành công!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookPage()),
        );
      } else {
        _showMessage("❌ Sai email hoặc mật khẩu!");
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối: $e");
      _showMessage("Lỗi kết nối đến server!");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        117,
        222,
        217,
        217,
      ), // Nền màu xám nhạt
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề LOGIN
              const Center(
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Text("User", style: TextStyle(color: Colors.white)),
              // Ô nhập Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Nền trắng
                  hintText: "Nhập email...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.black),
                ),
              ),

              const SizedBox(height: 20),
              Text("Password", style: TextStyle(color: Colors.white)),
              // Ô nhập Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Nền trắng
                  hintText: "Nhập mật khẩu...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // Logo
              Center(
                child: Image.asset(
                  'lib/assets/images/logo.png', // Đặt ảnh logo trong thư mục assets
                  height: 300,
                ),
              ),

              const SizedBox(height: 20),
              // Nút Đăng nhập
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.purpleAccent, // Màu trắng
                    foregroundColor: Colors.white, // Màu chữ đen
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("Submit"),
                ),
              ),
              const SizedBox(height: 10),

              // Nút Đăng ký
              Center(
                child: TextButton(
                  onPressed: () {
                    // Chuyển sang trang đăng ký
                  },
                  child: const Text(
                    "Chưa có tài khoản? Đăng ký ngay",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
