import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _selectedImage; // Biến lưu ảnh đã chọn
  bool isPasswordVisible = false;

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signin() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      _showMessage("⚠️ Vui lòng điền đầy đủ thông tin!");
      return;
    }

    final AuthController authController = AuthController();

    bool success = await authController.registerUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      avatar: _selectedImage,
    );

    if (success) {
      _showMessage("🎉 Đăng ký thành công!", Colors.green);
      Navigator.pop(context);
    } else {
      _showMessage("❌ ${authController.errorMess}");
    }
  }

  void _showMessage(String message, [Color color = Colors.red]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthController();

    return Scaffold(
      backgroundColor: const Color.fromARGB(117, 222, 217, 217),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "SIGN IN",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                      child:
                          _selectedImage == null
                              ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildInputField("Họ và tên", _nameController, Icons.person),
                _buildInputField("Email", _emailController, Icons.email),
                _buildInputField(
                  "Mật khẩu",
                  _passwordController,
                  Icons.lock,
                  isPassword: true,
                ),
                _buildInputField(
                  "Số điện thoại",
                  _phoneController,
                  Icons.phone,
                ),
                _buildInputField("Địa chỉ", _addressController, Icons.home),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        authController.isLoading
                            ? null
                            : _signin, // Disable khi đang loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child:
                        authController.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Đăng Ký"),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Đã có tài khoản? Đăng nhập ngay",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword ? !isPasswordVisible : false,
          keyboardType:
              label == "Số điện thoại"
                  ? TextInputType.phone
                  : TextInputType.text,
          inputFormatters:
              label == "Số điện thoại"
                  ? [
                    FilteringTextInputFormatter.digitsOnly,
                  ] // Chỉ cho phép nhập số
                  : [],
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Nhập $label...",
            hintStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: Colors.black, size: 18),
            suffixIcon:
                isPassword // 🔥 Chỉ hiển thị icon mắt nếu là mật khẩu
                    ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons
                                .visibility // 🔥 Icon mắt mở
                            : Icons.visibility_off, // 🔥 Icon mắt đóng
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible =
                              !isPasswordVisible; // 🔄 Đảo trạng thái
                        });
                      },
                    )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 15,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
