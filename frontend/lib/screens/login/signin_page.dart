import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_event.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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

  void _signin() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      _showMessage("⚠️ Vui lòng điền đầy đủ thông tin!");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showMessage("📧 Email không hợp lệ!");
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignUpEvent(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        avatar: _selectedImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(117, 222, 217, 217),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            _showMessage("Đang xử lý...");
          } else if (state is AuthSuccess) {
            _showMessage("🎉 Đăng ký thành công!");
            Navigator.pop(context);
          } else if (state is AuthFailure) {
            _showMessage("❌ ${state.message}");
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
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

              // Input fields
              _buildInputField("Họ và tên", _nameController, Icons.person),
              _buildInputField("Email", _emailController, Icons.email),
              _buildInputField(
                "Mật khẩu",
                _passwordController,
                Icons.lock,
                isPassword: true,
              ),
              _buildInputField("Số điện thoại", _phoneController, Icons.phone),
              _buildInputField("Địa chỉ", _addressController, Icons.home),

              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("Đăng Ký"),
                ),
              ),
              const SizedBox(height: 10),

              // Navigation buttons
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
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
    );
  }

  // Common input field builder
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
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Nhập $label...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
            prefixIcon: Icon(icon, color: Colors.black),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed:
                          () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
