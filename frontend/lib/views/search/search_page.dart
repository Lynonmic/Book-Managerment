import 'package:flutter/material.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/service/api_service.dart';
import 'package:frontend/views/profile/edit_profile_page.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModels> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      List<UserModels> results = await ApiService().searchUsers(query);
      setState(() => _searchResults = results);
    } catch (e) {
      print("Search error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editUser(UserModels user) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfilePage(
              isEditing: true,
              userData: {
                'id': user.maKhachHang,
                'name': user.tenKhachHang,
                'email': user.email,
                'phone': user.soDienThoai,
                'address': user.diaChi,
                'avatar': user.urlAvata,
              },
            ),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        int index = _searchResults.indexWhere(
          (u) => u.maKhachHang == updatedUser['id'],
        );
        if (index != -1) {
          _searchResults[index] = UserModels.fromJson(updatedUser);
        }
      });

      // Gọi lại tìm kiếm để lấy dữ liệu mới nhất từ API
      _performSearch(_searchController.text);
    }
  }

  Future<void> _deleteUser(UserModels user) async {
    bool confirm = await _showDeleteConfirmation(user);
    if (confirm) {
      Map<String, dynamic> response = await ApiService.deleteUser(
        user.maKhachHang!,
      );

      if (response["success"] == true) {
        setState(() {
          _searchResults.removeWhere((u) => u.maKhachHang == user.maKhachHang);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Xóa người dùng thành công"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Xóa thất bại"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(UserModels user) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Xóa ${user.tenKhachHang} ?"),
                content: const Text("Bạn có chắc muốn xóa người dùng này?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Xóa",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nhập tên hoặc email...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child:
                      _searchResults.isEmpty
                          ? const Center(
                            child: Text("Không tìm thấy người dùng"),
                          )
                          : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              return ListTile(
                                leading:
                                    user.urlAvata != null &&
                                            user.urlAvata!.isNotEmpty
                                        ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            user.urlAvata!,
                                          ),
                                        )
                                        : const Icon(Icons.person),
                                title: Text(
                                  user.tenKhachHang ?? 'Không có tên',
                                ),
                                subtitle: Text(user.email ?? 'Không có email'),
                                onTap: () => _editUser(user),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') _editUser(user);
                                    if (value == 'delete') _deleteUser(user);
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text("✏️ Sửa"),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            "❌ Xóa",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                ),
                              );
                            },
                          ),
                ),
          ],
        ),
      ),
    );
  }
}
