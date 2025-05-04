import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/search/search_user_bloc.dart';
import 'package:frontend/blocs/search/search_user_event.dart';
import 'package:frontend/blocs/search/search_user_state.dart';
import 'package:frontend/blocs/user/user_bloc.dart';
import 'package:frontend/blocs/user/user_event.dart';
import 'package:frontend/model/UserModels.dart';
import 'package:frontend/screens/profile/edit_profile_page.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SearchUserBloc>().add(PerformSearchUserEvent(''));
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
              onChanged: (query) {
                context.read<SearchUserBloc>().add(PerformSearchUserEvent(query));
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocConsumer<SearchUserBloc, SearchUserState>(
                listener: (context, state) {
                  // if (state is SearchUserError) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text(state.message)),
                  //   );
                  // }
                },
                builder: (context, state) {
                  if (state is SearchUserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchUserSuccess) {
                    final _searchResults = state.results;
                    if (_searchResults.isEmpty) {
                      return const Center(child: Text("Không tìm thấy người dùng"));
                    }
                    return ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          leading: user.urlAvata != null &&
                                  user.urlAvata!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.urlAvata!),
                                )
                              : const Icon(Icons.person),
                          title: Text(user.tenKhachHang ?? 'Không có tên'),
                          subtitle: Text(user.email ?? 'Không có email'),
                          onTap: () => _editUser(user),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _editUser(user);
                              if (value == 'delete') _deleteUser(user);
                            },
                            itemBuilder: (context) => [
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
                    );
                  }

                  return const Center(child: Text("Không có dữ liệu"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUser(UserModels user) async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
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
      context.read<UserBloc>().add(UpdateUserEvent(
        userId: user.maKhachHang!,
        tenKhachHang: updatedUser['name'],
        soDienThoai: updatedUser['phone'],
        diaChi: updatedUser['address'],
        email: updatedUser['email'],
        avatar: updatedUser['avatar'],
      ));
    }
    context.read<SearchUserBloc>().add(PerformSearchUserEvent(''));
  }

  Future<void> _deleteUser(UserModels user) async {
    bool confirm = await _showDeleteConfirmation(user);
    if (confirm) {
      context.read<UserBloc>().add(DeleteUserEvent(user.maKhachHang!));
    }
  }

  Future<bool> _showDeleteConfirmation(UserModels user) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
}
