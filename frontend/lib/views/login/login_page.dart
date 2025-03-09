import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/views/book/book_page_admin.dart';
import 'package:frontend/views/book/book_page_user.dart';
import 'package:frontend/views/login/signin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isPasswordVisible = false;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email và mật khẩu không được để trống!");
      return;
    }

    if (email == "admin123@gmail.com" && password == "admin123") {
      print("✅ Đăng nhập admin thành công!");
      _showMessage("Đăng nhập admin thành công!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookPageAdmin()),
      );
      return;
    }

    var response = await ApiService.loginUser(email, password);

    if (response["success"]) {
      String token = response["token"];
      print("✅ Đăng nhập thành công, Token: $token");
      _showMessage("Đăng nhập thành công!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookPage()),
      );
    } else {
      _showMessage("❌ ${response["message"]}");
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
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Nền trắng
                  hintText: "Nhập mật khẩu...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible =
                            !isPasswordVisible; // 🔄 Đảo trạng thái
                      });
                    },
                  ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SigninPage(),
                      ),
                    );
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
