import 'dart:io';

abstract class UserEvent {}

class LoadUsersEvent extends UserEvent {}

class DeleteUserEvent extends UserEvent {
  final int userId;

  DeleteUserEvent(this.userId);
}

class UpdateUserEvent extends UserEvent {
  final int userId;
  final String? tenKhachHang;
  final String? soDienThoai;
  final String? diaChi;
  final String? email;
  final File? avatar;

  UpdateUserEvent({
    required this.userId,
    this.tenKhachHang,
    this.soDienThoai,
    this.diaChi,
    this.email,
    this.avatar,
  });
}

