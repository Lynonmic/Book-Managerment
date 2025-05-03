import 'dart:io';

abstract class UserEvent {}

class LoadUsersEvent extends UserEvent {}

class DeleteUserEvent extends UserEvent {
  final int userId;

  DeleteUserEvent(this.userId);
}
class UpdateUserEvent extends UserEvent {
  final int userId;
  final String tenKhachHang;
  final String soDienThoai;
  final String diaChi;
  final String email;
  final File? avatar;

  UpdateUserEvent({
    required this.userId,
    required this.tenKhachHang,
    required this.soDienThoai,
    required this.diaChi,
    required this.email,
    this.avatar,
  });
}

