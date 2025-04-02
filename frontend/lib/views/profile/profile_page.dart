import 'package:flutter/material.dart';
import 'package:frontend/views/login/login_page.dart';
import 'package:frontend/views/profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = Map.from(widget.userData);
  }

  void _updateProfile(Map<String, dynamic> newData) {
    setState(() {
      _userData = Map.from(newData);
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // Để gradient lên cả AppBar
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              const SizedBox(height: 80),
              _buildAvatar(),
              const SizedBox(height: 20),
              Expanded(child: _buildProfileDetails(context)),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditProfilePage(isEditing: true, userData: _userData),
            ),
          );

          if (updatedData != null) {
            _updateProfile(updatedData);
          }
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purpleAccent, Colors.lightBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: CircleAvatar(
        radius: 55,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 50,
          backgroundImage:
              _userData['avatar'] != null ? NetworkImage(_userData['avatar']) : null,
          child: _userData['avatar'] == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileField(Icons.person, "Họ và tên", _userData['name']),
            _buildProfileField(Icons.email, "Email", _userData['email']),
            _buildProfileField(Icons.phone, "Số điện thoại", _userData['phone']),
            _buildProfileField(Icons.home, "Địa chỉ", _userData['address']),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        value ?? "Chưa có thông tin",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
