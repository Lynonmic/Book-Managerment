import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/users_controller.dart';
import 'package:frontend/service/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? userData;

  const EditProfilePage({super.key, required this.isEditing, this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final UsersController _usersController = UsersController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _nameController.text = widget.userData?['name'] ?? '';
    _emailController.text = widget.userData?['email'] ?? '';
    _phoneController.text = widget.userData?['phone'] ?? '';
    _addressController.text = widget.userData?['address'] ?? '';
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

  void _updateProfile() async {
    var response = await ApiService.updateUser(
      userId: widget.userData?['id'],
      tenKhachHang: _nameController.text,
      soDienThoai: _phoneController.text,
      diaChi: _addressController.text,
      email: _emailController.text,
      avatar: _selectedImage,
    );

    if (response != null) {
      bool success = response["success"] ?? false;
      String message = response["message"] ?? "Lỗi không xác định!";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        String? avatarUrl = response['user']['url_avata']; // Lấy URL từ server
        print("Avatar URL mới: $avatarUrl");

        Navigator.pop(context, {
          'id': widget.userData?['id'],
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'avatar': avatarUrl, // Trả về URL thay vì File
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "CHỈNH SỬA THÔNG TIN",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                              : (widget.userData?['avatar'] != null
                                      ? NetworkImage(widget.userData!['avatar'])
                                      : null)
                                  as ImageProvider?,
                      child:
                          (_selectedImage == null &&
                                  widget.userData?['avatar'] == null)
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
                  "Số điện thoại",
                  _phoneController,
                  Icons.phone,
                ),
                _buildInputField("Địa chỉ", _addressController, Icons.home),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.purpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ],
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
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType:
              label == "Số điện thoại"
                  ? TextInputType.phone
                  : TextInputType.text,
          inputFormatters:
              label == "Số điện thoại"
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [],
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            hintText: "Nhập $label...",
            hintStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: Colors.black, size: 18),
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
