import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_state.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin người dùng")),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthSuccess) {
            final user = state.userData;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tên: ${user['name'] ?? ''}", style: const TextStyle(fontSize: 18)),
                  Text("Email: ${user['email'] ?? ''}", style: const TextStyle(fontSize: 18)),
                  Text("SĐT: ${user['phone'] ?? ''}", style: const TextStyle(fontSize: 18)),
                  Text("Địa chỉ: ${user['address'] ?? ''}", style: const TextStyle(fontSize: 18)),
                  // Avatar nếu có
                  if (user['avatar'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(user['avatar']),
                      ),
                    ),
                ],
              ),
            );
          } else if (state is AuthFailure) {
            return Center(child: Text("Lỗi: ${state.message}"));
          } else {
            return const Center(child: Text("Chưa đăng nhập"));
          }
        },
      ),
    );
  }
}
